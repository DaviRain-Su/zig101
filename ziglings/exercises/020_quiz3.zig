//
// 我们来看看能不能利用到目前学过的一些内容。
// 我们将创建两个函数：一个包含 `for` 循环，一个包含 `while` 循环。
//
// 下面这两个函数都被简单地标记为 "loop"。
//
const std = @import("std");

pub fn main() void {
    const my_numbers = [4]u16{ 5, 6, 7, 8 };

    printPowersOfTwo(my_numbers);
    std.debug.print("\n", .{});
}

// 这种写法并不是每天都能见到：一个函数参数是
// 一个包含 **恰好四个 u16 数字** 的数组。
// 这并不是你在实际中传递数组给函数的常规方法。
// 我们很快就会学习切片 (slice) 和指针 (pointer)。
// 现在我们只用已经掌握的知识。
//
// 这个函数只打印结果，不返回任何东西。
//
fn printPowersOfTwo(numbers: [4]u16) ??? {
    loop (numbers) |n| {
        std.debug.print("{} ", .{twoToThe(n)});
    }
}

// 这个函数和上一个练习中的 twoToThe() 有明显相似之处。
// 但别被迷惑了！这里我们不借助标准库，自己动手实现数学计算！
//
fn twoToThe(number: u16) ??? {
    var n: u16 = 0;
    var total: u16 = 1;

    loop (n < number) : (n += 1) {
        total *= 2;
    }

    return ???;
}
