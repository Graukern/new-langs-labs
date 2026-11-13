def main() raises:
    var csv = open("sample/students.csv", "r").read()
    var lines = csv.split("\n")
    if len(lines) > 0:
        var headers = lines[0].replace("\r", "").split(",")
        var separators = ["---" for _ in headers]
        print("| " + " | ".join(headers) + " |")
        print("| " + " | ".join(separators) + " |")
        for line in lines[1:]:
            var clean_line = line.replace("\r", "")
            if clean_line.byte_length() > 0:
                print("| " + " | ".join(clean_line.split(",")) + " |")
