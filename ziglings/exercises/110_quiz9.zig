// ----------------------------------------------------------------------------
// 测验时间：切换、设置与清除位（Bits）
// ----------------------------------------------------------------------------
//
// Zig 另一个令人兴奋的方面是它非常适合嵌入式编程。
// 你的 Zig 代码不必只运行在笔记本电脑上；你也可以把它部署到微控制器上！
// 这意味着你可以用 Zig 来驱动你的下一个机器人或温室环境控制系统！
// 准备好进入嵌入式编程的精彩世界了吗？让我们开始吧！
//
// ----------------------------------------------------------------------------
// 一些背景知识
// ----------------------------------------------------------------------------
//
// 在微控制器编程中，一个常见的活动就是对输入/输出引脚的位进行设置与清除。
// 这让你能够控制 LED、传感器、电机等！在前面的练习
// （097_bit_manipulation.zig）里，你学过如何使用 ^（XOR——异或）运算符
// 来交换两个字节。本次小测验会在让你初尝真实微控制器寄存器控制体验的同时，
// 检验你在 Zig 中进行位操作的知识。文末还包含一些辅助函数，展示我们如何
// 让代码更易读。
//
// 下面是著名的 ATmega328 AVR 微控制器的引脚图，它是许多流行的微控平台
//（比如 Arduino UNO）的主控芯片。
//
//  ============ ATMEGA328 微控制器引脚分布图（PINOUT DIAGRAM） ============
//                                _____ _____
//                               |     U     |
//                 (RESET) PC6 --|  1     28 |-- PC5
//                         PD0 --|  2     27 |-- PC4
//                         PD1 --|  3     26 |-- PC3
//                         PD2 --|  4     25 |-- PC2
//                         PD3 --|  5     24 |-- PC1
//                         PD4 --|  6     23 |-- PC0
//                         VCC --|  7     22 |-- GND
//                         GND --|  8     21 |-- AREF
//                     |-- PB6 --|  9     20 |-- AVCC
//                     |-- PB7 --| 10     19 |-- PB5 --|
//                     |   PD5 --| 11     18 |-- PB4 --|
//                     |   PD6 --| 12     17 |-- PB3 --|
//                     |   PD7 --| 13     16 |-- PB2 --|
//                     |-- PB0 --| 14     15 |-- PB1 --|
//                     |         |___________|         |
//                     \_______________________________/
//                                    |
//                                  PORTB
//
// 从这张图获取灵感，我们将以 PORTB 的各引脚作为本次位操作测验的心智模型。
// 需要说明的是，在下面的问题中我们使用了普通变量（其中一个命名为 PORTB）
// 来模拟对真实硬件寄存器位的修改。但在实际的微控制器代码中，PORTB 可能会
// 像这样被定义：
//          pub const PORTB = @as(*volatile u8, @ptrFromInt(0x25));
//
// 这能让编译器知道不要对 PORTB 做优化，从而使 IO 引脚能正确映射到我们的代码。
//
// 注意：为简化，我们在下列问题中使用 u4 类型，因此将结果应用到 PORTB 时，
// 只会影响低四位引脚 PB0..PB3。当然，你也完全可以把 u4 换成 u8，这样就能
// 控制 PORTB 的全部 8 个 IO 引脚了。

const std = @import("std");
const print = std.debug.print;
const testing = std.testing;

