//
// 小测验。看看你能不能让这个程序运行成功！
//
// 用任何你喜欢的方法解决，
// 只要确保输出结果是：
//
//     my_num=42
//
const std = @import("std");

const NumError = error{IllegalNumber};

pub fn main() void {
    var stdout = std.fs.File.stdout().writer(&.{});

    const my_num: u32 = getNumber();

    try stdout.interface.print("my_num={}\n", .{my_num});
}

// 这个函数显然有点怪异，而且不太“实用”。
// 但是在这个测验里你 **不能修改它**。
fn getNumber() NumError!u32 {
    if (false) return NumError.IllegalNumber;
    return 42;
}
