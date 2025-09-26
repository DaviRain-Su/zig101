//
// 和整数一样，当你希望修改一个结构体时，
// 你可以把它的指针传给函数。
// 当你需要保存对结构体的引用（即一个“链接”）时，
// 指针也很有用。
//
//     const Vertex = struct{ x: u32, y: u32, z: u32 };
//
//     var v1 = Vertex{ .x=3, .y=2, .z=5 };
//
//     var pv: *Vertex = &v1;   // <-- 指向 v1 的指针
//
// 注意：访问结构体的字段时，你不需要先解引用指针：
//
//     ✅ pv.x
//     ❌ pv.*.x
//
// 我们可以写接受结构体指针作为参数的函数。
// 比如这个 foo() 函数修改了 v：
//
//     fn foo(v: *Vertex) void {
//         v.x += 2;
//         v.y += 3;
//         v.z += 7;
//     }
//
// 调用时这样写：
//
//     foo(&v1);
//
// 我们来重温 RPG 的例子，写一个 printCharacter() 函数，
// 它接受一个角色 (Character) 的引用并打印它……
// **同时**打印它的 “导师”(mentor)，如果存在的话。
//
const std = @import("std");

const Class = enum {
    wizard,
    thief,
    bard,
    warrior,
};

const Character = struct {
    class: Class,
    gold: u32,
    health: u8 = 100, // 你可以提供默认值
    experience: u32,

    // 这里我需要用 '?' 来允许空值 (null)。
    // 但我还不会解释这个，先别告诉别人哦。
    mentor: ?*Character = null,
};

pub fn main() void {
    var mighty_krodor = Character{
        .class = Class.wizard,
        .gold = 10000,
        .experience = 2340,
    };

    var glorp = Character{ // Glorp!
        .class = Class.wizard,
        .gold = 10,
        .experience = 20,
        .mentor = &mighty_krodor, // Glorp 的导师是 Mighty Krodor
    };

    // 修复这里！
    // 请把 Glorp 传给 printCharacter():
    printCharacter(???);
}

// 注意这个函数的参数 "c" 是一个 Character 结构体的指针。
fn printCharacter(c: *Character) void {
    // 你之前没见过这个：当 switch 一个枚举时，
    // 不需要写完整的枚举名。
    // Zig 会理解 ".wizard" 表示 "Class.wizard"，
    // 因为我们在 switch 的是 Class 类型。
    const class_name = switch (c.class) {
        .wizard => "Wizard",
        .thief => "Thief",
        .bard => "Bard",
        .warrior => "Warrior",
    };

    std.debug.print("{s} (G:{} H:{} XP:{})\n", .{
        class_name,
        c.gold,
        c.health,
        c.experience,
    });

    // 检查并捕获一个“可选值”的写法会在后面解释，
    // 它对应上面提到的 '?'。
    if (c.mentor) |mentor| {
        std.debug.print("  Mentor: ", .{});
        printCharacter(mentor);
    }
}
