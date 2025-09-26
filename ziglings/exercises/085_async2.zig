//
// 所以，'suspend' 会把控制权返回到调用它的位置（“调用点”）。
// 那么我们该如何把控制权交还给被挂起的函数呢？
//
// 为此，Zig 提供了一个新的关键字 'resume'，它接收一个
// 异步函数调用的栈帧，并将控制权重新交还给它。
//
//     fn fooThatSuspends() void {
//         suspend {}
//     }
//
//     var foo_frame = async fooThatSuspends();
//     resume foo_frame;
//
// 试试看你能否让这个程序输出 "Hello async!"。
//
const print = @import("std").debug.print;

pub fn main() void {
    var foo_frame = async foo();
}

fn foo() void {
    print("Hello ", .{});
    suspend {}
    print("async!\n", .{});
}
