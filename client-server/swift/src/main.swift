import Foundation
import Glibc

struct Standing {
    var played = 0
    var points = 0
}

func reply(to command: String, standings: inout [String: Standing]) -> String {
    let fields = command.split(whereSeparator: \.isWhitespace)
    if fields == ["TABLE"] {
        let ordered = standings.sorted { left, right in
            if left.value.points == right.value.points {
                return left.key < right.key
            }
            return left.value.points > right.value.points
        }
        let rows = ordered.map { name, standing in
            "\(name)\t\(standing.played)\t\(standing.points)"
        }
        return (["Команда\tМатчи\tОчки"] + rows).joined(separator: "\n")
    }

    guard fields.count == 5, fields[0] == "RESULT", fields[1] != fields[2],
          let firstScore = Int(fields[3]), let secondScore = Int(fields[4]),
          firstScore >= 0, secondScore >= 0 else {
        return "ERROR"
    }

    let first = String(fields[1])
    let second = String(fields[2])
    standings[first, default: Standing()].played += 1
    standings[second, default: Standing()].played += 1
    if firstScore == secondScore {
        standings[first, default: Standing()].points += 1
        standings[second, default: Standing()].points += 1
    } else {
        let winner = firstScore > secondScore ? first : second
        standings[winner, default: Standing()].points += 3
    }
    return "OK"
}

func sendMessage(_ message: String, on descriptor: Int32) -> Bool {
    let bytes = Array((message + "\n").utf8)
    return bytes.withUnsafeBytes { buffer in
        var offset = 0
        while offset < buffer.count {
            let sent = send(descriptor, buffer.baseAddress!.advanced(by: offset),
                            buffer.count - offset, Int32(MSG_NOSIGNAL))
            if sent < 0 && errno == EINTR { continue }
            if sent <= 0 { return false }
            offset += sent
        }
        return true
    }
}

func readResponse(on descriptor: Int32, singleLine: Bool) -> String? {
    var data: [UInt8] = []
    var buffer = [UInt8](repeating: 0, count: 1024)
    while true {
        let size = read(descriptor, &buffer, buffer.count)
        if size < 0 && errno == EINTR { continue }
        if size < 0 { return nil }
        if size == 0 { break }
        let chunk = buffer.prefix(size)
        if singleLine, let newline = chunk.firstIndex(of: 10) {
            data.append(contentsOf: chunk.prefix(upTo: newline))
            return String(bytes: data, encoding: .utf8)
        }
        data.append(contentsOf: chunk)
    }
    return data.isEmpty ? nil : String(bytes: data, encoding: .utf8)
}

func withAddress(
    _ address: inout sockaddr_in,
    _ operation: (UnsafePointer<sockaddr>, socklen_t) -> Int32
) -> Int32 {
    return withUnsafePointer(to: &address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            operation($0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
}

func fail(_ message: String) -> Never {
    fputs(message + "\n", stderr)
    exit(1)
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard (arguments.count == 3 && arguments.first == "server") ||
      (arguments.count == 4 && arguments.first == "client") else {
    fail("Использование: server|client АДРЕС ПОРТ [КОМАНДА]")
}
guard let port = UInt16(arguments[2]), port > 0 else {
    fail("Порт должен быть в диапазоне 1–65535")
}
var address = sockaddr_in()
address.sin_family = sa_family_t(AF_INET)
address.sin_port = port.bigEndian
guard inet_pton(AF_INET, arguments[1], &address.sin_addr) == 1 else {
    fail("Ожидался адрес IPv4")
}
let descriptor = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
guard descriptor >= 0 else { fail("Не удалось создать сокет") }

if arguments[0] == "server" {
    var reuse: Int32 = 1
    _ = setsockopt(descriptor, SOL_SOCKET, SO_REUSEADDR, &reuse,
                   socklen_t(MemoryLayout<Int32>.size))
    guard withAddress(&address, { bind(descriptor, $0, $1) }) == 0,
          listen(descriptor, 16) == 0 else {
        fail("Не удалось запустить сервер")
    }
    print("Сервер слушает \(arguments[1]):\(port)")
    var standings: [String: Standing] = [:]
    while true {
        let client = accept(descriptor, nil, nil)
        if client < 0 {
            if errno == EINTR { continue }
            fail("Не удалось принять подключение")
        }
        if let command = readResponse(on: client, singleLine: true) {
            _ = sendMessage(reply(to: command, standings: &standings), on: client)
        }
        close(client)
    }
} else {
    guard withAddress(&address, { connect(descriptor, $0, $1) }) == 0 else {
        fail("Не удалось подключиться к серверу")
    }
    guard sendMessage(arguments[3], on: descriptor),
          let response = readResponse(on: descriptor, singleLine: false) else {
        fail("Не удалось получить ответ сервера")
    }
    print(response, terminator: "")
    close(descriptor)
}
