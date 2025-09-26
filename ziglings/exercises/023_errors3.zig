//
// 处理错误联合 (error union) 的一种方式是使用 `catch`：
// 捕获任何错误，并用一个默认值来替代它。
//
//     foo = canFail() catch 6;
//
// 如果 canFail() 失败了，foo 就会等于 6。
//
const std = @import("std");

const MyNumberError = error{TooSmall};

pub fn main() void {
    const a: u32 = addTwenty(44) catch 22;
    const b: u32 = addTwenty(4) ??? 22;

    std.debug.print("a={}, b={}\n", .{ a, b });
}

// 请为这个函数补充正确的返回类型。
// 提示：它应该是一个错误联合 (error union)。
fn addTwenty(n: u32) ??? {
    if (n < 5) {
        return MyNumberError.TooSmall;
    } else {
        return n + 20;
    }
}
