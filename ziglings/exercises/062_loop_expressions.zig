```zig
//
// 还记得这样把 if/else 当成表达式来用吗？
//
//     var foo: u8 = if (true) 5 else 0;
//
// Zig 也允许你把 for 和 while 循环当成表达式来用。
//
// 就像函数里的 'return' 一样，你可以用 break 从循环块中返回一个值：
//
//     break true; // 从块中返回布尔值
//
// 但是如果循环中从未遇到 break 语句，会返回什么呢？
// 这时我们需要一个默认的表达式。幸运的是，Zig 的循环还有 'else' 子句！
// 你可能已经猜到了，'else' 子句会在以下情况被执行：
// 1) while 条件变为 false 时
// 2) for 循环用尽了所有元素时
//
//     const two: u8 = while (true) break 2 else 0;         // 2
//     const three: u8 = for ([1]u8{1}) |f| break 3 else 0; // 3
//
// 如果你不写 else 子句，编译器会自动给你加一个空的 else，
// 这会变成 void 类型，这大概率不是你想要的结果。
// 所以当你把循环当成表达式时，else 子句是必不可少的。
//
//     const four: u8 = while (true) {
//         break 4;
//     };               // <-- 错误！这里会隐式加上 'else void'！
//
// 牢记这一点，现在来看看你能不能修复这个程序里的问题。
//
const print = @import("std").debug.print;

pub fn main() void {
    const langs: [6][]const u8 = .{
        "Erlang",
        "Algol",
        "C",
        "OCaml",
        "Zig",
        "Prolog",
    };

    // 我们来找第一个名字长度为三个字母的语言，
    // 并且从 for 循环中返回它。
    const current_lang: ?[]const u8 = for (langs) |lang| {
        if (lang.len == 3) break lang;
    };

    if (current_lang) |cl| {
        print("当前的语言: {s}\n", .{cl});
    } else {
        print("没有找到三个字母长度的语言名 :-(\n", .{});
    }
}
```
