//
// Zig 里还有一个 `inline while`。
// 就像 `inline for` 一样，它在编译期循环，
// 可以让你做一些运行时完全无法做到的有趣事情。
// 来看看这个有点疯狂的例子会打印什么：
//
//     const foo = [3]*const [5]u8{ "~{s}~", "<{s}>", "d{s}b" };
//     comptime var i = 0;
//
//     inline while ( i < foo.len ) : (i += 1) {
//         print(foo[i] ++ "\n", .{foo[i]});
//     }
//
// 你还没摘掉那顶魔法师的帽子吧？
//
const print = @import("std").debug.print;

pub fn main() void {
    // 这里有一个字符串，里面包含一系列算术操作
    // 和个位十进制数字。我们把每一个操作符和数字对
    // 称为一条“指令”。
    const instructions = "+3 *5 -2 *2";

    // 这里有一个 u32 变量，用来在运行时跟踪当前值。
    // 它从 0 开始，我们会通过依次执行上面字符串中的
    // 指令来得到最终的值。
    var value: u32 = 0;

    // 这个 “index” 变量只会在编译期的循环中使用。
    comptime var i = 0;

    // 这里我们想在编译期循环遍历字符串中的每一条“指令”。
    //
    // 请修复这里，让它能对每条“指令”循环一次：
    ??? (i < instructions.len) : (???) {

        // 这里从“指令”中取出数字。你能想明白
        // 为什么要减去字符 '0' 吗？
        const digit = instructions[i + 1] - '0';

        // 这个 `switch` 语句在运行时完成实际的操作。
        // 乍一看好像没什么特别的……
        switch (instructions[i]) {
            '+' => value += digit,
            '-' => value -= digit,
            '*' => value *= digit,
            else => unreachable,
        }
        // ……但它比乍看之下要有意思得多。
        // `inline while` 在运行时已经不存在了，
        // 任何没有直接被运行时代码触及的东西也都会消失。
        // 比如说，这个 `instructions` 字符串，
        // 它在编译后的程序里完全不会出现，
        // 因为它没有被用到！
        //
        // 所以，从某种意义上说，
        // 这个循环实际上是在 **编译期** 把字符串里的指令
        // 转换成了运行时代码。
        // 看吧？我们现在成编译器工程师了。
        // 那顶魔法师的帽子果然名副其实。
    }

    print("{}\n", .{value});
}
