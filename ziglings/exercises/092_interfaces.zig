//
// 还记得我们在练习 55 和 56 中用 union 构建的蚂蚁和蜜蜂模拟器吗？
// 在那里我们演示了 union 允许我们以统一的方式处理不同的数据类型。
//
// 一个很巧妙的功能是使用带标签的 union，通过 switch 创建一个
// 能同时打印蚂蚁 *或* 蜜蜂状态的函数：
//
//   switch (insect) {
//      .still_alive => ...      // （打印蚂蚁信息）
//      .flowers_visited => ...  // （打印蜜蜂信息）
//   }
//
// 不过这个模拟器运行得好好的，直到一个新昆虫——蚱蜢，来到虚拟花园！
//
// Zoraptera 博士开始在程序里加入蚱蜢的代码，但随后她从键盘前退开，
// 发出愤怒的嘶嘶声。她意识到：如果每种昆虫的逻辑在一个地方，
// 而打印函数却在另一个地方，那么当模拟扩展到数百种不同昆虫时，
// 维护起来会非常麻烦。
//
// 幸运的是，Zig 有另一个编译期功能可以帮助我们摆脱这个困境，
// 叫做 `inline else`。
//
// 我们可以把这种重复代码：
//
//   switch (thing) {
//       .a => |a| special(a),
//       .b => |b| normal(b),
//       .c => |c| normal(c),
//       .d => |d| normal(d),
//       .e => |e| normal(e),
//       ...
//   }
//
// 替换成：
//
//   switch (thing) {
//       .a => |a| special(a),
//       inline else => |t| normal(t),
//   }
//
// 这样我们就可以对部分情况进行特殊处理，剩下的交给 Zig 自动处理。
//
// 借助这个功能，你决定创建一个 Insect 联合体，并给它一个统一的 `print()` 方法。
// 这样每种昆虫都可以自己负责打印自己的状态。
// Zoraptera 博士终于能冷静下来，不再啃咬家具了。
//
const std = @import("std");

const Ant = struct {
    still_alive: bool,

    pub fn print(self: Ant) void {
        std.debug.print("Ant is {s}.\n", .{if (self.still_alive) "alive" else "dead"});
    }
};

const Bee = struct {
    flowers_visited: u16,

    pub fn print(self: Bee) void {
        std.debug.print("Bee visited {} flowers.\n", .{self.flowers_visited});
    }
};

// 这是新的蚱蜢。注意我们也为每种昆虫加了 print 方法。
const Grasshopper = struct {
    distance_hopped: u16,

    pub fn print(self: Grasshopper) void {
        std.debug.print("Grasshopper hopped {} meters.\n", .{self.distance_hopped});
    }
};

const Insect = union(enum) {
    ant: Ant,
    bee: Bee,
    grasshopper: Grasshopper,

    // 多亏了 `inline else`，我们可以把这个 print() 看作接口方法。
    // union 中任何带有 print() 方法的成员，都能被外部代码统一调用，
    // 而无需关心其他细节。很酷吧！
    pub fn print(self: Insect) void {
        switch (self) {
            inline else => |case| return case.print(),
        }
    }
};

pub fn main() !void {
    const my_insects = [_]Insect{
        Insect{ .ant = Ant{ .still_alive = true } },
        Insect{ .bee = Bee{ .flowers_visited = 17 } },
        Insect{ .grasshopper = Grasshopper{ .distance_hopped = 32 } },
    };

    std.debug.print("Daily Insect Report:\n", .{});
    for (my_insects) |insect| {
        // 差不多完成了！我们想要通过一个统一的方法调用来打印每只昆虫。
        ???
    }
}

// 我们在 Insect 联合体里的 print() 方法，演示了一个非常类似于
// 面向对象语言里的抽象数据类型的概念。
// 也就是说，Insect 类型本身并不包含底层数据，print() 函数
// 实际上也不直接执行打印。
//
// 接口的意义在于支持泛型编程：
// 可以把不同的东西当作相同的来处理，从而减少冗余和复杂度。
//
// 《每日昆虫报告》不需要担心报告里有哪些昆虫——它们都能通过
// 统一接口来打印自己！
//
// Zoraptera 博士非常满意。
