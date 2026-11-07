import Glibc
import Foundation

func makeAddress(host: String, port: Int) -> sockaddr_in {
    var address = sockaddr_in()
    address.sin_family = sa_family_t(AF_INET)
    address.sin_port = in_port_t(port).bigEndian
    address.sin_addr = in_addr(s_addr: inet_addr(host))
    return address
}

func sendMessage(socket: Int32, message: String) {
    let data = Array((message + "\n").utf8)
    data.withUnsafeBytes { buffer in
        _ = write(socket, buffer.baseAddress, buffer.count)
    }
}

func receiveMessage(socket: Int32) -> String {
    var buffer = [UInt8](repeating: 0, count: 1024)
    let count = read(socket, &buffer, buffer.count)
    if count <= 0 {
        return ""
    }
    return String(decoding: buffer[0..<count], as: UTF8.self)
}

let arguments = Array(CommandLine.arguments.dropFirst())
guard arguments.count >= 3 else {
    fputs("Использование: server|client АДРЕС ПОРТ [СООБЩЕНИЕ]\n", stderr)
    exit(1)
}

let mode = arguments[0]
let host = arguments[1]
guard let port = Int(arguments[2]) else {
    fputs("Порт должен быть числом\n", stderr)
    exit(1)
}

if mode == "server" {
    let server = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
    var address = makeAddress(host: host, port: port)
    let bindResult = withUnsafePointer(to: &address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            bind(server, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    guard server >= 0, bindResult == 0, listen(server, 1) == 0 else {
        fputs("Не удалось запустить сервер\n", stderr)
        exit(1)
    }

    print("Сервер слушает \(host):\(port)")
    let client = accept(server, nil, nil)
    if client >= 0 {
        let message = receiveMessage(socket: client).trimmingCharacters(in: .whitespacesAndNewlines)
        sendMessage(socket: client, message: "Получено: \(message)")
        close(client)
    }
    close(server)
} else if mode == "client" && arguments.count >= 4 {
    let client = socket(AF_INET, Int32(SOCK_STREAM.rawValue), 0)
    var address = makeAddress(host: host, port: port)
    let result = withUnsafePointer(to: &address) {
        $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
            connect(client, $0, socklen_t(MemoryLayout<sockaddr_in>.size))
        }
    }
    guard result == 0 else {
        fputs("Не удалось подключиться к серверу\n", stderr)
        exit(1)
    }
    sendMessage(socket: client, message: arguments[3])
    print("Ответ сервера: \(receiveMessage(socket: client).trimmingCharacters(in: .whitespacesAndNewlines))")
    close(client)
} else {
    fputs("Неверные аргументы\n", stderr)
    exit(1)
}
