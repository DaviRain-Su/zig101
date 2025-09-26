//
// Zig 的 `while` 语句可以带一个可选的 “continue 表达式”，
// 它会在每次循环继续时运行（不管是循环到末尾继续，还是
// 遇到显式的 `continue` 语句 - 我们接下来会尝试这个功能）：
//
//     while (condition) : (continue expression) {
//         ...
//     }
//
// 示例：
//
//     var foo = 2;
//     while (foo < 10) : (foo += 2) {
//         // 在这里处理小于 10 的偶数...
//     }
//
// 试试看能不能使用 continue 表达式，重写上一个练习：
//
const std = @import("std");

pub fn main() void {
    var n: u32 = 2;

    // 请设置 continue 表达式，这样才能得到下面打印语句中
    // 期望的结果。
    while (n < 1000) : ??? {
        // 打印当前数字
        std.debug.print("{} ", .{n});
    }

    // 和上一个练习一样，我们希望最终结果是 "n=1024"
    std.debug.print("n={}\n", .{n});
}
