//
// 到目前为止，我们只是在控制台打印输出，
// 这已经足够用来打外星人和记录隐士账簿了。
//
// 但是，许多其他任务需要与文件系统交互。
// 文件系统是你电脑上组织文件的底层结构。
//
// 文件系统提供了一种分层结构来存储文件：
// 通过把文件放入目录（目录里可以包含文件或其他目录），
// 从而形成一棵可导航的树。
//
// 幸运的是，Zig 标准库提供了一个简单的 API
// 用于与文件系统交互，详细文档见：
//
// https://ziglang.org/documentation/master/std/#std.fs
//
// 在本练习中，我们会尝试：
//   - 创建一个新目录
//   - 在目录中打开一个文件
//   - 向文件写入内容
//

// 一如既往，先导入 std
const std = @import("std");

pub fn main() !void {
    // 首先获取当前工作目录
    const cwd: std.fs.Dir = std.fs.cwd();

    // 然后尝试创建一个新的目录 /output/
    // 用来存放我们的输出文件
    cwd.makeDir("output") catch |e| switch (e) {
        // 你可能会多次运行这个程序，
        // 如果路径已经存在，就会报错。
        // 所以我们需要处理这个错误：什么都不做。
        //
        // 我们要捕获 error.PathAlreadyExists 并忽略它。
        error.PathAlreadyExists => {},
        // 其他意料之外的错误直接向上抛出
        else => return e,
    };

    // 接着尝试打开刚刚创建的目录
    // 等等……打开目录也可能失败！
    // 我们该怎么处理呢？
    var output_dir: std.fs.Dir = try cwd.openDir("output", .{});
    defer output_dir.close();

    // 尝试打开文件 `zigling.txt`，
    // 如果失败则把错误传递出去
    const file: std.fs.File = try output_dir.createFile("zigling.txt", .{});
    // 一个好习惯是：在用完文件后关闭它，
    // 这样其他程序就可以安全读取，避免数据损坏。
    // 不过我们现在还没写入内容。
    // 要是 Zig 有一个关键字能“延迟”代码执行到作用域结束就好了……
    defer file.close();

    // 注意！不允许把下面两行代码移动到文件关闭之前！
    const byte_written = try file.write("It's zigling time!");
    std.debug.print("成功写入 {d} 字节。\n", .{byte_written});
}
//
// 如何检查文件是否真的写入成功？
// 1. 用文本编辑器打开文件
// 2. 或者在控制台里查看：
//    Linux/macOS:   >> cat ./output/zigling.txt
//    Windows (CMD): >> type .\output\zigling.txt
//
//
// 更多关于创建文件的说明：
//
// 注意这一行：
// ... try output_dir.createFile("zigling.txt", .{});
//                                              ^^^
//                 我们给函数传入了一个匿名结构体
//
// 这个匿名结构体其实是 `CreateFlag`，它的默认字段是：
//
// {
//      read: bool = false,       // 是否允许读
//      truncate: bool = true,    // 是否清空原文件
//      exclusive: bool = false,  // 是否要求文件必须不存在
//      lock: Lock = .none,       // 文件锁选项
//      lock_nonblocking: bool = false,
//      mode: Mode = default_mode // 权限模式
// }
//
// 问题：
//   - 如果想在打开文件后还能读取内容，该怎么设置？
//   - 打开文档中 `std.fs.Dir` 的说明：
//     https://ziglang.org/documentation/master/std/#std.fs.Dir
//       - 你能找到用于打开文件的函数吗？用于删除文件的函数呢？
//       - 这些函数都有哪些可用的选项？
