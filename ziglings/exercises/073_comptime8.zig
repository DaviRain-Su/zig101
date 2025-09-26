//
// 事实上，你可以在任何表达式前面加上 `comptime`，
// 来强制它在编译期运行。
//
// 执行一个函数：
//
//     comptime llama();
//
// 获取一个值：
//
//     bar = comptime baz();
//
// 执行整个代码块：
//
//     comptime {
//         bar = baz + biff();
//         llama(bar);
//     }
//
// 从代码块中获取一个值：
//
//     var llama = comptime bar: {
//         const baz = biff() + bonk();
//         break :bar baz;
//     }
//
const print = @import("std").debug.print;

const llama_count = 5;
const llamas = [llama_count]u32{ 5, 10, 15, 20, 25 };

pub fn main() void {
    // 我们本来是想取最后一只 llama。
    // 请修复这个简单的错误，让断言不再失败。
    const my_llama = getLlama(5);

    print("My llama value is {}.\n", .{my_llama});
}

fn getLlama(i: usize) u32 {
    // 我们在函数开头放了一个断言 assert() 来防止出错。
    // 这里使用 `comptime` 关键字，意味着这个错误会在 **编译期**
    // 被捕获！
    //
    // 如果没有 `comptime`，这段代码依然可以运行，
    // 但断言会在运行时失败并触发 PANIC，
    // 体验就没那么好了。
    //
    // 不幸的是，现在我们会遇到一个错误，
    // 因为参数 `i` 必须保证在编译期就已知。
    // 你能想到怎么修改上面的参数 `i` 来实现吗？
    comptime assert(i < llama_count);

    return llamas[i];
}

// 趣味知识：这个 assert() 函数和 Zig 标准库里的
// std.debug.assert() 完全相同。
fn assert(ok: bool) void {
    if (!ok) unreachable;
}
//
// 额外趣味知识：我不小心把所有的 'foo' 都换成了 'llama'，
// 但我一点都不后悔！
