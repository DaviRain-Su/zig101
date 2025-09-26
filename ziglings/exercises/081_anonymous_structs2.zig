//
// 匿名结构体的值字面量（不要与结构体类型混淆）使用 '.{}' 语法：
//
//     .{
//          .center_x = 15,
//          .center_y = 12,
//          .radius = 6,
//     }
//
// 这些字面量总是在编译期完全计算。
// 上面的例子可以被强制转换为上一个练习中的 “circle 结构体”的 i32 版本。
//
// 或者你也可以让它们保持完全匿名，比如这个例子：
//
//     fn bar(foo: anytype) void {
//         print("a:{} b:{}\n", .{foo.a, foo.b});
//     }
//
//     bar(.{
//         .a = true,
//         .b = false,
//     });
//
// 上面的例子会打印 "a:true b:false"。
//
const print = @import("std").debug.print;

pub fn main() void {
    printCircle(.{
        .center_x = @as(u32, 205),
        .center_y = @as(u32, 187),
        .radius = @as(u32, 12),
    });
}

// 请完成这个函数，用来打印一个表示圆的匿名结构体。
fn printCircle(???) void {
    print("x:{} y:{} radius:{}\n", .{
        circle.center_x,
        circle.center_y,
        circle.radius,
    });
}
