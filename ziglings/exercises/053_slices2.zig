//
// 你可能会想尝试在字符串上使用切片？毕竟它们只是 u8 字符数组，对吧？
// 在字符串上使用切片当然是可行的。
// 不过有一个小陷阱：不要忘了 Zig 的字符串字面量是不可变（const）的值。
// 所以我们需要把切片的类型从：
//
//     var foo: []u8 = "foobar"[0..3];
//
// 改成：
//
//     var foo: []const u8 = "foobar"[0..3];
//
// 来试试你能不能修复这个受《Zero Wing》启发的乱序短语解码器：
const std = @import("std");

pub fn main() void {
    const scrambled = "great base for all your justice are belong to us";

    const base1: []u8 = scrambled[15..23];
    const base2: []u8 = scrambled[6..10];
    const base3: []u8 = scrambled[32..];
    printPhrase(base1, base2, base3);

    const justice1: []u8 = scrambled[11..14];
    const justice2: []u8 = scrambled[0..5];
    const justice3: []u8 = scrambled[24..31];
    printPhrase(justice1, justice2, justice3);

    std.debug.print("\n", .{});
}

fn printPhrase(part1: []u8, part2: []u8, part3: []u8) void {
    std.debug.print("'{s} {s} {s}.' ", .{ part1, part2, part3 });
}
