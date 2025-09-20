//
// 这是一个有趣的内容：Zig 有多行字符串！
//
// 要创建多行字符串，在每行开头放置 '\\'，
// 就像代码注释一样，但使用反斜杠：
//
//     const two_lines =
//         \\Line One
//         \\Line Two
//     ;
//
// 看看你能否让这个程序打印一些歌词。
//
const std = @import("std");

pub fn main() void {
    const lyrics =
        Ziggy played guitar
        Jamming good with Andrew Kelley
        And the Spiders from Mars
    ;

    std.debug.print("{s}\n", .{lyrics});
}
