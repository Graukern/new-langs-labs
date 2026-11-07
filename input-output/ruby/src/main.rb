source_path, target_path = ARGV

if source_path.nil? || target_path.nil?
  warn "Использование: ruby src/main.rb ИСХОДНЫЙ_ФАЙЛ ФАЙЛ_КОПИЯ"
  exit 1
end

unless File.file?(source_path)
  warn "Файл не найден: #{source_path}"
  exit 1
end

File.binwrite(target_path, File.binread(source_path))

source_size = File.size(source_path)
target_size = File.size(target_path)
puts "Размер исходного файла: #{source_size}"
puts "Размер копии: #{target_size}"
