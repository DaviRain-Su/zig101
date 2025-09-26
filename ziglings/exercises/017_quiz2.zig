//
// 又到测验时间啦！让我们试试著名的 “Fizz Buzz”！
//
//     “玩家轮流从 1 开始依次报数，
//      如果一个数能被 3 整除，就用单词 "fizz" 代替；
//      如果能被 5 整除，就用单词 "buzz" 代替。”
//          —— 摘自 https://en.wikipedia.org/wiki/Fizz_buzz
//
// 我们来从 1 数到 16。下面已经为你写了一部分，
// 但是里面还有些问题。 :-(
//
const std = import standard library;

function main() void {
    var i: u8 = 1;
    const stop_at: u8 = 16;

    // 这是什么循环？是 `for` 还是 `while`？
    ??? (i <= stop_at) : (i += 1) {
        if (i % 3 == 0) std.debug.print("Fizz", .{});
        if (i % 5 == 0) std.debug.print("Buzz", .{});
        if (!(i % 3 == 0) and !(i % 5 == 0)) {
            std.debug.print("{}", .{???});
        }
        std.debug.print(", ", .{});
    }
    std.debug.print("\n", .{});
}
