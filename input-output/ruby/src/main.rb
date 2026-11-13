source_path, target_path = ARGV

if source_path.nil? || target_path.nil?
  warn "Использование: ruby src/main.rb ИСХОДНЫЙ_ФАЙЛ ФАЙЛ_КОПИЯ"
  exit 1
end

unless File.file?(source_path)
  warn "Файл не найден: #{source_path}"
  exit 1
end

count = 0
File.open(target_path, "w", encoding: "UTF-8") do |target|
  File.foreach(source_path, encoding: "UTF-8") do |line|
    count += 1
    target.puts "#{count}. #{line.chomp}"
  end
end

puts "Скопировано строк: #{count}"