pub fn main() !void {
    var PORTB: u4 = 0b0000; // 为了简单起见，仅用 4 位宽

    // ------------------------------------------------------------------------
    // 测验
    // ------------------------------------------------------------------------
    //
    // 试着解决下面的问题。最后两个问题会给你一点“变招”。
    // 尝试独立解决它们。如果需要帮助，滚动到 main 的底部，
    // 查看关于在 Zig 中切换、设置和清除位的深入讲解。

    print("使用 XOR 在 PORTB 上切换引脚（Toggle）\n", .{});
    print("-----------------------------\n", .{});
    PORTB = 0b1100;
    print("  {b:0>4} // （PORTB 的初始状态）\n", .{PORTB});
    print("^ {b:0>4} // （位掩码 bitmask）\n", .{0b0101});
    PORTB ^= (1 << 1) | (1 << 0); // 这里有什么问题？
    checkAnswer(0b1001, PORTB);

    newline();

    PORTB = 0b1100;
    print("  {b:0>4} // （PORTB 的初始状态）\n", .{PORTB});
    print("^ {b:0>4} // （位掩码 bitmask）\n", .{0b0011});
    PORTB ^= (1 << 1) & (1 << 0); // 这里有什么问题？
    checkAnswer(0b1111, PORTB);

    newline();

    print("使用 OR 在 PORTB 上设置引脚（Set）\n", .{});
    print("-------------------------\n", .{});

    PORTB = 0b1001; // 重置 PORTB
    print("  {b:0>4} // （PORTB 的初始状态）\n", .{PORTB});
    print("| {b:0>4} // （位掩码 bitmask）\n", .{0b0100});
    PORTB = PORTB ??? (1 << 2); // 这里缺了什么？
    checkAnswer(0b1101, PORTB);

    newline();

    PORTB = 0b1001; // 重置 PORTB
    print("  {b:0>4} // （重置后的状态）\n", .{PORTB});
    print("| {b:0>4} // （位掩码 bitmask）\n", .{0b0100});
    PORTB ??? (1 << 2); // 这里缺了什么？
    checkAnswer(0b1101, PORTB);

    newline();

    print("使用 AND 与 NOT 在 PORTB 上清除引脚（Clear）\n", .{});
    print("------------------------------------\n", .{});

    PORTB = 0b1110; // 重置 PORTB
    print("  {b:0>4} // （PORTB 的初始状态）\n", .{PORTB});
    print("& {b:0>4} // （位掩码 bitmask）\n", .{0b1011});
    PORTB = PORTB & ???@as(u4, 1 << 2); // 这里缺了什么字符？
    checkAnswer(0b1010, PORTB);

    newline();

    PORTB = 0b0111; // 重置 PORTB
    print("  {b:0>4} // （重置后的状态）\n", .{PORTB});
    print("& {b:0>4} // （位掩码 bitmask）\n", .{0b1110});
    PORTB &= ~(1 << 0); // 这里缺了什么？
    checkAnswer(0b0110, PORTB);

    newline();
    newline();
}

