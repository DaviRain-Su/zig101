//
// 看哪！这是 `for` 循环！
// `for` 循环可以让你针对数组中的每一个元素执行代码：
//
//     for (items) |item| {
//
//         // 对 item 做一些操作
//
//     }
//
const std = @import("std");

pub fn main() void {
    const story = [_]u8{ 'h', 'h', 's', 'n', 'h' };

    std.debug.print("A Dramatic Story: ", .{});

    for (???) |???| {
        if (scene == 'h') std.debug.print(":-)  ", .{});
        if (scene == 's') std.debug.print(":-(  ", .{});
        if (scene == 'n') std.debug.print(":-|  ", .{});
    }

    std.debug.print("The End.\n", .{});
}

// 注意：`for` 循环同样可以用于一种叫做 “切片 (slice)” 的东西，
// 我们稍后会看到它。
//
// 另外需要注意的是：在这份练习写成的两年后，
// Zig 的 `for` 循环变得更灵活、更强大了。
// 稍后我们会介绍更多内容。
