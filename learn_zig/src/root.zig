//! By convention, root.zig is the root source file when making a library.
const std = @import("std");
pub const user = @import("module/user.zig");
pub const enum_usage = @import("module/enum_usage.zig");
pub const thread_usage = @import("module/thread_usage.zig");
pub const simple_http_server = @import("module/simple_http_server.zig");
pub const readline_number = @import("module/readline_num.zig");

pub fn bufferedPrint() !void {
    // Stdout is for the actual output of your application, for example if you
    // are implementing gzip, then only the compressed bytes should be sent to
    // stdout, not any debugging messages.
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;

    try stdout.print("Run `zig build test` to run the tests.\n", .{});

    try stdout.flush(); // Don't forget to flush!
}

pub fn add(comptime T: type, a: T, b: T) T {
    return a + b;
}

pub fn addi32(a: i32, b: i32) i32 {
    //a = b; // error: cannot assign to constant
    std.debug.print("a = {d}\n", .{a});
    return a + b;
}

pub fn addi32Byref(a: *i32, b: i32) i32 {
    a.* = b;
    std.debug.print("a = {d}\n", .{a.*});
    return a.* + b;
}

test "test addi32Byref" {
    var a: i32 = 3;
    try std.testing.expect(addi32Byref(&a, 7) == 14);
}

test "test addi32" {
    try std.testing.expect(addi32(3, 7) == 10);
}

test "comptime add functionality" {
    try std.testing.expect(add(i32, 3, 7) == 10);
}

test {
    _ = @import("module/user.zig");
    _ = @import("module/enum_usage.zig");
    _ = @import("module/thread_usage.zig");
}
