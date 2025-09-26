//
//    “我们生活在宁静的无知小岛上，
//     四周是无垠的黑色海洋，
//     命中并未注定让我们远航。”
//
//     —— 摘自 H. P. Lovecraft《克苏鲁的呼唤》
//
// Zig 至少有四种方式来表达“没有值”：
//
// * undefined（未定义）
//
//       var foo: u8 = undefined;
//
//       不要把 “undefined” 当成一个值，而应理解为：
//       你**尚未**给它赋值的一种声明方式。任何类型都可以设为 undefined，
//       但**尝试读取或使用**这个“值”**始终**是错误的。
//
// * null（空值）
//
//       var foo: ?u8 = null;
//
//       原语值 “null” **确实是一个值**，它的含义是“没有值”。通常配合
//       可选类型使用，就像上面的 ?u8。foo 等于 null 时，这并不是一个
//       u8 类型的值；这表示在 foo 里**根本没有**任何 u8 类型的值！
//
// * error（错误）
//
//       var foo: MyError!u8 = BadError;
//
//       错误与 null **非常**相似。它们**是**一个值，但通常表示你想要的
//       “真实值”并不存在，取而代之的是一个错误。上面的错误联合类型
//       MyError!u8 表示：foo 要么保存一个 u8 值，要么保存一个错误。
//       当它被设为一个错误时，foo 中**没有**任何 u8 类型的值！
//
// * void（空类型）
//
//       var foo: void = {};
//
//       “void” 是一种**类型**，不是值。它是最常见的“零位类型”（不占空间、
//       只有语义意义的类型）。当编译为可执行代码时，零位类型完全不产生代码。
//       上面的例子展示了一个类型为 void 的变量 foo，它被赋予一个空表达式。
//       更常见的场景是把 void 用作“不返回任何值”的函数返回类型。
//
// Zig 之所以有这些不同方式去表达“无值”，是因为它们各有用途。简述：
//
//   * undefined - 目前**还没有**值，**暂时**不能读取
//   * null      - 存在一个明确的“无值”
//   * errors    - 因为出了错，所以没有值
//   * void      - 这里**永远不会**存储任何值
//
// 请为每个 ??? 使用正确的“无值”写法，使本程序打印出
// 《死灵之书》的某句被诅咒的引文……如果你敢的话。
//
const std = @import("std");

const Err = error{Cthulhu};

pub fn main() void {
    var first_line1: *const [16]u8 = ???;
    first_line1 = "That is not dead";

    var first_line2: Err!*const [21]u8 = ???;
    first_line2 = "which can eternal lie";

    // 注意：对错误联合里的字符串需要使用 "{!s}" 的格式。
    std.debug.print("{s} {!s} / ", .{ first_line1, first_line2 });

    printSecondLine();
}

fn printSecondLine() ??? {
    var second_line2: ?*const [18]u8 = ???;
    second_line2 = "even death may die";

    std.debug.print("And with strange aeons {s}.\n", .{second_line2.?});
}
