//
// 哦不，这个程序应该打印 "Hello world!"，但它需要你的帮助。
//
// Zig 函数默认是私有的，但 main() 函数应该是公开的。
//
// 使用 "pub" 语句可以将函数设为公开，如下所示：
//
//     pub fn foo() void {
//         ...
//     }
//
// 也许知道这一点能帮助解决我们在这个小程序中遇到的错误？
//
const std = @import("std");

fn main() void {
    std.debug.print("Hello world!\n", .{});
}
