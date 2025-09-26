//
// 先决条件：
//    - exercise/106_files.zig，或者
//    - 在 {project_root}/output/ 下创建一个文件 zigling.txt
//      其内容为 `It's zigling time!`（共 18 字节）
//
// 如果我们写入文件却不读取，那还有什么意义？对吧？
// 让我们写一个程序来读取刚才创建的文件的内容。
//
// 我假设你已经为此创建了相应的文件。
//
// 好的，小伙子，靠近点。计划如下：
//    - 首先，我们打开 {project_root}/output/ 目录
//    - 其次，我们在该目录下打开文件 `zigling.txt`
//    - 然后，我们用字母 'A' 初始化一个字符数组，并打印它
//    - 接下来，我们将文件的内容读入该数组
//    - 最后，我们打印出刚读取到的内容
//

const std = @import("std");

pub fn main() !void {
    // 获取当前工作目录
    const cwd = std.fs.cwd();

    // 尝试打开 ./output，假设你已经完成了 106_files 练习
    var output_dir = try cwd.openDir("output", .{});
    defer output_dir.close();

    // 尝试打开文件
    const file = try output_dir.openFile("zigling.txt", .{});
    defer file.close();

    // 用全部为字母 'A' 的 u8 数组进行初始化
    // 我们需要选择数组大小，64 看起来是个不错的数字
    // 修复下面的初始化
    var content = ['A']*64;
    // 这应该打印出：`AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA`
    std.debug.print("{s}\n", .{content});

    // 好吧，看来用暴力威胁并不是解决办法
    // 你可以在这里找到读取内容的方法吗？
    // https://ziglang.org/documentation/master/std/#std.fs.File
    // 提示：在这种情况下你可能会找到两种都有效的答案
    const bytes_read = zig_read_the_file_or_i_will_fight_you(&content);

    // 哇，太大声了。我知道你对 zigling 时刻很激动，但收敛一点。
    // 你能只打印我们从文件中读取的内容吗？
    std.debug.print("成功读取 {d} 字节：{s}\n", .{
        bytes_read,
        content, // 仅修改此行以打印已读取的部分
    });
}
