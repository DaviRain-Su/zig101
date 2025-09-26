//
// 现在我们来创建一个带参数的函数。
// 下面是一个带两个参数的例子。可以看到，参数的声明方式和其他类型一样：
// ("名字": "类型")
//
//     fn myFunction(number: u8, is_lucky: bool) void {
//         ...
//     }
//
const std = @import("std");

pub fn main() void {
    std.debug.print("Powers of two: {} {} {} {}\n", .{
        twoToThe(1),
        twoToThe(2),
        twoToThe(3),
        twoToThe(4),
    });
}

// 请为这个函数补上正确的输入参数。
// 你需要推断出参数的名字和类型。
// 输出类型已经为你写好了。
//
fn twoToThe(???) u32 {
    return std.math.pow(u32, 2, my_number);
    // std.math.pow(type, a, b) 接收一个数值类型和两个
    // 该类型（或可转换为该类型）的数字，
    // 返回 "a 的 b 次方"，结果也是该数值类型。
}
