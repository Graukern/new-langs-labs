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

	data, err := os.read_entire_file_from_path(path, context.allocator)
	if err != nil {
		fmt.eprintfln("Не удалось прочитать файл %s: %v", path, err)
		return
	}

	fmt.println("{")
	lines := strings.split(string(data), "\n")
	first := true
	for line in lines {
		trimmed := strings.trim_space(line)
		if trimmed == "" {
			continue
		}
		parts := strings.split_n(trimmed, "=", 2)
		if len(parts) != 2 {
			continue
		}
		if !first {
			fmt.println(",")
		}
		first = false
		fmt.printf("  \"%s\": \"%s\"",
			strings.trim_space(parts[0]),
			strings.trim_space(parts[1]))
	}
	fmt.println()
	fmt.println("}")
}
