//
//    “长鼻子和尾巴
//     都是好用的东西”
//
//     —— 摘自 Lenore M. Link《Holding Hands》
//
// 既然我们已经把尾巴都搞清楚了，你能实现长鼻子（trunks）吗？
//
const std = @import("std");

const Elephant = struct {
    letter: u8,
    tail: ?*Elephant = null,
    trunk: ?*Elephant = null,
    visited: bool = false,

    // 大象“尾巴”的方法！
    pub fn getTail(self: *Elephant) *Elephant {
        return self.tail.?; // 记住，这相当于 "orelse unreachable"
    }

    pub fn hasTail(self: *Elephant) bool {
        return (self.tail != null);
    }

    // 你的大象“长鼻子”方法写在这里！
    // ---------------------------------------------------

    ???

    // ---------------------------------------------------

    pub fn visit(self: *Elephant) void {
        self.visited = true;
    }

    pub fn print(self: *Elephant) void {
        // 打印大象字母以及 [v]isited 标记
        const v: u8 = if (self.visited) 'v' else ' ';
        std.debug.print("{u}{u} ", .{ self.letter, v });
    }
};

pub fn main() void {
    var elephantA = Elephant{ .letter = 'A' };
    var elephantB = Elephant{ .letter = 'B' };
    var elephantC = Elephant{ .letter = 'C' };

    // 我们把大象连接起来，让每条尾巴都“指向”下一头大象。
    elephantA.tail = &elephantB;
    elephantB.tail = &elephantC;

    // 再把大象连接起来，让每条长鼻子都“指向”前一头大象。
    elephantB.trunk = &elephantA;
    elephantC.trunk = &elephantB;

    visitElephants(&elephantA);

    std.debug.print("\n", .{});
}

// 这个函数会访问所有大象两次：先沿着尾巴，再沿着长鼻子返回。
fn visitElephants(first_elephant: *Elephant) void {
    var e = first_elephant;

    // 我们沿着尾巴前进！
    while (true) {
        e.print();
        e.visit();

        // 获取下一头大象或停止。
        if (e.hasTail()) {
            e = e.getTail();
        } else {
            break;
        }
    }

    // 我们沿着长鼻子返回！
    while (true) {
        e.print();

        // 获取前一头大象或停止。
        if (e.hasTrunk()) {
            e = e.getTrunk();
        } else {
            break;
        }
    }
}
