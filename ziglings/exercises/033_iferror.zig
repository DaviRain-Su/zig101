//
// 我们再回顾一下第一个错误处理练习。
// 这次，我们要看看 `if` 语句的一种错误处理变体。
//
//     if (foo) |value| {
//
//         // foo 不是错误；value 是 foo 的非错误值
//
//     } else |err| {
//
//         // foo 是错误；err 是 foo 的错误值
//
//     }
//
// 我们还可以更进一步，结合 `switch` 语句来处理错误类型。
//
//     if (foo) |value| {
//         ...
//     } else |err| switch (err) {
//         ...
//     }
//
const MyNumberError = error{
    TooBig,
    TooSmall,
};

const std = @import("std");

pub fn main() void {
    const nums = [_]u8{ 2, 3, 4, 5, 6 };

    for (nums) |num| {
        std.debug.print("{}", .{num});

        const n = numberMaybeFail(num);
        if (n) |value| {
            std.debug.print("={}. ", .{value});
        } else |err| switch (err) {
            MyNumberError.TooBig => std.debug.print(">4. ", .{}),
            // 请在这里为 TooSmall 添加一个匹配，
            // 并让它打印："<4. "
        }
    }

    std.debug.print("\n", .{});
}

// 这次 numberMaybeFail() 将返回一个错误联合 (error union)，
// 而不是单纯的错误。
fn numberMaybeFail(n: u8) MyNumberError!u8 {
    if (n > 4) return MyNumberError.TooBig;
    if (n < 4) return MyNumberError.TooSmall;
    return n;
}
