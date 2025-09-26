//
// 六个事实：
//
// 1. 为程序中函数调用及其所有数据分配的内存空间称为
//    “栈帧”(stack frame)。
//
// 2. 'return' 关键字会“弹出”当前函数调用的栈帧（不再需要），
//    并将控制权返回到调用该函数的位置。
//
//     fn foo() void {
//         return; // 弹出栈帧并返回控制权
//     }
//
// 3. 与 'return' 不同，'suspend' 关键字会把控制权返回到
//    调用函数的位置，但当前函数调用的栈帧会保留，
//    以便之后再次恢复控制权。这样做的函数称为 "async"
//    （异步）函数。
//
//     fn fooThatSuspends() void {
//         suspend {} // 返回控制权，但保留栈帧
//     }
//
// 4. 在异步上下文中调用函数并获取它的栈帧引用以便之后使用，
//    使用 'async' 关键字：
//
//     var foo_frame = async fooThatSuspends();
//
// 5. 如果调用一个异步函数时没有加上 'async' 关键字，
//    那么调用该异步函数的函数本身也会变成异步函数！
//    在下面的例子中，bar() 因为调用了 fooThatSuspends()
//    （它是异步函数），所以 bar() 也变成了异步函数。
//
//     fn bar() void {
//         fooThatSuspends();
//     }
//
// 6. main() 函数不能是异步的！
//
// 已知事实 3 和 4，如何修复下面因为事实 5 和 6 而出错的程序？
//
const print = @import("std").debug.print;

pub fn main() void {
    // 额外提示：当你不打算使用某个值时，可以把它赋给 '_'。
    foo();
}

fn foo() void {
    print("foo() A\n", .{});
    suspend {}
    print("foo() B\n", .{});
}
