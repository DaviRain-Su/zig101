//
// Zig 有一些有趣的数组操作符。
//
// 你可以使用 '++' 来连接两个数组：
//
//   const a = [_]u8{ 1,2 };
//   const b = [_]u8{ 3,4 };
//   const c = a ++ b ++ [_]u8{ 5 }; // 等于 1 2 3 4 5
//
// 你可以使用 '**' 来重复一个数组：
//
//   const d = [_]u8{ 1,2,3 } ** 2; // 等于 1 2 3 1 2 3
//
// 注意，'++' 和 '**' 都只在程序_编译时_对数组进行操作。
// 这个特殊时间在 Zig 术语中被称为"comptime"（编译时），
// 我们稍后会学习更多相关内容。
//
const std = @import("std");

pub fn main() void {
    const le = [_]u8{ 1, 3 };
    const et = [_]u8{ 3, 7 };

    // (问题 1)
    // 请设置这个数组，连接上面的两个数组。
    // 结果应该是：1 3 3 7
    const leet = ???;

    // (问题 2)
    // 请使用重复操作设置这个数组。
    // 结果应该是：1 0 0 1 1 0 0 1 1 0 0 1
    const bit_pattern = [_]u8{ ??? } ** 3;

    // 好了，这就是所有的问题。让我们看看结果。
    //
    // 我们可以用 leet[0], leet[1],... 来打印这些数组，
    // 但让我们先预览一下 Zig 的 'for' 循环：
    //
    //    for (<item array>) |item| { <对 item 做一些操作> }
    //
    // 别担心，我们会在接下来的课程中正确地介绍循环。
    //
    std.debug.print("LEET: ", .{});

    for (leet) |n| {
        std.debug.print("{}", .{n});
    }

    std.debug.print(", Bits: ", .{});

    for (bit_pattern) |n| {
        std.debug.print("{}", .{n});
    }

    std.debug.print("\n", .{});
}
