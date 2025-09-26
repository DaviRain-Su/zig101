//
// 匿名结构体字面量语法也可以用来组合一个带有数组类型目标的
// “匿名列表”：
//
//     const foo: [3]u32 = .{10, 20, 30};
//
// 否则它就是一个 “元组”：
//
//     const bar = .{10, 20, 30};
//
// 唯一的区别就是目标类型。
//
const print = @import("std").debug.print;

pub fn main() void {
    // 请把 'hello' 变成一个类似字符串的 u8 数组，
    // 但不要改变字面量的值。
    //
    // 不要改这里这一部分：
    //
    //     = .{ 'h', 'e', 'l', 'l', 'o' };
    //
    const hello = .{ 'h', 'e', 'l', 'l', 'o' };
    print("I say {s}!\n", .{hello});
}
