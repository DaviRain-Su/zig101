//
// 既然你已经知道 `defer` 的用法，
// 那么我们来做一些更有趣的事情吧。
//
const std = @import("std");

pub fn main() void {
    const animals = [_]u8{ 'g', 'c', 'd', 'd', 'g', 'z' };

    for (animals) |a| printAnimal(a);

    std.debug.print("done.\n", .{});
}

// 这个函数**本来应该**打印一个动物名字并加上括号，
// 比如 "(Goat) "。
// 但是我们必须在函数能从四个不同位置 `return` 的情况下，
// 依然保证右括号能被打印出来！
fn printAnimal(animal: u8) void {
    std.debug.print("(", .{});

    std.debug.print(") ", .{}); // <---- 怎么做到的呢？！

    if (animal == 'g') {
        std.debug.print("Goat", .{});
        return;
    }
    if (animal == 'c') {
        std.debug.print("Cat", .{});
        return;
    }
    if (animal == 'd') {
        std.debug.print("Dog", .{});
        return;
    }

    std.debug.print("Unknown", .{});
}
