//
// 在结构体里把数值组合在一起不仅仅是为了方便。
// 它还能让我们在存储、传递函数参数等场景里，
// 把这些值当成一个整体来处理。
//
// 这个练习展示了如何把结构体存储在数组里，
// 以及这样做如何让我们能用循环来打印它们。
//
const std = @import("std");

const Role = enum {
    wizard,
    thief,
    bard,
    warrior,
};

const Character = struct {
    role: Role,
    gold: u32,
    health: u8,
    experience: u32,
};

pub fn main() void {
    var chars: [2]Character = undefined;

    // 智慧的 Glorp
    chars[0] = Character{
        .role = Role.wizard,
        .gold = 20,
        .health = 100,
        .experience = 10,
    };

    // 请添加 “喧闹的 Zump”，其属性如下：
    //
    //     role       bard
    //     gold       10
    //     health     100
    //     experience 20
    //
    // 你可以先不加 Zump 就运行程序。
    // 运行后会发生什么？为什么？

    // 循环打印所有 RPG 角色：
    for (chars, 0..) |c, num| {
        std.debug.print("Character {} - G:{} H:{} XP:{}\n", .{
            num + 1, c.gold, c.health, c.experience,
        });
    }
}

// 如果你尝试像上面说的那样运行程序（没加 Zump），
// 你会看到看似“垃圾”的数值。
// 在调试模式（默认模式）下，Zig 会在所有未定义的位置写入
// 二进制模式 "10101010"（十六进制 0xAA），
// 这样在调试时更容易发现它们。
