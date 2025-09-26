//
// 小测验时间！
//
// 让我们回顾一下 **隐士的地图**（Quiz 7 里的题目）。
//
// 哦，别担心，没有了那些长篇大论的解释性注释，代码没那么庞大。
// 而且这次我们只需要改动其中的一部分。
//
const print = @import("std").debug.print;

const TripError = error{ Unreachable, EatenByAGrue };

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

// 还记得我们当时不需要声明 `place_count` 的具体数值类型吗？
// 因为它只会在编译期使用。
// 现在是不是更好理解了？ :-)
const place_count = 6;

const Path = struct {
    from: *const Place,
    to: *const Place,
    dist: u8,
};

// 好的，你可能还记得，当时我们必须手动创建每一条 Path，
// 每一个 Path 都要写整整 5 行代码：
//
//    Path{
//        .from = &a, // 起点: Archer's Point
//        .to = &b,   // 终点: Bridge
//        .dist = 2,
//    },
//
// 但是现在我们有了编译期执行的知识，
// 也许可以用一个简单的函数来简化这些代码。
//
// 请补全这个函数体！
fn makePath(from: *Place, to: *Place, dist: u8) Path {}

// 使用新函数后，这些路径的定义在程序里占用的空间明显更少了！
const a_paths = [_]Path{makePath(&a, &b, 2)};
const b_paths = [_]Path{ makePath(&b, &a, 2), makePath(&b, &d, 1) };
const c_paths = [_]Path{ makePath(&c, &d, 3), makePath(&c, &e, 2) };
const d_paths = [_]Path{ makePath(&d, &b, 1), makePath(&d, &c, 3), makePath(&d, &f, 7) };
const e_paths = [_]Path{ makePath(&e, &c, 2), makePath(&e, &f, 1) };
const f_paths = [_]Path{makePath(&f, &d, 7)};
//
// 但是这样写真的更易读吗？这可是见仁见智的。
//
// 我们已经见过可以在编译期解析字符串，
// 所以理论上能做的事情无限多，花哨程度随你发挥。
//
// 举个例子，我们甚至可以自定义一种“路径语言”，
// 用它来生成 Path，比如这样：
//
//    a -> (b[2])
//    b -> (a[2] d[1])
//    c -> (d[3] e[2])
//    ...
//
// 如果你愿意，可以把它当成一个 **超级加分练习** 来实现！
