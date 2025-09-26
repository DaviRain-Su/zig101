//
// 信不信由你，有时候程序会出错。
//
// 在 Zig 中，错误 (error) 本质上也是一个值。
// 错误会有名字，用来标识可能出现的问题。
// 错误是通过 “错误集合 (error set)” 创建的，
// 它就是一组已命名的错误。
//
// 我们这里已经开始定义一个错误集合，
// 但是缺少了一个条件 "TooSmall"。
// 请在需要的地方补充它！
const MyNumberError = error{
    TooBig,
    ???,
    TooFour,
};

const std = @import("std");

pub fn main() void {
    const nums = [_]u8{ 2, 3, 4, 5, 6 };

    for (nums) |n| {
        std.debug.print("{}", .{n});

        const number_error = numberFail(n);

        if (number_error == MyNumberError.TooBig) {
            std.debug.print(">4. ", .{});
        }
        if (???) {
            std.debug.print("<4. ", .{});
        }
        if (number_error == MyNumberError.TooFour) {
            std.debug.print("=4. ", .{});
        }
    }

    std.debug.print("\n", .{});
}

// 注意：这个函数的返回值可以是 MyNumberError 错误集合中的任意成员。
fn numberFail(n: u8) MyNumberError {
    if (n > 4) return MyNumberError.TooBig;
    if (n < 4) return MyNumberError.TooSmall; // <---- 这个条件已经帮你写好了！
    return MyNumberError.TooFour;
}
