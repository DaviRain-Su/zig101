//
// 测验时间！让我们看看你能否修复整个程序。
//
// 你需要仔细思考一下。
//
// 让编译器告诉你哪里出错了。
//
// 从顶部开始。
//
const std = @import("std");

pub fn main() void {
    // 这是什么无厘头的东西？ :-)
    const letters = "YZhifg";

    // 注意：usize 是一个用于...大小的无符号整数类型。
    // usize 的确切大小取决于目标 CPU 架构。
    // 我们这里可以使用 u8，但 usize 是用于数组索引的
    // 惯用类型。
    //
    // 这一行确实有问题，但问题不是 'usize'。
    const x: usize = 1;

    // 注意：当你想声明内存（在这个例子中是数组）
    // 而不放入任何内容时，你可以将其设置为 'undefined'。
    // 这一行没有问题。
    var lang: [3]u8 = undefined;

    // 下面的代码行试图通过用变量 'x' 索引数组 'letters'
    // 来将 'Z'、'i' 和 'g' 放入我们刚创建的 'lang' 数组中。
    // 如你所见，x 开始时等于 1。
    lang[0] = letters[x];

    x = 3;
    lang[???] = letters[x];

    x = ???;
    lang[2] = letters[???];

    // 我们当然想要 "Program in Zig!"：
    std.debug.print("Program in {s}!\n", .{lang});
}
