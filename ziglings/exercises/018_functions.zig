//
// 函数！我们之前已经写过很多名为 `main()` 的函数了。
// 现在我们来做点不一样的：
//
//     fn foo(n: u8) u8 {
//         return n + 1;
//     }
//
// 上面的 foo() 函数接受一个数字 `n`，并返回比它大 1 的数字。
//
// 注意：输入参数 `n` 和返回值的类型都是 u8。
//
const std = @import("std");

pub fn main() void {
    // 新的函数 deepThought() 应该返回数字 42。见下方。
    const answer: u8 = deepThought();

    std.debug.print("Answer to the Ultimate Question: {}\n", .{answer});
}

// 请在下面定义 deepThought() 函数。
//
// 我们只缺少了几个部分。这里不需要使用关键字 "pub"。
// 你能猜到为什么吗？
//
??? deepThought() ??? {
    return 42; // 数字取自 Douglas Adams
}
