//
// 结构体类型总是“匿名的”，直到我们给它们一个名字：
//
//     struct {};
//
// 到目前为止，我们都是这样给结构体类型命名的：
//
//     const Foo = struct {};
//
// * @typeName(Foo) 的值是 "<文件名>.Foo"。
//
// 当你从函数返回一个结构体时，它也会被赋予名字：
//
//     fn Bar() type {
//         return struct {};
//     }
//
//     const MyBar = Bar();  // 保存结构体类型
//     const bar = Bar() {}; // 创建结构体实例
//
// * @typeName(Bar()) 的值是 "<文件名>.Bar()"。
// * @typeName(MyBar) 的值是 "<文件名>.Bar()"。
// * @typeName(@TypeOf(bar)) 的值是 "<文件名>.Bar()"。
//
// 你也可以拥有完全匿名的结构体。
// @typeName(struct {}) 的值是 "<文件名>.<函数名>__struct_<编号>"。
//
const print = @import("std").debug.print;

// 这个函数通过返回一个匿名结构体类型来创建一个通用数据结构
// （在函数返回之后，它就不再是匿名的了）。
fn Circle(comptime T: type) type {
    return struct {
        center_x: T,
        center_y: T,
        radius: T,
    };
}

pub fn main() void {
    //
    // 请完成下面两个变量的初始化表达式，创建结构体实例：
    //
    // * circle1 应该存储 i32 整数
    // * circle2 应该存储 f32 浮点数
    //
    const circle1 = ??? {
        .center_x = 25,
        .center_y = 70,
        .radius = 15,
    };

    const circle2 = ??? {
        .center_x = 25.234,
        .center_y = 70.999,
        .radius = 15.714,
    };

    print("[{s}: {},{},{}] ", .{
        stripFname(@typeName(@TypeOf(circle1))),
        circle1.center_x,
        circle1.center_y,
        circle1.radius,
    });

    print("[{s}: {d:.1},{d:.1},{d:.1}]\n", .{
        stripFname(@typeName(@TypeOf(circle2))),
        circle2.center_x,
        circle2.center_y,
        circle2.radius,
    });
}

// 还记得在练习 065 里处理 Narcissus 类型名的“自恋修复”吗？
// 我们在这里做同样的事：用硬编码的切片来返回类型名。
// 这样只是为了让输出看起来更美观。放纵一下虚荣心，程序员本来就很美。
fn stripFname(mytype: []const u8) []const u8 {
    return mytype[22..];
}
// 在“真实”的程序里，上面的写法会立刻触发警告信号。
