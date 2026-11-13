package main

import "core:fmt"
import "core:os"
import "core:strings"

main :: proc() {
	args := os.args
	path := "sample/config.txt"
	if len(args) > 1 {
		path = args[1]
	}

	data, ok := os.read_entire_file(path)
	if !ok {
		fmt.eprintln("Не удалось прочитать файл: ", path)
		return
	}

	fmt.println("{")
	lines := strings.split(string(data), "\n")
	for index, line in lines {
		trimmed := strings.trim_space(line)
		if trimmed == "" {
			continue
		}
		parts := strings.split(trimmed, "=")
		if len(parts) != 2 {
			continue
		}
		comma := if index < len(lines) - 1 { "," } else { "" }
		fmt.printf("  \"%s\": \"%s\"%s\n",
			strings.trim_space(parts[0]),
			strings.trim_space(parts[1]),
			comma)
	}
	fmt.println("}")
}
