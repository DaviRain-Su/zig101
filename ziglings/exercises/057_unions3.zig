//
// 使用带标签的联合体后，情况会变得更好！
// 如果你不需要单独定义一个枚举，可以直接在联合体里定义一个“推断枚举”。
// 只需要在标签类型的位置使用 `enum` 关键字即可：
//
//     const Foo = union(enum) {
//         small: u8,
//         medium: u32,
//         large: u64,
//     };
//
// 让我们把 Insect 转换一下。
// Zoraptera 博士已经帮你删除了显式的 InsectStat 枚举！
//
const std = @import("std");

const Insect = union(InsectStat) {
    flowers_visited: u16,
    still_alive: bool,
};

pub fn main() void {
    const ant = Insect{ .still_alive = true };
    const bee = Insect{ .flowers_visited = 17 };

    std.debug.print("Insect report! ", .{});

    printInsect(ant);
    printInsect(bee);

    std.debug.print("\n", .{});
}

fn printInsect(insect: Insect) void {
    switch (insect) {
        .still_alive => |a| std.debug.print("Ant alive is: {}. ", .{a}),
        .flowers_visited => |f| std.debug.print("Bee visited {} flowers. ", .{f}),
    }
}

// 推断枚举（inferred enums）非常巧妙，它展示了枚举和联合体关系中的冰山一角。
// 你实际上可以把一个联合体强制转换为枚举（得到联合体的活动字段作为一个枚举）。
// 更疯狂的是，你甚至可以把一个枚举强制转换为联合体！
// 不过别太兴奋，这只在联合体类型是那些奇怪的零比特类型（比如 void）时才有效。
//
// 带标签的联合体，和计算机科学中的大多数概念一样，可以追溯到 1960 年代。
// 不过，它们直到最近才逐渐进入主流，尤其是在系统级编程语言里。
// 你可能也见过它们被叫做 “variants（变体）”、
// “sum types（和类型）”，甚至就是 “enums（枚举）”！
