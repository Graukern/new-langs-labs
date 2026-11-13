const std = @import("std");

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    const path = if (args.len > 1) args[1] else "sample/records.txt";
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 1024 * 1024);
    defer allocator.free(content);

    var lines = std.mem.splitScalar(u8, content, '\n');
    const stdout = std.io.getStdOut().writer();
    try stdout.print("name,value\n", .{});

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r");
        if (trimmed.len == 0) continue;

        if (std.mem.indexOfScalar(u8, trimmed, '=')) |separator| {
            const name = std.mem.trim(u8, trimmed[0..separator], " ");
            const value = std.mem.trim(u8, trimmed[separator + 1 ..], " ");
            try stdout.print("{s},{s}\n", .{ name, value });
        }
    }
}
