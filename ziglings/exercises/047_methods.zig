//
// 救命啊！邪恶的外星生物把蛋藏满了整个地球，
// 它们正在孵化！
//
// 在你投入战斗之前，你需要知道三件事：
//
// 1. 你可以给结构体（和其他“类型定义”）附加函数：
//
//     const Foo = struct{
//         pub fn hello() void {
//             std.debug.print("Foo says hello!\n", .{});
//         }
//     };
//
// 2. 属于结构体的函数是在该结构体的“命名空间”中，
//    调用时需要先写命名空间再用点语法：
//
//     Foo.hello();
//
// 3. 很棒的地方在于，如果函数的第一个参数是这个结构体的实例
//    （或它的指针），那么我们可以用实例来当命名空间来调用它：
//
//     const Bar = struct{
//         pub fn a(self: Bar) void {}
//         pub fn b(this: *Bar, other: u8) void {}
//         pub fn c(bar: *const Bar) void {}
//     };
//
//    var bar = Bar{};
//    bar.a() // 等价于 Bar.a(bar)
//    bar.b(3) // 等价于 Bar.b(&bar, 3)
//    bar.c() // 等价于 Bar.c(&bar)
//
//    注意：参数的名字并不重要。
//    有的用 self，有的用类型名的小写形式，你可以随便取，
//    只要合适就行。
//
// 好了，你武装好了。
//
// 现在，请用热射线把这些外星结构体全消灭掉，
// 否则地球就要完蛋了！
//
const std = @import("std");

// 看看这个丑陋的 Alien 结构体。要知己知彼！
const Alien = struct {
    health: u8,

    // 我们讨厌这个方法：
    pub fn hatch(strength: u8) Alien {
        return Alien{
            .health = strength * 5,
        };
    }
};

// 这是你可靠的武器。用它消灭外星人！
const HeatRay = struct {
    damage: u8,

    // 我们喜欢这个方法：
    pub fn zap(self: HeatRay, alien: *Alien) void {
        alien.health -= if (self.damage >= alien.health) alien.health else self.damage;
    }
};

pub fn main() void {
    // 看看这些不同强度的外星人！
    var aliens = [_]Alien{
        Alien.hatch(2),
        Alien.hatch(1),
        Alien.hatch(3),
        Alien.hatch(3),
        Alien.hatch(5),
        Alien.hatch(3),
    };

    var aliens_alive = aliens.len;
    const heat_ray = HeatRay{ .damage = 7 }; // 我们得到了热射线武器。

    // 我们要不断检查，看是不是已经把所有外星人都消灭了。
    while (aliens_alive > 0) {
        aliens_alive = 0;

        // 用引用遍历每个外星人（* 表示捕获指针）
        for (&aliens) |*alien| {

            // *** 用热射线攻击外星人！***
            ???.zap(???);

            // 如果外星人的生命值还大于 0，它就还活着。
            if (alien.health > 0) aliens_alive += 1;
        }

        std.debug.print("{} aliens. ", .{aliens_alive});
    }

    std.debug.print("Earth is saved!\n", .{});
}
