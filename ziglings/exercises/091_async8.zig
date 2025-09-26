//
// 你肯定已经注意到 `suspend` 需要一个代码块表达式，例如：
//
//     suspend {}
//
// 这个 suspend 块会在函数挂起时执行。
// 为了理解它什么时候发生，请让下面的程序打印出：
//
//     "ABCDEF"
//
const print = @import("std").debug.print;

pub fn main() void {
    print("A", .{});

    var frame = async suspendable();

    print("X", .{});

    resume frame;

    print("F", .{});
}

fn suspendable() void {
    print("X", .{});

    suspend {
        print("X", .{});
    }

    print("X", .{});
}
