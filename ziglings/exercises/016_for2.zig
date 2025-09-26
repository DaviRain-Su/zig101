//
// `for` 循环同样允许你使用迭代的 “索引 (index)”，
// 它是一个数字，在每次迭代时递增。
// 要访问迭代的索引，你需要在 `for` 里指定第二个条件，
// 并捕获第二个值。
//
//     for (items, 0..) |item, index| {
//
//         // 对 item 和 index 做一些操作
//
//     }
//
// 你可以给 "item" 和 "index" 起任何名字。
// “i” 是 “index” 的常用缩写。
// item 名称通常是所遍历集合名的单数形式。
//
const std = @import("std");

pub fn main() void {
    // 我们来存储二进制数 1101 的各位，
    // 使用 “小端序 (little-endian)” 的顺序（最低有效位在前）：
    const bits = [_]u8{ 1, 0, 1, 1 };
    var value: u32 = 0;

    // 现在我们要把这些二进制位转换成数值，
    // 方法是：对每一位加上对应的 2 的幂次方乘以该位的值。
    //
    // 试着补全下面缺失的部分：
    for (bits, ???) |bit, ???| {
        // 注意：我们用 @intCast() 把 usize 类型的 i 转换成 u32，
        // @intCast() 和 @import() 一样，都是内建函数。
        // 我们会在后面的练习里正式学习这些。
        const i_u32: u32 = @intCast(i);
        const place_value = std.math.pow(u32, 2, i_u32);
        value += place_value * bit;
    }

    std.debug.print("The value of bits '1101': {}.\n", .{value});
}
//
// 正如上一个练习里提到的，`for` 循环在这些早期练习写成之后
// 已经获得了更多的灵活性。
// 我们会在后面的练习里看到，这种捕获索引的语法只是更通用能力的
// 一部分。请继续坚持！
//
