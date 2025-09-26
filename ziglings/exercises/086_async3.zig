//
// 因为可以挂起和恢复，Zig 的 async 函数是一个更通用的编程
// 概念——“协程”（coroutines）的例子。Zig 的 async 函数有一个
// 很酷的特点，就是在挂起和恢复时会保留它们的状态。
//
// 试试看你能否让这个程序输出 "5 4 3 2 1"。
//
const print = @import("std").debug.print;

pub fn main() void {
    const n = 5;
    var foo_frame = async foo(n);

    ???

    print("\n", .{});
}

fn foo(countdown: u32) void {
    var current = countdown;

    while (current > 0) {
        print("{} ", .{current});
        current -= 1;
        suspend {}
    }
}
