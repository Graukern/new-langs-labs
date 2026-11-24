import java.nio.file.Files

if (args.length != 2) {
    System.err.println('Использование: groovy src/main.groovy ВХОД.md ВЫХОД.txt')
    System.exit(1)
}

File input = new File(args[0])
File output = new File(args[1])
String tick = '`'
def fencePattern = ~('^ {0,3}(' + tick + '{3,})(.*)$')

try {
    if (output.exists() && Files.isSameFile(input.toPath(), output.toPath())) {
        throw new IOException('Входной и выходной файлы должны различаться')
    }

    List<String> entries = []
    int fenceLength = 0
    input.eachLine('UTF-8', 1) { line, number ->
        def fence = fencePattern.matcher(line)
        if (fence.matches()) {
            int length = fence.group(1).length()
            String suffix = fence.group(2)
            if (fenceLength == 0 && !suffix.contains(tick)) {
                fenceLength = length
            } else if (fenceLength > 0 && length >= fenceLength && suffix.trim().isEmpty()) {
                fenceLength = 0
            }
            return
        }

        if (fenceLength == 0) {
            def heading = line =~ /^(#{1,6}) (.+)$/
            if (heading.matches()) {
                String title = heading.group(2).trim().replaceFirst(/\s+#+$/, '')
                if (!title.isEmpty()) {
                    entries.add(number.toString() + ' — ' + heading.group(1).length() + ' — ' + title)
                }
            }
        }
    }

    output.withWriter('UTF-8') { writer ->
        entries.each { writer.writeLine(it) }
    }
} catch (IOException error) {
    System.err.println(error.message)
    System.exit(1)
}