// ************************************************************************
//                    下面是深入讲解（IN-DEPTH EXPLANATIONS）
// ************************************************************************
//
//
//
//
//
//
//
//
//
//
//
// ------------------------------------------------------------------------
// 使用 XOR 来切换位（Toggling bits with XOR）：
// ------------------------------------------------------------------------
// XOR 意为“异或（exclusive or）”。我们可以使用 ^（XOR）位运算符来切换位：
//
//
// 要输出 1，XOR 的逻辑要求两个输入位必须不同。
// 因此，0 ^ 1 与 1 ^ 0 都会得到 1，而 0 ^ 0 与 1 ^ 1 会得到 0。
// XOR 在“两个输入都是 1 时输出 0”的独特行为，使它不同于 OR 运算；
// 这也让我们可以通过在位掩码里放置 1 来实现“翻转（toggle）”。
// - 位掩码（bitmask）操作数中的 1，可以理解为会让另一个操作数的对应位
//   翻转为相反值。
// - 位掩码中的 0 不会引起变化。
//
//                            我们位掩码中的 0 会在输出中保留这些值
// -XOR 运算- ---展开示意---   _______________
//                          \ /
//                           /
//   1100   1   1   0   0
// ^ 0101   0   1   0   1 （位掩码）
// ------   -   -   -   -
// = 1001   1   0   0   1 <- 这个位本来就是清零的。
//              \_______\
//                       \
//                         可以把这些位理解为被翻转了，
//                         因为在我们位掩码相应列中存在 1。
//
// 接下来看看用 | 运算符设置位。
//
//
//
//
//
// ------------------------------------------------------------------------
// 使用 OR 设置位（Setting bits with OR）：
// ------------------------------------------------------------------------
// 我们可以用 |（OR）运算符在 PORTB 上设置位，例如：
//
// var PORTB: u4 = 0b1001;
// PORTB = PORTB | 0b0010;
// print("PORTB: {b:0>4}\n", .{PORTB}); // 输出：1011
//
// -OR 运算- ---展开示意---
//                    _ 只设置这个位。
//                   /
//   1001   1   0   0   1
// | 0010   0   0   1   0 （位掩码）
// ------   -   -   -   -
// = 1011   1   0   1   1
//           \___\_______\
//                        \
//                          这些位保持不变，因为与 0 做 OR 不会改变它们。
//
// ------------------------------------------------------------------------
// 如何创建像上面 0b0010 这样的位掩码：
//
// 1. 首先，用位移 <<（向左移）把 1 移动指定的位数，如下：
//           1 << 0 -> 0001
//           1 << 1 -> 0010  <-- 把 1 向左移动一位
//           1 << 2 -> 0100
//           1 << 3 -> 1000
//
// 这样，我们可以把上面的代码改写成：
//
// var PORTB: u4 = 0b1001;
// PORTB = PORTB | (1 << 1);
// print("PORTB: {b:0>4}\n", .{PORTB}); // 输出：1011
//
// 最后，与 C 语言类似，Zig 允许我们使用 |= 运算符，
// 因此又可以把代码更紧凑、更符合习惯地写成：PORTB |= (1 << 1)
//
// 现在我们已经介绍了如何切换与设置位。那么如何清除位呢？
// 这时 Zig 会给我们一点“变招”。别担心，我们按步骤来。
//
//
//
//
//
// ------------------------------------------------------------------------
// 使用 AND 与 NOT 清除位（Clearing bits with AND and NOT）：
// ------------------------------------------------------------------------
// 我们可以使用 &（AND）位运算符清除位，比如：
//
// PORTB = 0b1110; // 重置 PORTB
// PORTB = PORTB & 0b1011;
// print("PORTB: {b:0>4}\n", .{PORTB}); // 输出 -> 1010
//
// - 在与 AND 联合使用时，位掩码中的 0 会清除对应位。
// - 1 不会改变任何东西，从而保留原始位。
//
// -AND 运算- ---展开示意---
//                __________ 仅清除此位。
//               /
//   1110   1   1   1   0
// & 1011   1   0   1   1 （位掩码）
// ------   -   -   -   -
// = 1010   1   0   1   0 <- 这个位本来就是清零的。
//           \_______\
//                    \
//                      这些位保持不变，因为与 1 做 AND 会保留原始值
//                     （无论是 0 还是 1）。
//
// ------------------------------------------------------------------------
// 我们可以使用 ~（NOT）运算符来轻松创建类似 1011 的位掩码：
//
//  1. 首先，用位移 <<（向左移）把 1 移动两位：
//          1 << 0 -> 0001
//          1 << 1 -> 0010
//          1 << 2 -> 0100 <- 1 已向左移动了两位
//          1 << 3 -> 1000
//
//  2. 第二步是把这些位取反：
//          ~0100 -> 1011
//     在 C 里我们会写成：
//          ~(1 << 2) -> 1011
//
//     但如果在 Zig 里直接编译 ~(1 << 2)，会报错：
//          unable to perform binary not operation on type 'comptime_int'
//
//     在 Zig 取反位之前，它需要知道要取反的整数有多少位。
//
//     我们可以用内建 @as（类型转换为）来说明大小：
//          @as(u4, 1 << 2) -> 0100
//
//     最终，在该表达式前加上 NOT ~ 就能取反了：
//          ~@as(u4, 1 << 2) -> 1011
//
//     如果你不习惯必须像这样先把整数“限定为某个大小”才能取反
//    （而不是像 C 那样直接对整数字面量取反），你并不孤单。
//     但这正是 Zig 在帮助你规避难以调试的整数溢出问题。
//     为了保持理性，Zig 要求你显式告诉它要取反的数字有多少位。
//     用 Andrew Kelley 的话说，
//     “如果你想把一个整数的位取反，zig 必须知道它有多少位。”
//
//     想了解 Zig 团队为何对 ~ 运算符采取这样的设计，
//     可以看看 Andrew 在这个 GitHub issue 中的评论：
//     https://github.com/ziglang/zig/issues/1382#issuecomment-414459529
//
// 呼——综上，我们得到：
//          PORTB = PORTB & ~@as(u4, 1 << 2);
//
// 我们还可以用组合赋值运算符 &= 来缩写，
// 它会对 PORTB 执行 AND，然后把结果写回 PORTB：
//          PORTB &= ~@as(u4, 1 << 2);
//

