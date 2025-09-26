//
// ------------------------------------------------------------
//  绝密  绝密  绝密  绝密  绝密
// ------------------------------------------------------------
//
// 你准备好接受关于 Zig 字符串字面量的 **真相** 了吗？
//
// 真相如下：
//
//     @TypeOf("foo") == *const [3:0]u8
//
// 这意味着一个字符串字面量是：
// **“指向零结尾（空结尾）固定大小 u8 数组的常量指针”。**
//
// 现在你知道了。你赢得了它。欢迎加入秘密俱乐部！
//
// ------------------------------------------------------------
//
// 那么，既然 Zig 已经知道字符串的长度，为什么还要用零/空哨兵来终止字符串呢？
//
// **灵活性！** Zig 字符串兼容 C 字符串（它们是空结尾的），
// 并且可以强制转换成多种其他 Zig 类型：
//
//     const a: [5]u8 = "array".*;
//     const b: *const [16]u8 = "pointer to array";
//     const c: []const u8 = "slice";
//     const d: [:0]const u8 = "slice with sentinel";
//     const e: [*:0]const u8 = "many-item pointer with sentinel";
//     const f: [*]const u8 = "many-item pointer";
//
// 除了 `f`，其他都可以打印。
// （一个没有哨兵的多项指针是不安全打印的，因为我们不知道它在哪里结束！）
//
const print = @import("std").debug.print;

const WeirdContainer = struct {
    data: [*]const u8,
    length: usize,
};

pub fn main() void {
    // WeirdContainer 是一种非常别扭的字符串存放方式。
    //
    // 作为一个没有哨兵结尾的多项指针，
    // `data` 字段“丢失”了字符串字面量 "Weird Data!" 的
    // 长度信息和结尾哨兵。
    //
    // 幸运的是，`length` 字段让我们仍然可以操作这个值。
    const foo = WeirdContainer{
        .data = "Weird Data!",
        .length = 11,
    };

    // 那么我们该如何从 `foo` 得到一个可打印的值呢？
    // 一种方法是把它转换成带有已知长度的东西。
    // 我们确实有一个长度……其实你以前已经解决过类似问题了！
    //
    // 大提示：你还记得怎么截取一个切片吗？
    const printable = ???;

    print("{s}\n", .{printable});
}
