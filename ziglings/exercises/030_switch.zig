//
// `switch` 语句可以让你根据表达式的不同值，执行不同的操作。
//
// 这个 switch：
//
//     switch (players) {
//         1 => startOnePlayerGame(),
//         2 => startTwoPlayerGame(),
//         else => {
//             alert();
//             return GameError.TooManyPlayers;
//         }
//     }
//
// 等价于下面的 if/else：
//
//     if (players == 1) startOnePlayerGame();
//     else if (players == 2) startTwoPlayerGame();
//     else {
//         alert();
//         return GameError.TooManyPlayers;
//     }
//
const std = @import("std");

pub fn main() void {
    const lang_chars = [_]u8{ 26, 9, 7, 42 };

    for (lang_chars) |c| {
        switch (c) {
            1 => std.debug.print("A", .{}),
            2 => std.debug.print("B", .{}),
            3 => std.debug.print("C", .{}),
            4 => std.debug.print("D", .{}),
            5 => std.debug.print("E", .{}),
            6 => std.debug.print("F", .{}),
            7 => std.debug.print("G", .{}),
            8 => std.debug.print("H", .{}),
            9 => std.debug.print("I", .{}),
            10 => std.debug.print("J", .{}),
            // ... 中间的就不需要全部写了 ...
            25 => std.debug.print("Y", .{}),
            26 => std.debug.print("Z", .{}),
            // switch 语句必须是“穷尽的”（即必须覆盖所有可能的值）。
            // 请在这里加上一个 "else" 分支，
            // 当 c 不是上述匹配值之一时，打印一个问号 "?"。
        }
    }

    std.debug.print("\n", .{});
}
