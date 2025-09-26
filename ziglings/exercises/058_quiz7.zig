//
// 我们已经吸收了很多关于在 Zig 中可用的各种类型的信息。大致按顺序：
//
//                          u8  单个元素
//                         *u8  指向单个元素的指针
//                        []u8  切片（大小在运行时已知）
//                       [5]u8  一个包含 5 个 u8 的数组
//                       [*]u8  多元素指针（零个或多个）
//                 enum {a, b}  唯一值集合 a 与 b
//                error {e, f}  唯一错误值集合 e 与 f
//      struct {y: u8, z: i32}  值 y 与 z 的组合
// union(enum) {a: u8, b: i32}  单个值，要么是 u8 要么是 i32
//
// 上述任意类型的值都可以用 "var" 或 "const" 来声明，借此允许或禁止通过该名字进行修改（可变性）：
//
//     const a: u8 = 5; // 不可变
//       var b: u8 = 5; //   可变
//
// 我们也可以从上述任意类型构造错误联合或可选类型：
//
//     var a: E!u8 = 5; // 可以是 u8 或来自集合 E 的错误
//     var b: ?u8 = 5;  // 可以是 u8 或 null
//
// 了解了这些，也许我们能帮帮本地的一位隐士。他写了一个小小的 Zig 程序来帮助他规划穿越森林的旅程，
// 但里面有一些错误。
//
// *************************************************************
// *                      关于本练习的说明                      *
// *                                                           *
// * 你并不需要阅读并理解这个程序的每一处。这是一个很大的例子。 *
// * 随便浏览一下，然后只聚焦在那几个真的“坏掉”的地方即可！       *
// *                                                           *
// *************************************************************
//
const print = @import("std").debug.print;

// Grue（食人怪）是对 Zork 游戏的致敬。
const TripError = error{ Unreachable, EatenByAGrue };

// 先从地图上的地点开始。每个地点都有一个名字，以及旅行的距离或难度（由隐士评估）。
//
// 注意我们把这些地点声明为可变（var），因为稍后需要给它们赋值路径。
// 为什么要这样？因为路径包含指向地点的指针，如果现在就赋，会造成依赖循环！
const Place = struct {
    name: []const u8,
    paths: []const Path = undefined,
};

var a = Place{ .name = "Archer's Point" };
var b = Place{ .name = "Bridge" };
var c = Place{ .name = "Cottage" };
var d = Place{ .name = "Dogwood Grove" };
var e = Place{ .name = "East Pond" };
var f = Place{ .name = "Fox Pond" };

//           隐士手绘的 ASCII 地图
//  +---------------------------------------------------+
//  |         * Archer's Point                ~~~~      |
//  | ~~~                              ~~~~~~~~         |
//  |   ~~~| |~~~~~~~~~~~~      ~~~~~~~                 |
//  |         Bridge     ~~~~~~~~                       |
//  |  ^             ^                           ^      |
//  |     ^ ^                      / \                  |
//  |    ^     ^  ^       ^        |_| Cottage          |
//  |   Dogwood Grove                                   |
//  |                  ^     <boat>                     |
//  |  ^  ^  ^  ^          ~~~~~~~~~~~~~    ^   ^       |
//  |      ^             ~~ East Pond ~~~               |
//  |    ^    ^   ^       ~~~~~~~~~~~~~~                |
//  |                           ~~          ^           |
//  |           ^            ~~~ <-- short waterfall    |
//  |   ^                 ~~~~~                         |
//  |            ~~~~~~~~~~~~~~~~~                      |
//  |          ~~~~ Fox Pond ~~~~~~~    ^         ^     |
//  |      ^     ~~~~~~~~~~~~~~~           ^ ^          |
//  |                ~~~~~                              |
//  +---------------------------------------------------+
//
// 我们会根据地图上的地点数量在程序中预留内存。注意我们不需要显式指定这个值的类型，
// 因为一旦程序编译完成，我们实际上不会再用到它！（现在不理解也没关系。）
const place_count = 6;

// 现在创建站点之间的所有路径。一条路径从一个地点到另一个地点，并带有距离。
const Path = struct {
    from: *const Place,
    to: *const Place,
    dist: u8,
};

