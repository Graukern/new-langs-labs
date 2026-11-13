if #arg < 2 then
    io.stderr:write("Использование: lua5.4 main.lua ФАЙЛ add ТЕКСТ | list\n")
    os.exit(1)
end

local output_path = arg[1]
local mode = arg[2]

if mode == "add" then
    if #arg < 3 then
        io.stderr:write("Для режима add нужна заметка\n")
        os.exit(1)
    end
    local file, error_message = io.open(output_path, "a")
    if not file then
        io.stderr:write("Не удалось открыть файл: " .. error_message .. "\n")
        os.exit(1)
    end
    file:write(arg[3], "\n")
    file:close()
    print("Заметка добавлена")
elseif mode == "list" then
    local file, error_message = io.open(output_path, "r")
    if not file then
        io.stderr:write("Не удалось открыть файл: " .. error_message .. "\n")
        os.exit(1)
    end
    local number = 1
    for line in file:lines() do
        print(number .. ". " .. line)
        number = number + 1
    end
    file:close()
else
    io.stderr:write("Режим должен быть add или list\n")
    os.exit(1)
end
