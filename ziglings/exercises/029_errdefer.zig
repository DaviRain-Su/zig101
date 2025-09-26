//
// 一个常见的问题是：一段代码可能会因为错误而从多个地方退出 ——
// 但在退出之前，它需要执行一些操作（通常是清理工作）。
//
// `errdefer` 是一种特殊的 `defer`，它只会在代码块
// 因为错误退出时才运行：
//
//     {
//         errdefer cleanup();
//         try canFail();
//     }
//
// 在上面的例子中，只有当 canFail() 产生错误时，
// cleanup() 函数才会被调用。
//
const std = @import("std");

var counter: u32 = 0;

const MyErr = error{ GetFail, IncFail };

pub fn main() void {
    // 如果获取数字失败，我们就直接退出整个程序：
    const a: u32 = makeNumber() catch return;
    const b: u32 = makeNumber() catch return;

    std.debug.print("Numbers: {}, {}\n", .{ a, b });
}

fn makeNumber() MyErr!u32 {
    std.debug.print("Getting number...", .{});

    // 请让 "failed" 消息只在 makeNumber()
    // 函数因为错误退出时才打印：
    std.debug.print("failed!\n", .{});

    var num = try getNumber(); // <-- 这里可能失败！

    num = try increaseNumber(num); // <-- 这里也可能失败！

    std.debug.print("got {}. ", .{num});

    return num;
}

fn getNumber() MyErr!u32 {
    // 我 *可能* 会失败……不过这次没失败！
    return 4;
}

fn increaseNumber(n: u32) MyErr!u32 {
    // 我会在你第二次运行我时失败！
    if (counter > 0) return MyErr.IncFail;

    // 狡猾、奇怪的全局变量操作。
    counter += 1;

    return n + 1;
}
