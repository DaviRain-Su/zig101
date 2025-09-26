//
// 通常情况下，C 函数会被用在 Zig 里还没有等效函数的地方。
// 好吧，这种情况正在变得越来越少了。 ;-)
//
// 由于在 Zig 中集成 C 函数非常简单（上一练习已经演示过），
// 所以我们自然可以利用 C 标准库里大量的函数为我们的程序服务。
// 举个例子：
//
// 假设我们有一个角度值 765.2 度。
// 如果想把它归一化（normalize），就需要减去 X * 360 度，
// 从而得到正确的角度。
// 我们该怎么做呢？一个好方法就是用取模函数。
// 但是如果直接写 "765.2 % 360"，它只对编译期已知的浮点数有效。
// 在 Zig 里，应该使用 @mod(a, b)。
//
// 现在我们假设在 Zig 中做不到，而只能用 C 标准库里的函数。
// 在 "math" 库里有一个函数叫 "fmod"；其中 "f" 代表浮点数，
// 表示我们可以对实数做取模运算。
// 使用这个函数，就可以把角度归一化了。
// 让我们开始吧。
//

const std = @import("std");

const c = @cImport({
    // 我们需要引入什么？
    @cInclude("math.h");
});

pub fn main() !void {
    const angle = 765.2;
    const circle = 360;

    // 这里我们调用 C 函数 'fmod' 来得到归一化的角度。
    const result = c.fmod(angle, circle);

    // 我们用格式化器来设置所需的精度，并截断小数位
    std.debug.print("The normalized angle of {d: >3.1} degrees is {d: >3.1} degrees.\n", .{ angle, result });
}