// ------------------------------------------------------------------------
// 总结
// ------------------------------------------------------------------------
//
// 虽然本测验只用了 4 位宽的变量，但处理 8 位并没有什么不同。
// 下面是一个从“2 的位”开始每隔一位进行设置的示例：
//
// var PORTD: u8 = 0b0000_0000;
// print("PORTD: {b:0>8}\n", .{PORTD});
// PORTD |= (1 << 1);
// PORTD = setBit(u8, PORTD, 3);
// PORTD |= (1 << 5) | (1 << 7);
// print("PORTD: {b:0>8} // 每隔一位设置一次\n", .{PORTD});
// PORTD = ~PORTD;
// print("PORTD: {b:0>8} // 用 NOT (~) 翻转位\n", .{PORTD});
// newline();
//
// // 这里，我们从“2 的位”开始每隔一位清除一次。
// PORTD = 0b1111_1111;
// print("PORTD: {b:0>8}\n", .{PORTD});
// PORTD &= ~@as(u8, 1 << 1);
// PORTD = clearBit(u8, PORTD, 3);
// PORTD &= ~@as(u8, (1 << 5) | (1 << 7));
// print("PORTD: {b:0>8} // 每隔一位清除一次\n", .{PORTD});
// PORTD = ~PORTD;
// print("PORTD: {b:0>8} // 用 NOT (~) 翻转位\n", .{PORTD});
// newline();

// ----------------------------------------------------------------------------
// 下面是一些用于位操作的辅助函数
// ----------------------------------------------------------------------------

// 设置、清除与切换单个位的函数
fn setBit(comptime T: type, byte: T, comptime bit_pos: T) !T {
    return byte | (1 << bit_pos);
}

test "setBit" {
    try testing.expectEqual(setBit(u8, 0b0000_0000, 3), 0b0000_1000);
}

fn clearBit(comptime T: type, byte: T, comptime bit_pos: T) T {
    return byte & ~@as(T, (1 << bit_pos));
}

test "clearBit" {
    try testing.expectEqual(clearBit(u8, 0b1111_1111, 0), 0b1111_1110);
}

fn toggleBit(comptime T: type, byte: T, comptime bit_pos: T) T {
    return byte ^ (1 << bit_pos);
}

test "toggleBit" {
    var byte = toggleBit(u8, 0b0000_0000, 0);
    try testing.expectEqual(byte, 0b0000_0001);
    byte = toggleBit(u8, byte, 0);
    try testing.expectEqual(byte, 0b0000_0000);
}

// ----------------------------------------------------------------------------
// 再补充一些使用“元组”一次性设置、清除与切换多个位的函数，
// 毕竟，为什么不呢？ :)
// ----------------------------------------------------------------------------
//

fn createBitmask(comptime T: type, comptime bits: anytype) !T {
    comptime var bitmask: T = 0;
    inline for (bits) |bit| {
        if (bit >= @bitSizeOf(T)) return error.BitPosTooLarge;
        if (bit < 0) return error.BitPosTooSmall;

        bitmask |= (1 << bit);
    }
    return bitmask;
}

