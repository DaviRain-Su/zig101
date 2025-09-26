//
// if 语句在 Zig 中同样是一个有效的“表达式”:
//
//     const foo: u8 = if (a) 2 else 3;
//
const std = @import("std");

pub fn main() void {
    const discount = true;

    // 请使用 if...else 表达式来设置 "price"。
    // 如果 discount 为 true，价格应该是 $17，否则是 $20：
    const price: u8 = if ???;

    std.debug.print("With the discount, the price is ${}.\n", .{price});
}
