//
// 联合（union）允许你在同一个内存地址存储不同类型和大小的数据。
// 这是怎么做到的呢？编译器会为可能存储的最大数据类型分配足够的空间。
//
// 在这个例子中，一个 Foo 实例在内存中始终占用 u64 的大小，
// 即使你当前只存储了一个 u8：
//
//     const Foo = union {
//         small: u8,
//         medium: u32,
//         large: u64,
//     };
//
// 语法看起来和结构体（struct）很像，但 Foo 只能存储 small 或 medium 或 large 之一。
// 一旦某个字段被激活，其他非激活字段就不能再访问。
// 如果要切换激活的字段，必须重新赋值一个完整的新实例：
//
//     var f = Foo{ .small = 5 };
//     f.small += 5;                  // OK
//     f.medium = 5432;               // 错误！
//     f = Foo{ .medium = 5432 };     // OK
//
// 联合可以节省内存空间，因为它们允许你“重用”同一片内存。
// 它们还提供了一种原始的多态（polymorphism）。
// 例如 fooBar() 可以接受一个 Foo，不管它存的是什么大小的无符号整数：
//
//     fn fooBar(f: Foo) void { ... }
//
// 哦，那 fooBar() 怎么知道当前激活的是哪个字段呢？
// Zig 有一个很巧妙的机制来追踪它，但目前我们要手动处理。
//
// 让我们看看能不能让这个程序跑起来！
//
const std = @import("std");

// 我们正在编写一个简单的生态系统模拟。
// 昆虫会用蜜蜂或蚂蚁来表示。
// 蜜蜂存储它们当天访问过的花朵数量，蚂蚁只存储它们是否还活着。
const Insect = union {
    flowers_visited: u16,
    still_alive: bool,
};

// 因为我们需要指定昆虫的类型，所以要用一个枚举（还记得吗？）。
const AntOrBee = enum { a, b };

pub fn main() void {
    // 我们先做一只蚂蚁和一只蜜蜂来测试：
    const ant = Insect{ .still_alive = true };
    const bee = Insect{ .flowers_visited = 15 };

    std.debug.print("Insect report! ", .{});

    // 哎呀！这里写错了。
    printInsect(ant, AntOrBee.c);
    printInsect(bee, AntOrBee.c);

    std.debug.print("\n", .{});
}

// 怪 eccentric 的 Zoraptera 博士说我们只能用一个函数来打印昆虫。
// Z 博士个子很小，有时候还让人摸不透，但我们绝不能质疑她。
fn printInsect(insect: Insect, what_it_is: AntOrBee) void {
    switch (what_it_is) {
        .a => std.debug.print("Ant alive is: {}. ", .{insect.still_alive}),
        .b => std.debug.print("Bee visited {} flowers. ", .{insect.flowers_visited}),
    }
}
