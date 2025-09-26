//
// 在 Zig 中，标准库的功能变得越来越重要。
// 首先，看看标准库中各个函数是如何实现的，这是非常有帮助的，
// 因为它们非常适合作为自己编写函数的模板。
// 而且，这些标准函数是 Zig 基本配置的一部分。
//
// 这意味着它们在任何系统上都始终可用。
// 因此，在 Ziglings 中研究它们非常值得。
// 这是学习重要技能的好方法。
// 例如，经常需要处理文件中的大量数据。
// 为此，Zig 提供了一些有用的函数来进行顺序读取和处理，
// 我们会在接下来的练习中更仔细地研究它们。
//
// Zig 官方主页上发布了一个很好的示例，替代了有点“老旧”的 `Hello world!`
//
// 并不是说 `Hello world!` 不好，
// 但它无法体现 Zig 的优雅。
// 如果有人第一次访问主页，
// 看到的只是一个简单的 Hello world，未免可惜。
// 而这个示例则更适合作为入门展示。
// 因此我们会用它来引入 **分词 (tokenizing)** 的概念，
// 因为它非常适合理解基本原理。
//
// 在后续练习中，我们还会从大文件中读取和处理数据，
// 到那时你就会真正明白这些功能有多么实用。
//
// 下面我们先分析主页上的示例，并解释其中最重要的部分。
//
//    const std = @import("std");
//
//    // 这里定义了一个标准库函数，
//    // 用来把字符串里的数字转换成整数值。
//    const parseInt = std.fmt.parseInt;
//
//    // 定义一个测试用例
//    test "parse integers" {
//
//        // 输入字符串里包含四个数字。
//        // 注意：数字之间用空格或逗号分隔。
//        const input = "123 67 89,99";
//
//        // 为了处理这些输入值，需要内存。
//        // 这里定义了一个分配器 (allocator)。
//        const ally = std.testing.allocator;
//
//        // 用分配器初始化一个数组列表 (ArrayList)，
//        // 用来存储这些数字。
//        var list = std.ArrayList(u32).init(ally);
//
//        // 确保最后会释放内存，避免忘记。
//        defer list.deinit();
//
//        // 现在进入关键部分：
//        // 使用标准的分词器 (tokenizer)，
//        // 它会找到分隔符（空格和逗号）的位置，
//        // 然后传递给迭代器。
//        var it = std.mem.tokenizeAny(u8, input, " ,");
//
//        // 迭代器可以在循环中逐个处理分词，
//        // 并把它们转换为整数。
//        while (it.next()) |num| {
//            // 注意：这里的数字还是字符串。
//            // 我们需要用整数解析器把它们转换成真正的整数。
//            const n = try parseInt(u32, num, 10);
//
//            // 最后，把每个数值存入数组。
//            try list.append(n);
//        }
//
//        // 为测试准备一个静态数组，直接填入期望值。
//        const expected = [_]u32{ 123, 67, 89, 99 };
//
//        // 将解析出来的数字和期望值逐个比较，
//        // 如果完全一致，测试通过。
//        for (expected, list.items) |exp, actual| {
//            try std.testing.expectEqual(exp, actual);
//        }
//    }
//
// 上面就是主页示例的全部内容。
// 我们总结一下基本步骤：
//
// - 有一组顺序排列的数据，它们之间由分隔符分开。
// - 要进一步处理这些数据（例如存入数组），需要先分隔并在必要时转换格式。
// - 我们需要一个足够大的缓冲区来存储这些数据。
// - 如果数据量在编译时已知，可以静态分配；否则需要在运行时通过内存分配器动态分配。
// - 使用 Tokenizer 根据分隔符把数据切分，并存入内存。通常还要转换成目标格式。
// - 最终，数据以正确的格式存放，就能方便地继续处理。
//
// 这些步骤基本上都是通用的。
// 数据可能来自文件，也可能来自键盘输入，区别只是细节。
// 所以 Zig 提供了不同的分词器来处理这些情况，
// 后续练习里我们会介绍更多。
//
// 现在我们也来写一个小程序来做分词练习。
// 假设我们要统计这首小诗里有多少个单词：
//
//      My name is Ozymandias, King of Kings;
//      Look on my Works, ye Mighty, and despair!
//            by Percy Bysshe Shelley
//
//
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {

    // 输入
    const poem =
        \\My name is Ozymandias, King of Kings;
        \\Look on my Works, ye Mighty, and despair!
    ;

    // 使用分词器，但需要指定分隔符。
    var it = std.mem.tokenizeAny(u8, poem, ???);

    // 打印所有单词并统计数量
    var cnt: usize = 0;
    while (it.next()) |word| {
        cnt += 1;
        print("{s}\n", .{word});
    }

    // 打印结果
    print("This little poem has {d} words!\n", .{cnt});
}