// 顺便说一句，如果下面的代码看起来像是一堆乏味的手工劳动，你没看错！
// Zig 的一大杀手级特性是允许我们编写在编译期运行的代码，以“自动化”重复代码
// （类似其他语言的宏），但我们还没学到那里！
const a_paths = [_]Path{
    Path{
        .from = &a, // from: Archer's Point
        .to = &b, //   to: Bridge
        .dist = 2,
    },
};

const b_paths = [_]Path{
    Path{
        .from = &b, // from: Bridge
        .to = &a, //   to: Archer's Point
        .dist = 2,
    },
    Path{
        .from = &b, // from: Bridge
        .to = &d, //   to: Dogwood Grove
        .dist = 1,
    },
};

const c_paths = [_]Path{
    Path{
        .from = &c, // from: Cottage
        .to = &d, //   to: Dogwood Grove
        .dist = 3,
    },
    Path{
        .from = &c, // from: Cottage
        .to = &e, //   to: East Pond
        .dist = 2,
    },
};

const d_paths = [_]Path{
    Path{
        .from = &d, // from: Dogwood Grove
        .to = &b, //   to: Bridge
        .dist = 1,
    },
    Path{
        .from = &d, // from: Dogwood Grove
        .to = &c, //   to: Cottage
        .dist = 3,
    },
    Path{
        .from = &d, // from: Dogwood Grove
        .to = &f, //   to: Fox Pond
        .dist = 7,
    },
};

const e_paths = [_]Path{
    Path{
        .from = &e, // from: East Pond
        .to = &c, //   to: Cottage
        .dist = 2,
    },
    Path{
        .from = &e, // from: East Pond
        .to = &f, //   to: Fox Pond
        .dist = 1, // （顺着小瀑布单向下行！）
    },
};

const f_paths = [_]Path{
    Path{
        .from = &f, // from: Fox Pond
        .to = &d, //   to: Dogwood Grove
        .dist = 7,
    },
};

// 一旦我们规划出穿越森林的最佳路线，就会把它做成一次“旅行”。
// 一次旅行是由一系列通过路径连接的地点构成的。
// 我们用 TripItem 联合体让地点和路径能放在同一个数组里。
const TripItem = union(enum) {
    place: *const Place,
    path: *const Path,

    // 这是一个小助手函数，用来正确打印两种不同类型的条目。
    fn printMe(self: TripItem) void {
        switch (self) {
            // 糟糕！隐士忘了在 switch 里如何捕获联合体的值。
            // 请把每个值都捕获为变量名 'p'，以便下面的打印可用！
            .place => print("{s}", .{p.name}),
            .path => print("--{}->", .{p.dist}),
        }
    }
};

// 隐士的笔记本（Hermit's Notebook）是魔法发生的地方。
// 一条笔记本条目表示：地图上发现的一个地点、到达它所走的路径、以及从起点到达它的距离。
// 如果我们找到一条更好的路径（距离更短）到达某地点，就更新该条目。
// 条目也用作“待办事项”列表，以此追踪下一步要探索的路径。
const NotebookEntry = struct {
    place: *const Place,
    coming_from: ?*const Place,
    via_path: ?*const Path,
    dist_to_reach: u16,
};

