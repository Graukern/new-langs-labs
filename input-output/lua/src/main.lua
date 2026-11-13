if #arg < 2 then
    io.stderr:write("Нужно передать имя файла и хотя бы одну заметку\n")
    os.exit(1)
end

local output_path = arg[1]
local file, error_message = io.open(output_path, "a")
if not file then
    io.stderr:write("Не удалось открыть файл: " .. error_message .. "\n")
    os.exit(1)
end

for index = 2, #arg do
    file:write(arg[index], "\n")
end

file:close()
print("Заметки сохранены в " .. output_path)
