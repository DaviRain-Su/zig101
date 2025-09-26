//
// 有时候你需要创建一个不符合命名规则的标识符：
//
//     const 55_cows: i32 = 55; // 非法：以数字开头
//     const isn't true: bool = false; // 非法：这都啥玩意?!
//
// 如果你在正常情况下尝试创建这些标识符，
// 程序标识符语法安全小组（PISST）会跑到你家把你带走。
//
// 幸运的是，Zig 提供了一种办法能把这些古怪的标识符偷偷混进去：
// 使用 @"" 标识符引号语法。
//
//     @"foo"
//
// 请帮我们把这些“逃犯”标识符安全地走私进程序里：
//
const print = @import("std").debug.print;

pub fn main() void {
    const 55_cows: i32 = 55;
    const isn't true: bool = false;

    print("Sweet freedom: {}, {}.\n", .{
        55_cows,
        isn't true,
    });
}
