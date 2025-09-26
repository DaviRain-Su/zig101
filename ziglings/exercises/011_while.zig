//
// Zig 的 `while` 语句会创建一个循环，只要条件为真就会运行。
// 下面的代码最多运行一次：
//
//     while (condition) {
//         condition = false;
//     }
//
// 记住：条件必须是布尔值，
// 我们可以通过比较运算符得到布尔值，例如：
//
//     a == b   表示 “a 等于 b”
//     a < b    表示 “a 小于 b”
//     a > b    表示 “a 大于 b”
//     a != b   表示 “a 不等于 b”
//
const std = @import("std");

pub fn main() void {
    var n: u32 = 2;

    // 请使用一个条件，使得它在 "n" 达到 1024 之前保持为真：
    while (???) {
        // 打印当前数字
        std.debug.print("{} ", .{n});

        // 将 n 设置为 n 乘以 2
        n *= 2;
    }

    // 一旦上面的条件正确，这里会打印 "n=1024"
    std.debug.print("n={}\n", .{n});
}
