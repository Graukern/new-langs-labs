from std.collections import Dict
from std.sys import argv

def decode_literal(line: String, start: Int) raises -> String:
    var bytes = line.as_bytes()
    var index = start
    while index < len(bytes) and (bytes[index] == 32 or bytes[index] == 9):
        index += 1
    if index >= len(bytes) or bytes[index] != 34:
        raise Error("Ожидалась строка PO в кавычках.")
    index += 1

    var decoded = List[UInt8]()
    while index < len(bytes):
        var byte = bytes[index]
        index += 1
        if byte == 34:
            if index != len(bytes):
                raise Error("Лишние данные после строки PO.")
            return String(unsafe_from_utf8=decoded)
        if byte == 92:
            if index == len(bytes):
                break
            var escaped = bytes[index]
            index += 1
            if escaped == 97:
                byte = 7
            elif escaped == 98:
                byte = 8
            elif escaped == 102:
                byte = 12
            elif escaped == 110:
                byte = 10
            elif escaped == 114:
                byte = 13
            elif escaped == 116:
                byte = 9
            elif escaped == 118:
                byte = 11
            elif escaped == 34 or escaped == 92 or escaped == 39 or escaped == 63:
                byte = escaped
            else:
                raise Error("Неизвестная escape-последовательность PO.")
        decoded.append(byte)
    raise Error("Не хватает закрывающей кавычки.")

def quote_json(value: String) -> String:
    var digits = String("0123456789abcdef")
    var hex = digits.as_bytes()
    var encoded = List[UInt8]()
    encoded.append(34)
    for byte in value.as_bytes():
        if byte < 32:
            encoded.append(92)
            encoded.append(117)
            encoded.append(48)
            encoded.append(48)
            encoded.append(hex[Int(byte) // 16])
            encoded.append(hex[Int(byte) % 16])
        else:
            if byte == 34 or byte == 92:
                encoded.append(92)
            encoded.append(byte)
    encoded.append(34)
    return String(unsafe_from_utf8=encoded)

def add_entry(key: String, value: String, mut entries: List[String],
              mut seen: Dict[String, Bool]) raises:
    if key.byte_length() == 0:
        return
    if key in seen:
        raise Error("Повторяющийся msgid: " + key)
    seen[key] = True
    entries.append("  " + quote_json(key) + ": " + quote_json(value))

def convert(content: String) raises -> String:
    var entries = List[String]()
    var seen = Dict[String, Bool]()
    var key = String()
    var value = String()
    var has_key = False
    var has_value = False
    var number = 0

    for raw in content.split("\n"):
        number += 1
        var line = String(raw.strip())
        if line.byte_length() == 0 or line.startswith("#"):
            continue

        try:
            if line.startswith("msgid"):
                if has_key:
                    if not has_value:
                        raise Error("Для предыдущего msgid нет перевода.")
                    add_entry(key, value, entries, seen)
                key = decode_literal(line, 5)
                has_key = True
                has_value = False
            elif line.startswith("msgstr") and has_key and not has_value:
                value = decode_literal(line, 6)
                has_value = True
            elif line.startswith("\"") and has_key:
                var continuation = decode_literal(line, 0)
                if has_value:
                    value += continuation
                else:
                    key += continuation
            else:
                raise Error("Ожидались msgid, msgstr или продолжение строки.")
        except error:
            raise Error("Строка " + String(number) + ": " + String(error))

    if has_key:
        if not has_value:
            raise Error("Для последнего msgid нет перевода.")
        add_entry(key, value, entries, seen)
    if len(entries) == 0:
        return "{}\n"
    return "{\n" + ",\n".join(entries) + "\n}\n"

def main() raises:
    var args = argv()
    if len(args) != 3:
        raise Error("Использование: mojo run src/main.mojo ВХОД.po ВЫХОД.json")
    var input_path = String(args[1])
    var output_path = String(args[2])
    if input_path == output_path:
        raise Error("Входной и выходной файлы должны различаться.")
    var content = open(input_path, "r").read()
    var result = convert(content)
    with open(output_path, "w") as output:
        output.write(result)
