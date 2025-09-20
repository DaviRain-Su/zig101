//
// 糟糕！这个程序应该像我们的 Hello World 示例一样打印一行文字。
// 但我们忘记了如何导入 Zig 标准库。
//
// @import() 函数是 Zig 的内置函数。它返回一个代表被导入代码的值。
// 将导入存储为与导入名称相同的常量值是一个好习惯：
//
//     const foo = @import("foo");
//
// 请完成下面的导入：
//

?? = @import("std");

pub fn main() void {
    std.debug.print("Standard Library.\n", .{});
}

// 对于好奇的人：导入必须声明为常量，因为它们只能在编译时使用，
// 而不能在运行时使用。Zig 在编译时计算常量值。
// 别担心，我们稍后会详细介绍导入。
// 另请参见这个回答：https://stackoverflow.com/a/62567550/695615
