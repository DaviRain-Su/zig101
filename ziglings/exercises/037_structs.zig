//
// 能把数值组合在一起，能让我们把下面这种写法：
//
//     point1_x = 3;
//     point1_y = 16;
//     point1_z = 27;
//     point2_x = 7;
//     point2_y = 13;
//     point2_z = 34;
//
// 变成这样：
//
//     point1 = Point{ .x=3, .y=16, .z=27 };
//     point2 = Point{ .x=7, .y=13, .z=34 };
//
// 上面的 Point 就是一个 “struct”（结构体）的例子。
// 这个结构体类型可以这样定义：
//
//     const Point = struct{ x: u32, y: u32, z: u32 };
//
// 我们来用结构体存储一些有趣的东西：一个角色扮演游戏里的角色！
//
const std = @import("std");

// 我们用一个枚举来表示角色的职业。
const Role = enum {
    wizard,
    thief,
    bard,
    warrior,
};

// 请在这个结构体里新增一个名为 "health" 的属性，类型是 u8 整数。
const Character = struct {
    role: Role,
    gold: u32,
    experience: u32,
};

pub fn main() void {
    // 请初始化 Glorp，并赋予 100 点生命值。
    var glorp_the_wise = Character{
        .role = Role.wizard,
        .gold = 20,
        .experience = 10,
    };

    // Glorp 获得了一些金币。
    glorp_the_wise.gold += 5;

    // 哎哟！Glorp 挨了一拳！
    glorp_the_wise.health -= 10;

    std.debug.print("Your wizard has {} health and {} gold.\n", .{
        glorp_the_wise.health,
        glorp_the_wise.gold,
    });
}
