//
// 错误的一个常见场景是：我们期望得到一个值，
// 但也有可能出现问题。来看这个例子：
//
//     var text: Text = getText("foo.txt");
//
// 如果 getText() 找不到 "foo.txt"，会发生什么呢？
// 我们要如何在 Zig 里表达这种情况？
//
// Zig 允许我们创建一种叫做 “错误联合 (error union)” 的类型。
// 它表示一个值：这个值要么是一个正常的结果，
// 要么是来自某个错误集合 (error set) 的错误。
//
//     var text: MyErrorSet!Text = getText("foo.txt");
//
// 现在，我们就来试试看能不能创建一个错误联合！
//
const std = @import("std");

const MyNumberError = error{TooSmall};

pub fn main() void {
    var my_number: ??? = 5;

    // 看起来 my_number 需要能同时表示一个数字或者一个错误。
    // 你能在上面把类型设置正确吗？
    my_number = MyNumberError.TooSmall;

    std.debug.print("I compiled!\n", .{});
}