// +------------------------------------------------+
// |              ~ Hermit's Notebook ~             |
// +---+----------------+----------------+----------+
// |   |      Place     |      From      | Distance |
// +---+----------------+----------------+----------+
// | 0 | Archer's Point | null           |        0 |
// | 1 | Bridge         | Archer's Point |        2 | < next_entry
// | 2 | Dogwood Grove  | Bridge         |        1 |
// | 3 |                |                |          | < end_of_entries
// |                      ...                       |
// +---+----------------+----------------+----------+
//
const HermitsNotebook = struct {
    // 还记得数组重复操作符 `**` 吗？它可不只是个花哨玩具，
    // 也是无需一项项写就能为数组批量赋值的好办法。
    // 这里我们用它把整个数组初始化为 null。
    entries: [place_count]?NotebookEntry = .{null} ** place_count,

    // next_entry 记录我们在“待办”列表中的位置。
    next_entry: u8 = 0,

    // end_of_entries 标记笔记本中空白区域的起始位置。
    end_of_entries: u8 = 0,

    // 我们经常需要按 Place 查找条目。没找到就返回 null。
    fn getEntry(self: *HermitsNotebook, place: *const Place) ?*NotebookEntry {
        for (&self.entries, 0..) |*entry, i| {
            if (i >= self.end_of_entries) break;

            // 隐士被卡在了这里。我们需要返回“指向 NotebookEntry 的可选指针”。
            //
            // 但现在拿到的 "entry" 是相反的：它是“指向 可选 NotebookEntry 的指针”！
            //
            // 要相互转换，我们需要先解引用 entry（用 .*），
            // 再从可选值里取出非空值（用 .?），
            // 然后返回它的地址。下面的 if 提示了“解引用 + 可选解包”的写法。
            // 记得返回地址要用 & 运算符。
            if (place == entry.*.?.place) return entry;
            // 尝试把你的答案写得和这行一样长：__________;
        }
        return null;
    }

    // checkNote() 方法是这本魔法笔记本的心脏。
    // 给定一条新的笔记（NotebookEntry 结构体），我们先看是否已有该 Place 的条目。
    //
    // 如果“没有”，就把新条目（连同路径和距离）加到笔记本末尾。
    //
    // 如果“有”，就看看这条路径是否“更好”（更短距离）。
    // 如果更好，就用新条目覆盖旧条目。
    fn checkNote(self: *HermitsNotebook, note: NotebookEntry) void {
        const existing_entry = self.getEntry(note.place);

        if (existing_entry == null) {
            self.entries[self.end_of_entries] = note;
            self.end_of_entries += 1;
        } else if (note.dist_to_reach < existing_entry.?.dist_to_reach) {
            existing_entry.?.* = note;
        }
    }

    // 接下来两个方法让我们把笔记本当作“待办列表”来用。
    fn hasNextEntry(self: *HermitsNotebook) bool {
        return self.next_entry < self.end_of_entries;
    }

    fn getNextEntry(self: *HermitsNotebook) *const NotebookEntry {
        defer self.next_entry += 1; // 取出条目后再递增
        return &self.entries[self.next_entry].?;
    }

    // 当我们完成地图搜索后，就会得到到每个地点的最短路径。
    // 要收集“从起点到目的地”的完整旅行路线，我们需要从目的地的笔记条目开始，
    // 沿着 coming_from 指针一路往回走到起点。最终我们得到一个“反向顺序”的 TripItem 数组。
    //
    // 我们需要把 trip 数组作为参数传入，因为我们希望 main() 来“拥有”这块数组内存。
    // 你觉得如果我们在这个函数的栈帧里分配数组（函数的“局部”内存）并返回指针或切片，会发生什么？
    //
    // 看起来隐士在这个函数的返回值上漏了点什么。会是什么呢？
    fn getTripTo(self: *HermitsNotebook, trip: []?TripItem, dest: *Place) void {
        // 从目的地条目开始。
        const destination_entry = self.getEntry(dest);

        // 如果请求的目的地从未被到达，这个函数需要返回一个错误。
        // （在我们的地图里这实际上不会发生，因为每个地点都能由其他任何地点到达。）
        if (destination_entry == null) {
            return TripError.Unreachable;
        }

        // current_entry 保存当前检查的条目；i 用来记录向 trip 里追加条目的位置。
        var current_entry = destination_entry.?;
        var i: u8 = 0;

        // 每次循环结束时，continue 表达式把索引加一。
        // 能看出为什么我们要加 2 吗？
        while (true) : (i += 2) {
            trip[i] = TripItem{ .place = current_entry.place };

            // 如果“来自于（coming_from）”为空，说明我们到了起点，结束。
            if (current_entry.coming_from == null) break;

            // 否则，这个条目一定带有一条路径。
            trip[i + 1] = TripItem{ .path = current_entry.via_path.? };

            // 现在跟着“来自于”的条目继续往回找。
            // 如果按 Place 找不到它，那程序就出大问题了！
            // （这基本不该发生。你确定没有被 Grue 吃掉吗？）
            // 注意：你不需要修改这里的任何东西。
            const previous_entry = self.getEntry(current_entry.coming_from.?);
            if (previous_entry == null) return TripError.EatenByAGrue;
            current_entry = previous_entry.?;
        }
    }
};

