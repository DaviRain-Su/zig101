//
// 枚举 (enum) 本质上就是一组数字。
// 你可以把编号交给编译器自动分配，
// 也可以显式地给它们赋值。
// 甚至还可以指定使用的数值类型。
//
//     const Stuff = enum(u8){ foo = 16 };
//
// 你可以用内建函数 @intFromEnum() 把枚举值转成整数。
// 我们会在后面的练习里正式学习这些内建函数。
//
//     const my_stuff: u8 = @intFromEnum(Stuff.foo);
//
// 注意到这个内建函数和我们用过的 @import() 一样，
// 都是以 "@" 开头的。
//
const std = @import("std");

// Zig 允许我们用十六进制写整数：
//
//     0xf   (在十六进制里代表十进制的 15)
//
// Web 浏览器允许我们用十六进制的数字来指定颜色，
// 其中每个字节代表一个颜色分量的亮度值 (RGB)。
// 两位十六进制数就是一个字节，范围 0-255：
//
//     #RRGGBB
//
// 请定义并使用一个纯蓝色 (pure blue) 的 Color 值：
const Color = enum(u32) {
    red = 0xff0000,
    green = 0x00ff00,
    blue = ???,
};

pub fn main() void {
    // 还记得 Zig 的多行字符串吗？这里又用到了。
    // 另外，看看这个很酷的格式字符串：
    //
    //     {x:0>6}
    //      ^
    //      x       类型 ('x' 表示小写十六进制)
    //       :      分隔符（格式语法需要）
    //        0     填充字符（默认是空格）
    //         >    对齐方式（'>' 表示右对齐）
    //          6   宽度（用填充来强制宽度）
    //
    // 请把这个格式应用到 blue 值上。
    // （更好的是，试试去掉它，或者只改部分，看看会输出什么！）
    std.debug.print(
        \\<p>
        \\  <span style="color: #{x:0>6}">Red</span>
        \\  <span style="color: #{x:0>6}">Green</span>
        \\  <span style="color: #{}">Blue</span>
        \\</p>
        \\
    , .{
        @intFromEnum(Color.red),
        @intFromEnum(Color.green),
        @intFromEnum(???), // 哎呀！这里还缺点东西！
    });
}
