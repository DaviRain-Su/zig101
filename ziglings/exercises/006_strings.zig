//
// 现在我们已经学习了数组，可以讨论字符串了。
//
// 我们已经见过 Zig 字符串字面量："Hello world.\n"
//
// Zig 将字符串存储为字节数组。
//
//     const foo = "Hello";
//
// 几乎*等同于：
//
//     const foo = [_]u8{ 'H', 'e', 'l', 'l', 'o' };
//
// (* 我们将在练习 77 中看到 Zig 字符串的真正本质。)
//
// 注意单个字符使用单引号（'H'），而字符串使用双引号（"H"）。
// 这两者不能互换！
//
const std = @import("std");

pub fn main() void {
    const ziggy = "stardust";

    // (问题 1)
    // 使用数组方括号语法从上面的字符串 "stardust" 中获取字母 'd'。
    const d: u8 = ziggy[???];

    // (问题 2)
    // 使用数组重复操作符 '**' 来创建 "ha ha ha "。
    const laugh = "ha " ???;

    // (问题 3)
    // 使用数组连接操作符 '++' 来创建 "Major Tom"。
    // (你还需要添加一个空格！)
    const major = "Major";
    const tom = "Tom";
    const major_tom = major ??? tom;

    // 这就是所有的问题。让我们看看结果：
    std.debug.print("d={u} {s}{s}\n", .{ d, laugh, major_tom });
    // 细心的人会注意到我们在上面格式字符串的 '{}' 占位符中
    // 放入了 'u' 和 's'。这告诉 print() 函数分别将值格式化为
    // UTF-8 字符和 UTF-8 字符串。如果我们不这样做，我们会看到 '100'，
    // 这是 UTF-8 中与 'd' 字符对应的十进制数。
    // (在字符串的情况下会出现错误。)
    //
    // 既然谈到这个话题，'c'（ASCII 编码字符）可以代替 'u' 使用，
    // 因为 UTF-8 的前 128 个字符与 ASCII 相同！
    //
}