pub fn main() void {
    // 隐士决定他想去哪儿。一旦你让程序跑起来，试试地图上的其他地点！
    const start = &a; // Archer's Point
    const destination = &f; // Fox Pond

    // 把每个 Path 数组以切片形式放进各自的 Place 里。
    // 如前所述，我们需要推迟这些引用的建立，以免编译器在分配每个条目的空间时遇到依赖循环。
    a.paths = a_paths[0..];
    b.paths = b_paths[0..];
    c.paths = c_paths[0..];
    d.paths = d_paths[0..];
    e.paths = e_paths[0..];
    f.paths = f_paths[0..];

    // 创建一本笔记本，并加入第一个“起点”条目。注意其中的 null 值。
    // 上面 checkNote() 的注释解释了这个条目是如何加入笔记本的。
    var notebook = HermitsNotebook{};
    var working_note = NotebookEntry{
        .place = start,
        .coming_from = null,
        .via_path = null,
        .dist_to_reach = 0,
    };
    notebook.checkNote(working_note);

    // 不断从笔记本里取下一个条目（第一个是刚加的起点），直到取完为止；
    // 这时我们就检查完所有可达的地点了。
    while (notebook.hasNextEntry()) {
        const place_entry = notebook.getNextEntry();

        // 对于当前地点的每一条“出发路径（FROM）”，创建一条新笔记（NotebookEntry），
        // 记录目标地点和从起点到达该地的总距离。再读一读上面对 checkNote() 的注释看看它怎么工作的。
        for (place_entry.place.paths) |*path| {
            working_note = NotebookEntry{
                .place = path.to,
                .coming_from = place_entry.place,
                .via_path = path,
                .dist_to_reach = place_entry.dist_to_reach + path.dist,
            };
            notebook.checkNote(working_note);
        }
    }

    // 当上面的循环完成后，我们已经计算出到每个可达地点的最短路径！
    // 现在需要为旅行预留内存，然后让隐士的笔记本把“从终点回溯到起点”的旅行路线填入。
    // 注意这还是我们第一次真正用到 destination！
    var trip = [_]?TripItem{null} ** (place_count * 2);

    notebook.getTripTo(trip[0..], destination) catch |err| {
        print("Oh no! {}\n", .{err});
        return;
    };

    // 用下面的小助手函数打印旅行路线。
    printTrip(trip[0..]);
}

// 记住，旅行是一系列交替的 TripItem（Place 或 Path），它们从终点一路回到起点。
// 数组里剩余的空间会是 null 值，所以我们需要反向遍历，跳过 null，
// 直到到达数组前端的起点。
fn printTrip(trip: []?TripItem) void {
    // 用内建函数 @intCast() 把 usize 长度转换成 u8（就像 @import() 一样，都是内建函数）。
    // 我们会在后面的练习中系统学习这些内容。
    var i: u8 = @intCast(trip.len);

    while (i > 0) {
        i -= 1;
        if (trip[i] == null) continue;
        trip[i].?.printMe();
    }

    print("\n", .{});
}

// 更深入一点：
//
// 在计算机科学术语中，地图上的地点是“节点（nodes）”或“顶点（vertices）”，路径是“边（edges）”。
// 它们一起组成一个“加权有向图（weighted, directed graph）”。“加权”是因为每条路径有距离（也叫“代价”）。
// “有向”是因为路径从一个地方到另一个地方（无向图允许在一条边上双向通行）。
//
// 由于我们把新条目附加在列表末尾，并从头开始按顺序探索（类似“待办队列”），
// 我们把笔记本当作“先进先出（FIFO）队列”。
//
// 因为我们总是先探索更近的路径，才去尝试更远的路径（多亏了“待办队列”），
// 我们实际上在执行“广度优先搜索（BFS）”。
//
// 通过跟踪“最小代价”的路径，也可以说我们在做“最小代价搜索（least-cost search）”。
//
// 更具体地说，隐士的笔记本最像“最短路径快速算法（SPFA）”，归功于 Edward F. Moore。
// 如果我们把简单的 FIFO 队列换成“优先队列（priority queue）”，基本上就得到 Dijkstra 算法。
// 优先队列会按“权重”排序（在这里是路径距离），把最短的放在最前面。
// Dijkstra 算法更高效，因为可以更快地排除更长的路径。（不妨在纸上推演一下为什么！）
