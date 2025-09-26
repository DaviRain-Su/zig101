//
//    "大象们走在路上
//     互相牵着手
//
//     他们其实是
//     用尾巴牵着的。"
//
//     —— 摘自 Lenore M. Link 《Holding Hands》
//
const std = @import("std");

const Elephant = struct {
    letter: u8,
    tail: *Elephant = undefined,
    visited: bool = false,
};

pub fn main() void {
    var elephantA = Elephant{ .letter = 'A' };
    // （请在这里添加 Elephant B！）
    var elephantC = Elephant{ .letter = 'C' };

    // 把大象们连起来，让每条尾巴都“指向”下一头大象。
    // 它们形成一个圈：A->B->C->A...
    elephantA.tail = &elephantB;
    // （请在这里把 Elephant B 的尾巴连到 Elephant C！）
    elephantC.tail = &elephantA;

    visitElephants(&elephantA);

    std.debug.print("\n", .{});
}

// 这个函数会从第一头大象开始访问所有大象，
// 按照尾巴的指向依次前进，每头大象只访问一次。
// 如果我们不“标记”大象已访问（visited=true），
// 这个循环就会无限进行下去！
fn visitElephants(first_elephant: *Elephant) void {
    var e = first_elephant;

    while (!e.visited) {
        std.debug.print("Elephant {u}. ", .{e.letter});
        e.visited = true;
        e = e.tail;
    }
}