test "creating bitmasks from a tuple" {
    try testing.expectEqual(createBitmask(u8, .{0}), 0b0000_0001);
    try testing.expectEqual(createBitmask(u8, .{1}), 0b0000_0010);
    try testing.expectEqual(createBitmask(u8, .{2}), 0b0000_0100);
    try testing.expectEqual(createBitmask(u8, .{3}), 0b0000_1000);
    //
    try testing.expectEqual(createBitmask(u8, .{ 0, 4 }), 0b0001_0001);
    try testing.expectEqual(createBitmask(u8, .{ 1, 5 }), 0b0010_0010);
    try testing.expectEqual(createBitmask(u8, .{ 2, 6 }), 0b0100_0100);
    try testing.expectEqual(createBitmask(u8, .{ 3, 7 }), 0b1000_1000);

    try testing.expectError(error.BitPosTooLarge, createBitmask(u4, .{4}));
}

fn setBits(byte: u8, bits: anytype) !u8 {
    const bitmask = try createBitmask(u8, bits);
    return byte | bitmask;
}

test "setBits" {
    try testing.expectEqual(setBits(0b0000_0000, .{0}), 0b0000_0001);
    try testing.expectEqual(setBits(0b0000_0000, .{7}), 0b1000_0000);

    try testing.expectEqual(setBits(0b0000_0000, .{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b1111_1111);
    try testing.expectEqual(setBits(0b1111_1111, .{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b1111_1111);

    try testing.expectEqual(setBits(0b0000_0000, .{ 2, 3, 4, 5 }), 0b0011_1100);

    try testing.expectError(error.BitPosTooLarge, setBits(0b1111_1111, .{8}));
    try testing.expectError(error.BitPosTooSmall, setBits(0b1111_1111, .{-1}));
}

fn clearBits(comptime byte: u8, comptime bits: anytype) !u8 {
    const bitmask: u8 = try createBitmask(u8, bits);
    return byte & ~@as(u8, bitmask);
}

test "clearBits" {
    try testing.expectEqual(clearBits(0b1111_1111, .{0}), 0b1111_1110);
    try testing.expectEqual(clearBits(0b1111_1111, .{7}), 0b0111_1111);

    try testing.expectEqual(clearBits(0b1111_1111, .{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b000_0000);
    try testing.expectEqual(clearBits(0b0000_0000, .{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b000_0000);

    try testing.expectEqual(clearBits(0b1111_1111, .{ 0, 1, 6, 7 }), 0b0011_1100);

    try testing.expectError(error.BitPosTooLarge, clearBits(0b1111_1111, .{8}));
    try testing.expectError(error.BitPosTooSmall, clearBits(0b1111_1111, .{-1}));
}

fn toggleBits(comptime byte: u8, comptime bits: anytype) !u8 {
    const bitmask = try createBitmask(u8, bits);
    return byte ^ bitmask;
}

test "toggleBits" {
    try testing.expectEqual(toggleBits(0b0000_0000, .{0}), 0b0000_0001);
    try testing.expectEqual(toggleBits(0b0000_0000, .{7}), 0b1000_0000);

    try testing.expectEqual(toggleBits(0b1111_1111, .{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b000_0000);
    try testing.expectEqual(toggleBits(0b0000_0000, .{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b1111_1111);

    try testing.expectEqual(toggleBits(0b0000_1111, .{ 0, 1, 2, 3, 4, 5, 6, 7 }), 0b1111_0000);
    try testing.expectEqual(toggleBits(0b0000_1111, .{ 0, 1, 2, 3 }), 0b0000_0000);

    try testing.expectEqual(toggleBits(0b0000_0000, .{ 0, 2, 4, 6 }), 0b0101_0101);

    try testing.expectError(error.BitPosTooLarge, toggleBits(0b1111_1111, .{8}));
    try testing.expectError(error.BitPosTooSmall, toggleBits(0b1111_1111, .{-1}));
}

// ----------------------------------------------------------------------------
// 实用函数
// ----------------------------------------------------------------------------

fn newline() void {
    print("\n", .{});
}

fn checkAnswer(expected: u4, answer: u4) void {
    if (expected != answer) {
        print("*************************************************************\n", .{});
        print("= {b:0>4} <- INCORRECT! THE EXPECTED OUTPUT IS {b:0>4}\n", .{ answer, expected });
        print("*************************************************************\n", .{});
    } else {
        print("= {b:0>4}", .{answer});
    }
    newline();
}
