//
// Zig 提供了一个很方便的 `try` 简写，
// 用来处理常见的错误传递模式：
//
//     canFail() catch |err| return err;
//
// 这可以更紧凑地写成：
//
//     try canFail();
//
const std = @import("std");

const MyNumberError = error{
    TooSmall,
    TooBig,
};

pub fn main() void {
    const a: u32 = addFive(44) catch 0;
    const b: u32 = addFive(14) catch 0;
    const c: u32 = addFive(4) catch 0;

    std.debug.print("a={}, b={}, c={}\n", .{ a, b, c });
}

fn addFive(n: u32) MyNumberError!u32 {
    // 这个函数需要返回 detect() 可能带回的任何错误。
    // 请使用 `try` 语句，而不是 `catch`。
    //
    const x = detect(n);

    return x + 5;
}

fn detect(n: u32) MyNumberError!u32 {
    if (n < 10) return MyNumberError.TooSmall;
    if (n > 20) return MyNumberError.TooBig;
    return n;
}
