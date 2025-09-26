//
// 使用 `catch` 把错误替换为默认值有点粗暴，
// 因为它完全不关心到底是哪种错误。
//
// `catch` 还允许我们捕获错误的值，
// 并基于不同的错误执行额外的操作，写法如下：
//
//     canFail() catch |err| {
//         if (err == FishError.TunaMalfunction) {
//             ...
//         }
//     };
//
const std = @import("std");

const MyNumberError = error{
    TooSmall,
    TooBig,
};

pub fn main() void {
    // 下面的 "catch 0" 是个临时方案，
    // 用来处理 makeJustRight() 返回的错误联合（暂时的）。
    const a: u32 = makeJustRight(44) catch 0;
    const b: u32 = makeJustRight(14) catch 0;
    const c: u32 = makeJustRight(4) catch 0;

    std.debug.print("a={}, b={}, c={}\n", .{ a, b, c });
}

// 在这个搞笑的例子里，我们把“让数字刚刚好”的责任
// 分拆成了四（！）个函数：
//
//     makeJustRight()   调用 fixTooBig()，本身不能修复任何错误。
//     fixTooBig()       调用 fixTooSmall()，修复 TooBig 错误。
//     fixTooSmall()     调用 detectProblems()，修复 TooSmall 错误。
//     detectProblems()  返回数字或错误。
//
fn makeJustRight(n: u32) MyNumberError!u32 {
    return fixTooBig(n) catch |err| {
        return err;
    };
}

fn fixTooBig(n: u32) MyNumberError!u32 {
    return fixTooSmall(n) catch |err| {
        if (err == MyNumberError.TooBig) {
            return 20;
        }

        return err;
    };
}

fn fixTooSmall(n: u32) MyNumberError!u32 {
    // 哎呀，这里漏了好多！不过别担心，
    // 它和上面的 fixTooBig() 基本一样。
    //
    // 如果遇到 TooSmall 错误，我们应该返回 10。
    // 如果遇到其他错误，我们应该返回该错误。
    // 否则，我们返回这个 u32 数字。
    return detectProblems(n) ???;
}

fn detectProblems(n: u32) MyNumberError!u32 {
    if (n < 10) return MyNumberError.TooSmall;
    if (n > 20) return MyNumberError.TooBig;
    return n;
}
