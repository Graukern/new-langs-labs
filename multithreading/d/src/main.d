import std.conv;
import std.format;
import std.parallelism;
import std.stdio;
import std.string;

void main(string[] args)
{
    int count = 100;
    if (args.length == 2) {
        count = to!int(args[1]);
    } else if (args.length > 2 || count < 1) {
        writeln("Использование: main [количество-строк]");
        return;
    }

    auto lines = new string[count];
    foreach (i; 0 .. count) {
        lines[i] = format("строка-%s", i + 1);
    }

    long total = 0;
    foreach (length; taskPool.amap!((string line) => line.length)(lines)) {
        total += length;
    }

    writeln("Строк: ", count);
    writeln("Общая длина: ", total);
}
