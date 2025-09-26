//
// Zig 有一个 `unreachable` 语句。
// 当你想告诉编译器某个分支永远不会被执行，
// 并且一旦执行到这里就说明出错了，
// 就可以使用它。
//
//     if (true) {
//         ...
//     } else {
//         unreachable;
//     }
//
// 这里我们写了一个小小的虚拟机 (VM)，
// 它会对一个数值执行数学运算。
// 看起来不错，但有个小问题：
// switch 语句并没有覆盖 u8 类型的所有可能值！
//
// **我们**知道只有三种操作，但 Zig 并不知道。
// 使用 `unreachable` 语句让这个 switch 完整起来。
// 否则，嘿嘿…… :-)
//
const std = @import("std");

pub fn main() void {
    const operations = [_]u8{ 1, 1, 1, 3, 2, 2 };

    var current_value: u32 = 0;

    for (operations) |op| {
        switch (op) {
            1 => {
                current_value += 1;
            },
            2 => {
                current_value -= 1;
            },
            3 => {
                current_value *= current_value;
            },
        }

        std.debug.print("{} ", .{current_value});
    }

    std.debug.print("\n", .{});
}
