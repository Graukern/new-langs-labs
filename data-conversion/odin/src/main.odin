package main

import "core:fmt"
import "core:os"
import "core:strconv"
import "core:strings"

Color :: [3]u8
alphabet :: "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

next_token :: proc(data: string, position: ^int) -> string {
	for position^ < len(data) {
		switch data[position^] {
		case ' ', '\t', '\r', '\n', '\v', '\f':
			position^ += 1
		case '#':
			for position^ < len(data) && data[position^] != '\n' && data[position^] != '\r' {
				position^ += 1
			}
		case:
			start := position^
			for position^ < len(data) {
				switch data[position^] {
				case ' ', '\t', '\r', '\n', '\v', '\f', '#':
					return data[start:position^]
				}
				position^ += 1
			}
			return data[start:position^]
		}
	}
	return ""
}

fail :: proc(message: string) {
	fmt.eprintln(message)
	os.exit(1)
}

read_number :: proc(data: string, position: ^int) -> int {
	token := next_token(data, position)
	for digit in token {
		if digit < '0' || digit > '9' do fail("Ожидалось целое неотрицательное число.")
	}
	value, ok := strconv.parse_int(token, 10)
	if !ok || token == "" do fail("Ожидалось целое неотрицательное число.")
	return value
}

write_code :: proc(builder: ^strings.Builder, index, width: int) {
	buffer: [32]u8
	digits := alphabet
	value := index
	for position := width - 1; position >= 0; position -= 1 {
		buffer[position] = digits[value % len(alphabet)]
		value /= len(alphabet)
	}
	strings.write_string(builder, string(buffer[:width]))
}

main :: proc() {
	if len(os.args) != 3 do fail("Использование: odin run src/main.odin -file -- ВХОД.ppm ВЫХОД.xpm")
	data, read_error := os.read_entire_file_from_path(os.args[1], context.allocator)
	if read_error != nil do fail("Не удалось прочитать входной файл.")
	defer delete(data)

	input := string(data)
	position := 0
	if next_token(input, &position) != "P3" do fail("Ожидался формат PPM P3.")
	width := read_number(input, &position)
	height := read_number(input, &position)
	if width <= 0 || height <= 0 || width > len(data) / height {
		fail("Некорректные размеры изображения.")
	}
	if read_number(input, &position) != 255 do fail("Ожидалось максимальное значение канала 255.")

	indices := make(map[Color]int)
	defer delete(indices)
	palette: [dynamic]Color
	defer delete(palette)
	pixels := make([]int, width * height)
	defer delete(pixels)
	for index in 0..<len(pixels) {
		color: Color
		for channel in 0..<len(color) {
			value := read_number(input, &position)
			if value > 255 do fail("Значение цветового канала должно быть не больше 255.")
			color[channel] = u8(value)
		}
		palette_index, exists := indices[color]
		if !exists {
			palette_index = len(palette)
			indices[color] = palette_index
			append(&palette, color)
		}
		pixels[index] = palette_index
	}
	if next_token(input, &position) != "" do fail("После последнего пикселя остались лишние данные.")

	code_width := 1
	for index := len(palette) - 1; index >= len(alphabet); index /= len(alphabet) {
		code_width += 1
	}
	builder: strings.Builder
	strings.builder_init(&builder)
	defer strings.builder_destroy(&builder)
	strings.write_string(&builder, "/* XPM */\nstatic char *image[] = {\n")
	fmt.sbprintf(&builder, "\"%d %d %d %d\",\n", width, height, len(palette), code_width)
	for color, index in palette {
		strings.write_string(&builder, "\"")
		write_code(&builder, index, code_width)
		fmt.sbprintf(&builder, " c #%02X%02X%02X\",\n", color[0], color[1], color[2])
	}
	for row in 0..<height {
		strings.write_string(&builder, "\"")
		for column in 0..<width {
			write_code(&builder, pixels[row * width + column], code_width)
		}
		strings.write_string(&builder, "\"")
		if row < height - 1 do strings.write_string(&builder, ",")
		strings.write_string(&builder, "\n")
	}
	strings.write_string(&builder, "};\n")
	if os.write_entire_file_from_string(os.args[2], strings.to_string(builder)) != nil {
		fail("Не удалось записать выходной файл.")
	}
}
