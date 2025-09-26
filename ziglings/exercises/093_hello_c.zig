//
// 当 Andrew Kelley 在 2016 年 2 月 8 日的博客里宣布一种新的编程语言 —— Zig —— 时，
// 他同时也立下了雄心勃勃的目标：取代 C 语言！
//
// 为了能够实现这个目标，Zig 应该尽可能地与它的“前辈”兼容。
// 只有在不必使用复杂封装器的情况下，就能在现有的 C 程序中替换单个模块，
// 这个尝试才有成功的机会。
//
// 因此，调用 C 函数及其反向调用 Zig 都是极其“顺畅”的，这并不奇怪。
//
// 在 Zig 中调用 C 函数时，你只需要指定包含该函数的库。
// 为此，Zig 提供了一个与常见 @import() 类似的内置函数：
//
//                           @cImport()
//
// 所有需要的库都可以用 Zig 的常见语法引入：
//
//                    const c = @cImport({
//                        @cInclude("stdio.h");
//                        @cInclude("...");
//                    });
//
// 现在就可以通过常量 `c`（在本例中）来调用函数了：
//
//                    c.puts("Hello world!");
//
// 顺便一提，大多数 C 函数都有返回值，通常是整数。
// 可以用返回值来判断错误（返回 < 0），或者获取其他信息。
// 例如，`puts` 会返回输出的字符数量。
//
// 为了让这些内容不只是枯燥的理论，让我们直接在 Zig 里调用一个 C 函数吧。
//

// Zig 的常见“import”
const std = @import("std");

// 这里是新的 C import
const c = @cImport({
    @cInclude("unistd.h");
});

pub fn main() void {

    // 为了输出能被 Zig Builder 捕获的文本，我们需要把内容写到错误输出。
    // 在 Zig 中，我们用 "std.debug.print"，而在 C 中我们可以指定文件描述符，
    // 比如 2 表示错误控制台。
    //
    // 在这个练习中，我们用 `write` 输出 17 个字符，
    // 但是这里还缺少了点东西……
    const c_res = write(2, "Hello C from Zig!", 17);

    // 来看看 C 的结果：
    std.debug.print(" - C result is {d} chars written.\n", .{c_res});
}
//
// 在编译调用 C 函数的程序时，有一点必须注意。
// 那就是 Zig 编译器需要知道要链接对应的库。
// 为此我们在编译时需要带上参数 "lc"，例如：
//     zig run -lc hello_c.zig
//
