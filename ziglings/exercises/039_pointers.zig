//
// 看这个：
//
//     var foo: u8 = 5;      // foo 是 5
//     var bar: *u8 = &foo;  // bar 是一个指针
//
// 什么是指针？它是对某个值的引用。
// 在这个例子里，bar 引用的是当前存放数值 5 的内存空间。
//
// 一个速查表（基于上面的声明）：
//
//     u8         u8 值的类型
//     foo        数值 5
//     *u8        指向一个 u8 值的指针类型
//     &foo       对 foo 的引用
//     bar        指向 foo 的指针
//     bar.*      数值 5（对 bar 解引用得到的值）
//
// 我们马上就会看到指针为什么有用。
// 现在，先看看你能不能让这个例子运行成功！
//
const std = @import("std");

pub fn main() void {
    var num1: u8 = 5;
    const num1_pointer: *u8 = &num1;

    var num2: u8 = undefined;

    // 请用 num1_pointer 让 num2 变成 5！
    // （可以参考上面的速查表。）
    num2 = ???;

    std.debug.print("num1: {}, num2: {}\n", .{ num1, num2 });
}
