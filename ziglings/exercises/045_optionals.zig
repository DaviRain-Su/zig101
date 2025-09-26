//
// 有时候你会知道一个变量可能有值，也可能没有值。
// Zig 有一个很巧妙的方式来表达这个概念 —— **可选值 (Optionals)**。
// 可选类型只需要在类型前面加一个 `?`，比如：
//
//     var foo: ?u32 = 10;
//
// 现在 foo 可以存储一个 u32 整数 **或者** null
// （一个代表“值不存在”这种宇宙恐怖的特殊值！）
//
//     foo = null;
//
//     if (foo == null) beginScreaming();
//
// 在我们把可选值当成非 null 类型（比如这里的 u32 整数）来使用之前，
// 我们需要保证它不是 null。
// 一种方法是用 `orelse` 来“威胁”它。
//
//     var bar = foo orelse 2;
//
// 在这里，bar 要么等于 foo 里存储的 u32 整数值，
// 要么等于 2（如果 foo 是 null）。
//
const std = @import("std");

pub fn main() void {
    const result = deepThought();

    // 请“威胁” result，使得 answer 要么等于 deepThought() 的整数值，
    // 要么等于 42：
    const answer: u8 = result;

    std.debug.print("The Ultimate Answer: {}.\n", .{answer});
}

fn deepThought() ?u8 {
    // 看起来“深思”号的输出质量下降了。
    // 但我们还是保持原样。抱歉啦，深思。
    return null;
}

// 来自过去的提示：
//
// 可选值 (Optionals) 很像 错误联合类型 (error union types)，
// 它们可以保存一个值，或者保存一个错误。
// 同样，`orelse` 语句也很像 `catch` 语句 —— 都用来“解包”一个值，
// 或者在失败时提供一个默认值：
//
//    var maybe_bad: Error!u32 = Error.Evil;
//    var number: u32 = maybe_bad catch 0;
//
