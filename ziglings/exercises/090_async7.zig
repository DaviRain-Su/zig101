//
// 记得吗？一个带有 'suspend' 的函数就是异步函数，
// 而调用一个异步函数时如果没有加上 'async' 关键字，
// 会让 **调用它的函数** 也变成异步的。
//
//     fn fooThatMightSuspend(maybe: bool) void {
//         if (maybe) suspend {}
//     }
//
//     fn bar() void {
//         fooThatMightSuspend(true); // 现在 bar() 变成异步的了！
//     }
//
// 但是如果你 **确定** 这个函数不会挂起，
// 你可以用 `nosuspend` 关键字向编译器作出承诺：
//
//     fn bar() void {
//         nosuspend fooThatMightSuspend(false);
//     }
//
// 如果函数确实挂起了，而你对编译器的承诺被打破了，
// 程序会在运行时触发 panic。
// （老实说，这是对你这种“誓言破坏者”最仁慈的惩罚了！ >:-( ）
//
const print = @import("std").debug.print;

pub fn main() void {

    // main() 函数不能是异步的。
    // 但我们知道这次调用 getBeef() 不会挂起。
    // 请让它合法化：
    var my_beef = getBeef(0);

    print("beef? {X}!\n", .{my_beef});
}

fn getBeef(input: u32) u32 {
    if (input == 0xDEAD) {
        suspend {}
    }

    return 0xBEEF;
}
//
// 更深入一点...
//                     ...关于 **未定义行为（Undefined Behavior, UB）**！
//
// 我们之前没提到过，运行时的“安全检查”其实会让编译出的程序多一些额外的指令。
// 大多数情况下，你都应该保留这些检查。
//
// 但是在某些场景下，当数据正确性不如运行速度重要时（比如某些游戏），
// 你可以在编译时关闭这些安全功能。
//
// 这时候，当出现问题时，程序不会触发安全的 panic，
// 而是会表现出 **未定义行为（UB）**。
// 这意味着 Zig 语言无法（也不能）定义会发生什么。
// 最好的情况是程序崩溃，
// 最糟的情况是程序继续运行，但结果错误，
// 并且可能损坏数据或带来安全隐患。
//
// 这个程序就是探索 UB 的好例子。
// 一旦你让它运行起来，试试用参数 `0xDEAD` 调用 getBeef()：
//
//     getBeef(0xDEAD)
//
// 这样它就会触发 `suspend`。
// 当你运行时，程序会 panic，并给出漂亮的调用栈，帮助你调试问题：
//
//     zig run exercises/090_async7.zig
//     thread 328 panic: async function called...
//     ...
//
// 但看看当你关闭安全检查，用 **ReleaseFast 模式** 运行时会发生什么：
//
//     zig run -O ReleaseFast exercises/090_async7.zig
//     beef? 0!
//
// 这是错误的结果。
// 在你的电脑上可能会得到不同的结果，或者直接崩溃！
// 到底会发生什么是 **未定义的**。
//
// 你的计算机现在就像一头野兽，
// 仅凭 CPU 的本能在处理内存里的比特和字节。
// 既令人恐惧，又让人兴奋。
