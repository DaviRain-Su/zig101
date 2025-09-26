//
// 你也可以在函数参数前加上 `comptime`，
// 强制要求传入的实参必须在 **编译期** 就确定。
// 其实我们一直在用这样的函数 —— 例如 `std.debug.print()`：
//
//     fn print(comptime fmt: []const u8, args: anytype) void
//
// 注意到这里的格式字符串参数 `fmt` 被标记为了 `comptime`。
// 这带来一个好处：**格式字符串可以在编译期检查错误**，
// 而不是等到运行时报错或崩溃。
//
// （实际的格式化工作是由 `std.fmt.format()` 完成的，
// 它包含了一个完整的 **格式字符串解析器**，
// 并且整个解析过程都在编译期完成！）
//
const print = @import("std").debug.print;

// 这个结构体是一个帆船模型。
// 我们可以将它缩放到任意比例：
// 例如 1:2 表示一半大小，1:32 表示缩小 32 倍，等等。
const Schooner = struct {
    name: []const u8,
    scale: u32 = 1,
    hull_length: u32 = 143,
    bowsprit_length: u32 = 34,
    mainmast_height: u32 = 95,

    fn scaleMe(self: *Schooner, comptime scale: u32) void {
        comptime var my_scale = scale;

        // 我们在这里做了一件巧妙的事：
        // 提前考虑了可能会有人不小心设置比例 1:0 的情况。
        // 与其在运行时触发除零错误，
        // 我们选择在编译时报错。
        //
        // 这通常是正确的做法。
        // 但在我们的「模型帆船模型程序」里，
        // 我们希望它能「理解我的意思」并继续运行。
        //
        // 请改成：如果比例为 0，就设为 1。
        if (my_scale == 0) @compileError("比例 1:0 无效！");

        self.scale = my_scale;
        self.hull_length /= my_scale;
        self.bowsprit_length /= my_scale;
        self.mainmast_height /= my_scale;
    }

    fn printMe(self: Schooner) void {
        print("{s} (1:{}, {} x {})\n", .{
            self.name,
            self.scale,
            self.hull_length,
            self.mainmast_height,
        });
    }
};

pub fn main() void {
    var whale = Schooner{ .name = "Whale" };
    var shark = Schooner{ .name = "Shark" };
    var minnow = Schooner{ .name = "Minnow" };

    // 注意：我们不能直接把这个运行期变量作为参数
    // 传给 `scaleMe()` 方法。那要怎么做呢？
    var scale: u32 = undefined;

    scale = 32; // 1:32 比例

    minnow.scaleMe(scale);
    minnow.printMe();

    scale -= 16; // 1:16 比例

    shark.scaleMe(scale);
    shark.printMe();

    scale -= 16; // 1:0 比例（哎呀，但 **不要修复这个！**）

    whale.scaleMe(scale);
    whale.printMe();
}
//
// 更深入思考：
//
// 如果你真的尝试做一个比例为 1:0 的模型，会发生什么？
//
//    A) 你已经完成了！
//    B) 你会遭受精神上的除零错误。
//    C) 你将制造一个奇点并毁灭地球。
//
// 那么比例为 0:1 呢？
//
//    A) 你已经完成了！
//    B) 你会把「无」精心安排成原本的「无」但无限放大。
//    C) 你将制造一个奇点并毁灭地球。
//
// 答案可以在 Ziglings 包装盒背面找到。
