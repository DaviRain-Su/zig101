//
// 既然我们现在有了可选类型 (optional types)，
// 我们就能把它们应用到结构体上。
// 上一次我们写大象的时候，必须把三头大象连成一个“圈”，
// 因为最后一条尾巴必须指向第一头大象。
// 这是因为我们当时没有“尾巴可以不指向任何大象”这个概念！
//
// 我们还要介绍一个方便的 `.?` 简写：
//
//     const foo = bar.?;
//
// 等价于：
//
//     const foo = bar orelse unreachable;
//
// 看看下面的代码，我们用这个简写来根据可选值是否存在来改变控制流。
//
// 现在让我们把大象的尾巴改成可选的吧！
//
const std = @import("std");

const Elephant = struct {
    letter: u8,
    tail: *Elephant = null, // 嗯…… tail 这里需要改成可选类型……
    visited: bool = false,
};

pub fn main() void {
    var elephantA = Elephant{ .letter = 'A' };
    var elephantB = Elephant{ .letter = 'B' };
    var elephantC = Elephant{ .letter = 'C' };

    // 把大象们连起来，让每条尾巴都“指向”下一头大象。
    linkElephants(&elephantA, &elephantB);
    linkElephants(&elephantB, &elephantC);

    // 如果你尝试把不存在的大象连起来，`linkElephants`
    // 会让程序直接退出！试试看把下面的注释取消掉：
    // const missingElephant: ?*Elephant = null;
    // linkElephants(&elephantC, missingElephant);

    visitElephants(&elephantA);

    std.debug.print("\n", .{});
}

// 如果 e1 和 e2 是有效的大象指针，
// 这个函数就会把 e1 的尾巴“指向” e2。
fn linkElephants(e1: ?*Elephant, e2: ?*Elephant) void {
    e1.?.tail = e2.?;
}

// 这个函数会从第一头大象开始，
// 一直访问所有大象，顺着尾巴依次前进。
fn visitElephants(first_elephant: *Elephant) void {
    var e = first_elephant;

    while (!e.visited) {
        std.debug.print("Elephant {u}. ", .{e.letter});
        e.visited = true;

        // 我们应该在遇到一条“没有指向下一头大象”的尾巴时停下。
        // 要在这里写点什么才能实现呢？
        //
        // 提示：我们想要的效果和 `.?` 类似，
        // 但不要让程序退出，而是要跳出循环……
        e = e.tail ???
    }
}
