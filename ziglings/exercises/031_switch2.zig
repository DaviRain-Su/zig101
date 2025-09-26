//
// 更棒的是，你可以把 `switch` 语句当作一个**表达式**来使用，
// 直接返回一个值。
//
//     const a = switch (x) {
//         1 => 9,
//         2 => 16,
//         3 => 7,
//         ...
//     }
//
const std = @import("std");

pub fn main() void {
    const lang_chars = [_]u8{ 26, 9, 7, 42 };

    for (lang_chars) |c| {
        const real_char: u8 = switch (c) {
            1 => 'A',
            2 => 'B',
            3 => 'C',
            4 => 'D',
            5 => 'E',
            6 => 'F',
            7 => 'G',
            8 => 'H',
            9 => 'I',
            10 => 'J',
            // ...
            25 => 'Y',
            26 => 'Z',
            // 和上一个练习一样，请在这里加上 "else" 分支。
            // 这次要求返回一个感叹号 '!'。
        };

        std.debug.print("{c}", .{real_char});
        // 注意："{c}" 会强制 print() 把值当作字符显示。
        // 你能猜到如果去掉 "c" 会发生什么吗？试试看！
    }

    std.debug.print("\n", .{});
}
