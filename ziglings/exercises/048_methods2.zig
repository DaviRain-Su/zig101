//
// 既然我们已经见识了方法 (methods) 是怎么用的，
// 那么让我们再帮大象们多写几个属于 Elephant 的方法吧。
//
const std = @import("std");

const Elephant = struct {
    letter: u8,
    tail: ?*Elephant = null,
    visited: bool = false,

    // 新增 Elephant 方法！
    pub fn getTail(self: *Elephant) *Elephant {
        return self.tail.?; // 记住，这里等价于 "orelse unreachable"
    }

    pub fn hasTail(self: *Elephant) bool {
        return (self.tail != null);
    }

    pub fn visit(self: *Elephant) void {
        self.visited = true;
    }

    pub fn print(self: *Elephant) void {
        // 打印大象的字母以及 [v]isited
        const v: u8 = if (self.visited) 'v' else ' ';
        std.debug.print("{u}{u} ", .{ self.letter, v });
    }
};

pub fn main() void {
    var elephantA = Elephant{ .letter = 'A' };
    var elephantB = Elephant{ .letter = 'B' };
    var elephantC = Elephant{ .letter = 'C' };

    // 把大象们连起来，让每条尾巴都“指向”下一头大象。
    elephantA.tail = &elephantB;
    elephantB.tail = &elephantC;

    visitElephants(&elephantA);

    std.debug.print("\n", .{});
}

// 这个函数会从第一头大象开始，顺着尾巴依次访问所有大象，
// 每头大象只访问一次。
fn visitElephants(first_elephant: *Elephant) void {
    var e = first_elephant;

    while (true) {
        e.print();
        e.visit();

        // 获取下一头大象，或者停止：
        // 我们应该在这里调用哪个方法呢？
        e = if (e.hasTail()) e.??? else break;
    }
}

// Zig 的枚举 (enums) 也可以有方法！
// 这个注释最初是让大家去找“野生的枚举方法”实例。
// 前五个 pull requests 被接受了，这里是它们：
//
// 1) drforester - 我在 Zig 源码里找到了一个：
// https://github.com/ziglang/zig/blob/041212a41cfaf029dc3eb9740467b721c76f406c/src/Compilation.zig#L2495
//
// 2) bbuccianti - 我也找到了一个！
// https://github.com/ziglang/zig/blob/6787f163eb6db2b8b89c2ea6cb51d63606487e12/lib/std/debug.zig#L477
//
// 3) GoldsteinE - 找到了好几个，这里有一个：
// https://github.com/ziglang/zig/blob/ce14bc7176f9e441064ffdde2d85e35fd78977f2/lib/std/target.zig#L65
//
// 4) SpencerCDixon - 太喜欢这个语言了 :-)
// https://github.com/ziglang/zig/blob/a502c160cd51ce3de80b3be945245b7a91967a85/src/zir.zig#L530
//
// 5) tomkun - 这是另一个枚举方法
// https://github.com/ziglang/zig/blob/4ca1f4ec2e3ae1a08295bc6ed03c235cb7700ab9/src/codegen/aarch64.zig#L24
