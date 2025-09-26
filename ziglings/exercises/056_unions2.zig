//
// 手动追踪我们联合体（union）里哪个字段是激活的，真的很不方便，对吧？
//
// 幸运的是，Zig 还有“带标签的联合”（tagged unions），它允许我们在联合体中
// 存储一个枚举值，用来表示当前激活的是哪个字段。
//
//     const FooTag = enum{ small, medium, large };
//
//     const Foo = union(FooTag) {
//         small: u8,
//         medium: u32,
//         large: u64,
//     };
//
// 现在我们可以直接对联合体使用 switch 来处理当前激活的字段：
//
//     var f = Foo{ .small = 10 };
//
//     switch (f) {
//         .small => |my_small| do_something(my_small),
//         .medium => |my_medium| do_something(my_medium),
//         .large => |my_large| do_something(my_large),
//     }
//
// 让我们把 Insect 改成使用带标签的联合（Zoraptera 博士表示赞同）。
//
const std = @import("std");

const InsectStat = enum { flowers_visited, still_alive };

const Insect = union(InsectStat) {
    flowers_visited: u16,
    still_alive: bool,
};

pub fn main() void {
    const ant = Insect{ .still_alive = true };
    const bee = Insect{ .flowers_visited = 16 };

    std.debug.print("Insect report! ", .{});

    // 难道真的可以像这样直接传递联合体吗？
    printInsect(???);
    printInsect(???);

    std.debug.print("\n", .{});
}

fn printInsect(insect: Insect) void {
    switch (???) {
        .still_alive => |a| std.debug.print("Ant alive is: {}. ", .{a}),
        .flowers_visited => |f| std.debug.print("Bee visited {} flowers. ", .{f}),
    }
}

// 顺便说一句，联合体是不是让你想起了可选值（optional）和错误（error）？
// 可选值基本上就是“null 联合”，而错误使用的是“错误联合类型”。
// 现在我们可以添加自己的联合体，用来处理我们可能遇到的各种情况：
//          union(Tag) { value: u32, toxic_ooze: void }
