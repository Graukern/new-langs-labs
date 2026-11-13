import std.conv;
import std.datetime.stopwatch;
import std.format;
import std.parallelism;
import std.stdio;
import std.string;

void main(string[] args)
{
    int count = 1_000_000;
    if (args.length > 2) {
        writeln("Использование: main [верхняя-граница]");
        return;
    }
    if (args.length == 2) {
        try {
            count = to!int(args[1]);
        } catch (ConvException) {
            writeln("Верхняя граница должна быть целым числом.");
            return;
        }
    }
    if (count < 1) {
        writeln("Верхняя граница должна быть положительной.");
        return;
    }

    auto values = new long[count];
    foreach (i; 0 .. count) {
        values[i] = i + 1;
    }

    StopWatch sequentialWatch;
    sequentialWatch.start();
    long sequentialTotal = 0;
    foreach (value; values) {
        sequentialTotal += value * value;
    }
    sequentialWatch.stop();

    StopWatch parallelWatch;
    parallelWatch.start();
    long parallelTotal = 0;
    foreach (square; taskPool.amap!((long value) => value * value)(values)) {
        parallelTotal += square;
    }
    parallelWatch.stop();

    writeln("Последовательно: ", sequentialTotal, " за ",
        sequentialWatch.peek.total!"msecs", " мс");
    writeln("Параллельно: ", parallelTotal, " за ",
        parallelWatch.peek.total!"msecs", " мс");
}
