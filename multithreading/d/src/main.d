import std.algorithm : map;
import std.conv;
import std.datetime.stopwatch;
import std.math : sqrt;
import std.parallelism;
import std.range : iota;
import std.stdio;

void main(string[] args)
{
    int count = 50_000_000;
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

    StopWatch sequentialWatch;
    sequentialWatch.start();
    double sequentialTotal = 0;
    foreach (value; 1 .. count + 1) {
        sequentialTotal += sqrt(cast(double) value);
    }
    sequentialWatch.stop();

    StopWatch parallelWatch;
    parallelWatch.start();
    double parallelTotal = taskPool.reduce!"a + b"(
        0.0, iota(1, count + 1).map!(value => sqrt(cast(double) value)));
    parallelWatch.stop();

    writeln("Потоков в пуле: ", taskPool.size + 1);
    writefln("Последовательно: %.0f за %d мс",
        sequentialTotal, sequentialWatch.peek.total!"msecs");
    writefln("Параллельно: %.0f за %d мс",
        parallelTotal, parallelWatch.peek.total!"msecs");
}
