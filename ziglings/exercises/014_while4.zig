//
// 你可以使用 "break" 语句让循环立即退出：
//
//     while (condition) : (continue expression) {
//
//         if (other condition) break;
//
//     }
//
// 注意：当 while 循环因为 break 停止时，
// “continue 表达式” **不会** 被执行！
//
const std = @import("std");

pub fn main() void {
    var n: u32 = 1;

    // 哎呀！这个 while 循环会永远执行下去？！
    // 请修复它，使得下面的打印语句能够得到期望的输出。
    while (true) : (n += 1) {
        if (???) ???;
    }

    // 结果：我们希望输出 n=4
    std.debug.print("n={}\n", .{n});
}
