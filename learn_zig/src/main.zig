const std = @import("std");
const learn_zig = @import("learn_zig");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    //try learn_zig.bufferedPrint();
    //try learn_zig.thread_usage.basicThreadExample();
    //try learn_zig.thread_usage.multipleThreads(4);
    //try learn_zig.thread_usage.threadWithResult(10);
    try learn_zig.thread_usage.mutexExample(f32, 100, 0.0);
    //try learn_zig.simple_http_server.simpleHttpServer();
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
