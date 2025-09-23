const std = @import("std");
const learn_zig = @import("learn_zig");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    //try learn_zig.bufferedPrint();
    //try learn_zig.thread_usage.basicThreadExample();
    //try learn_zig.thread_usage.multipleThreads(4);
    //try learn_zig.thread_usage.threadWithResult(10);
    //try learn_zig.thread_usage.mutexExample(f32, 100, 0.0);
    //try learn_zig.simple_http_server.simpleHttpServer();
    //

    // slice
    var arr = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9 };
    std.debug.print("arr ptr: {*}, arr len: {d}\n", .{ &arr, arr.len });
    var p: [*]i32 = &arr;
    std.debug.print("arr ptr: {*}, value: {d}\n", .{ &p, p[0] });
    std.debug.print("arr ptr: {*}, value: {d}\n", .{ &(p + 1), (p + 1)[0] });

    const byte_ptr: [*]u8 = @ptrCast(&arr);
    const step = @sizeOf(i32);

    // 加上 @alignCast 后，调试模式能帮你确保没有未对齐访问。
    for (0..arr.len) |i| {
        const p_from_bytes: [*]i32 = @ptrCast(@alignCast(byte_ptr + i * step));
        comptime {
            if (@alignOf(@TypeOf(arr[0])) < @alignOf(i32)) @compileError("unexpected alignment");
        }
        std.debug.print("Index {d} pointer: {*}, value: {d}\n", .{ i, p_from_bytes, p_from_bytes[0] });
    }

    const slice = arr[1..4];
    std.debug.print("Slice: {any}, slice pointer: {*}, slice length: {d}\n", .{ slice, slice.ptr, slice.len });

    const temp_arr = [_]u8{1} ** 4;
    std.debug.print("TArray: {any}\n", .{temp_arr});

    // print hello world
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("Hello, {s}!\n", .{"world"});
    try stdout.flush(); // Don't forget to flush!
}

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
