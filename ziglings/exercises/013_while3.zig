//
// 前两个练习在功能上其实是一样的。continue 表达式的真正
// 用处，在于与 `continue` 语句配合使用时才能体现出来！
//
// 示例：
//
//     while (condition) : (continue expression) {
//
//         if (other condition) continue;
//
//     }
//
// “continue 表达式” 会在每次循环重新开始时执行，
// 无论是否发生了 `continue` 语句。
//
const std = @import("std");

pub fn main() void {
    var n: u32 = 1;

    // 我想打印 1 到 20 之间所有 **不能被 3 或 5 整除** 的数字。
    while (n <= 20) : (n += 1) {
        // `%` 符号是“取模”运算符，
        // 它会返回除法之后的余数。
        if (n % 3 == 0) ???;
        if (n % 5 == 0) ???;
        std.debug.print("{} ", .{n});
    }

    std.debug.print("\n", .{});
}
