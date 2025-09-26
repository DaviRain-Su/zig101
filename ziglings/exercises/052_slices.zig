//
// 我们已经看到传递数组有点麻烦。也许你还记得在 quiz3 中出现过一个非常可怕的函数定义？
// 这个函数只能接受长度**恰好为 4**的数组！
//
//     fn printPowersOfTwo(numbers: [4]u16) void { ... }
//
// 这就是数组的问题 —— 它们的大小是数据类型的一部分，必须在每次使用时都硬编码进去。
// 比如这个 digits 数组，它将永远是一个 [10]u8：
//
//     var digits = [10]u8{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 };
//
// 幸运的是，Zig 有切片（slice），它可以让你动态地指向一个起始元素并提供一个长度。
// 下面是 digits 数组的一些切片：
//
//     const foo = digits[0..1];  // 0
//     const bar = digits[3..9];  // 3 4 5 6 7 8
//     const baz = digits[5..9];  // 5 6 7 8
//     const all = digits[0..];   // 0 1 2 3 4 5 6 7 8 9
//
// 如你所见，一个切片 [x..y] 从索引 x 开始，到 y-1 结束。你可以省略 y 来表示“直到最后”。
//
// 对于 u8 数组的切片，它的类型是 []u8。
//
const std = @import("std");

pub fn main() void {
    var cards = [8]u8{ 'A', '4', 'K', '8', '5', '2', 'Q', 'J' };

    // 请把前 4 张牌放到 hand1，剩下的放到 hand2。
    const hand1: []u8 = cards[???];
    const hand2: []u8 = cards[???];

    std.debug.print("Hand1: ", .{});
    printHand(hand1);

    std.debug.print("Hand2: ", .{});
    printHand(hand2);
}

// 请给这个函数一个帮手参数 —— 一个 u8 切片 hand。
fn printHand(hand: ???) void {
    for (hand) |h| {
        std.debug.print("{u} ", .{h});
    }
    std.debug.print("\n", .{});
}
//
// 趣味小知识：在底层，切片实际上存储的是一个指向第一个元素的指针和一个长度。
