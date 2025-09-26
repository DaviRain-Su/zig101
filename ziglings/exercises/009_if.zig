//
// 现在我们要进入一些有趣的内容，从 `if` 语句开始！
//
//     if (true) {
//         ...
//     } else {
//         ...
//     }
//
// Zig 拥有“常见”的比较运算符，例如：
//
//     a == b   表示 “a 等于 b”
//     a < b    表示 “a 小于 b”
//     a > b    表示 “a 大于 b”
//     a != b   表示 “a 不等于 b”
//
// Zig 的 `if` 语句有一个很重要的特性：它 *只* 接受布尔值。
// 它不会像其他语言那样把数字或其他类型自动转为 true 或 false。
//
const std = @import("std");

pub fn main() void {
    const foo = 1;

    // 请修复这里的条件：
    if (foo) {
        // 我们希望程序能打印这条消息！
        std.debug.print("Foo is 1!\n", .{});
    } else {
        std.debug.print("Foo is not 1!\n", .{});
    }
}
