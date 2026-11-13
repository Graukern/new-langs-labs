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

    var headers = std.ArrayList([]const u8).init(allocator);
    defer headers.deinit();
    var records = std.ArrayList([][]const u8).init(allocator);
    defer {
        for (records.items) |record| allocator.free(record);
        records.deinit();
    }
    var names = std.ArrayList([]const u8).init(allocator);
    defer names.deinit();
    var values = std.ArrayList([]const u8).init(allocator);
    defer values.deinit();
    var first_record = true;

    const saveRecord = struct {
        fn run(
            names_list: *std.ArrayList([]const u8),
            values_list: *std.ArrayList([]const u8),
            headers_list: *std.ArrayList([]const u8),
            records_list: *std.ArrayList([][]const u8),
            first: *bool,
            alloc: std.mem.Allocator,
        ) !void {
            if (values_list.items.len == 0) return;
            if (first.*) {
                try headers_list.appendSlice(names_list.items);
                first.* = false;
            }
            try records_list.append(try values_list.toOwnedSlice());
            names_list.clearRetainingCapacity();
            values_list.* = std.ArrayList([]const u8).init(alloc);
        }
    }.run;

    var lines = std.mem.splitScalar(u8, content, '\n');
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \r");
        if (trimmed.len == 0) {
            try saveRecord(&names, &values, &headers, &records, &first_record, allocator);
            continue;
        }

        if (std.mem.indexOfScalar(u8, trimmed, '=')) |separator| {
            const name = std.mem.trim(u8, trimmed[0..separator], " \r");
            const value = std.mem.trim(u8, trimmed[separator + 1 ..], " ");
            if (first_record) try names.append(name);
            try values.append(value);
        }
    }

    try saveRecord(&names, &values, &headers, &records, &first_record, allocator);

    const stdout = std.io.getStdOut().writer();
    for (headers.items, 0..) |header, index| {
        if (index > 0) try stdout.print(",", .{});
        try stdout.print("{s}", .{header});
    }
    try stdout.print("\n", .{});
    for (records.items) |record| {
        for (record, 0..) |value, index| {
            if (index > 0) try stdout.print(",", .{});
            try stdout.print("{s}", .{value});
        }
        try stdout.print("\n", .{});
    }
}
