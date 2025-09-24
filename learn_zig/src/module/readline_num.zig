const std = @import("std");

pub fn readline_number() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        std.debug.print("Usage: {s} <filename>\n", .{args[0]});
        return;
    }

    const filename = args[1];
    var file = try std.fs.cwd().openFile(filename, .{ .mode = .read_only });
    defer file.close();

    var buf: [4096]u8 = undefined;
    var file_reader = file.reader(&buf); // 0.15：给 Reader 提供缓冲
    var line_count: usize = 0;

    // 逐行读取（不分配）
    while (file_reader.interface.takeDelimiterExclusive('\n')) |line| {
        _ = line; // 只计数
        line_count += 1;
    } else |err| switch (err) {
        error.EndOfStream => {}, // 到 EOF 停止
        else => return err,
    }

    std.debug.print("File \"{s}\" has {d} lines.\n", .{ filename, line_count });
}
