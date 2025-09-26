//
// 你可以用 `defer` 语句指定一些代码，
// 让它在某个代码块退出之后再运行：
//
//     {
//         defer runLater();
//         runNow();
//     }
//
// 在上面的例子中，runLater() 会在代码块 ({...}) 结束时执行。
// 所以上面的代码会按以下顺序运行：
//
//     runNow();
//     runLater();
//
// 这个特性一开始看起来有点奇怪，
// 但在下一个练习里我们会看到它的实际用途。
const std = @import("std");

pub fn main() void {
    // 在不改变其他内容的情况下，请在这段代码里加上一个 `defer` 语句，
    // 使得程序输出 "One Two\n"：
    std.debug.print("Two\n", .{});
    std.debug.print("One ", .{});
}
