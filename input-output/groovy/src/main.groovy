def path = args ? args[0] : "sample/input.txt"
def file = new File(path)

if (!file.isFile()) {
    System.err.println("Файл не найден: ${path}")
    System.exit(1)
}

def text = file.getText("UTF-8")
def lines = text ? text.readLines().size() : 0
def words = text ? text.split(/\s+/).size() : 0

println "Строк: ${lines}"
println "Слов: ${words}"
println "Символов: ${text.length()}"
