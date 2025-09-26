//
// 好消息！现在我们已经学到足够的知识，
// 可以理解 Zig 里一个“真正的” Hello World 程序了 ——
// 它使用了系统的标准输出 (Standard Out) 资源……而且它可能会失败！
//
const std = @import("std");

// 注意，这里 main() 的定义返回的是 "!void" 而不仅仅是 "void"。
// 由于没有指定具体的错误类型，这意味着 Zig 会自动推断错误类型。
// 在 main() 这种场景里这是合适的，
// 但在某些情况下可能会让函数变得更难处理（比如函数指针），
// 甚至在某些情况下无法使用（比如递归）。
//
// 你可以在这里找到更多信息：
// https://ziglang.org/documentation/master/#Inferred-Error-Sets
//
pub fn main() !void {
    // 我们获取一个标准输出 (Standard Out) 的 Writer，
    // 这样就可以用它的 print() 来输出内容。
    var stdout = std.fs.File.stdout().writer(&.{});

    // 和 std.debug.print() 不同，
    // 标准输出的 writer 可能会返回错误。
    // 我们并不关心具体是哪种错误，
    // 只需要把它往上层传递，作为 main() 的返回值即可。
    //
    // 我们刚刚学过一句语句，正好能完成这个任务。
    stdout.interface.print("Hello world!\n", .{});
}
