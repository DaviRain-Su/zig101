//
// 你可能已经注意到，我们不再从 foo() 中捕获返回值，
// 因为 'async' 关键字返回的是函数帧（frame）。
//
// 解决这个问题的一种方式是使用全局变量。
//
// 试试看你能否让这个程序输出 "1 2 3 4 5"。
//
const print = @import("std").debug.print;

var global_counter: i32 = 0;

pub fn main() void {
    var foo_frame = async foo();

    while (global_counter <= 5) {
        print("{} ", .{global_counter});
        ???
    }

    print("\n", .{});
}

fn foo() void {
    while (true) {
        ???
        ???
    }
}
