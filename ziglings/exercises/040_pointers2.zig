//
// 需要注意的一点是：变量指针 (variable pointer) 和常量指针 (constant pointer)
// 是不同的类型。
//
// 给定：
//
//     var foo: u8 = 5;
//     const bar: u8 = 5;
//
// 那么：
//
//     &foo 的类型是 "*u8"
//     &bar 的类型是 "*const u8"
//
// 你总是可以把一个可变值 (var) 的引用赋给一个常量指针，
// 但你不能把不可变值 (const) 的引用赋给一个变量指针。
//
// 听起来像是逻辑谜题，其实意思就是：
// 一旦数据被声明为不可变，就不能把它强制转换为可变类型。
// 可以把“可变数据”想象成是易变的甚至危险的。
// Zig 总是允许你“更安全”，但绝不允许你“更不安全”。
//
const std = @import("std");

pub fn main() void {
    const a: u8 = 12;
    const b: *u8 = &a; // 修复这里！

    std.debug.print("a: {}, b: {}\n", .{ a, b.* });
}
