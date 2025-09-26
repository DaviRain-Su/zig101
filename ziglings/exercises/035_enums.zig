//
// 还记得我们之前用 `unreachable` 写的小型数学虚拟机吗？
// 其实那里面我们使用操作码 (op code) 的方式有两个问题：
//
//   1. 必须靠记忆去知道操作码对应的数字 —— 这太糟糕了。
//   2. 我们不得不使用 `unreachable`，因为 Zig 并不知道
//      有多少个有效的操作码。
//
// `enum`（枚举）是 Zig 提供的一种构造，
// 它允许你给数值起名字，并把它们放在一个集合里。
// 它们看起来和错误集合 (error set) 很像：
//
//     const Fruit = enum{ apple, pear, orange };
//
//     const my_fruit = Fruit.apple;
//
// 我们来用枚举来替代之前版本里用到的数字吧！
//
const std = @import("std");

// 请补全这个枚举！
const Ops = enum { ??? };

pub fn main() void {
    const operations = [_]Ops{
        Ops.inc,
        Ops.inc,
        Ops.inc,
        Ops.pow,
        Ops.dec,
        Ops.dec,
    };

    var current_value: u32 = 0;

    for (operations) |op| {
        switch (op) {
            Ops.inc => {
                current_value += 1;
            },
            Ops.dec => {
                current_value -= 1;
            },
            Ops.pow => {
                current_value *= current_value;
            },
            // 这里不需要 "else"！你知道为什么吗？
        }

        std.debug.print("{} ", .{current_value});
    }

    std.debug.print("\n", .{});
}
