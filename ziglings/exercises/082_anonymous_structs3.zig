//
// 你甚至可以创建没有字段名的匿名结构体字面量：
//
//     .{
//         false,
//         @as(u32, 15),
//         @as(f64, 67.12)
//     }
//
// 我们称这些为 “元组（tuple）”，这个术语在很多编程语言里都用来表示一种
// 数据类型，其字段通过索引顺序而不是名字来引用。为了实现这个功能，Zig
// 编译器会自动给这些结构体分配数字字段名 0, 1, 2, 等等。
//
// 由于裸数字不是合法的标识符（foo.0 是语法错误），所以我们必须用 @"" 语法
// 来引用它们。例如：
//
//     const foo = .{ true, false };
//
//     print("{} {}\n", .{foo.@"0", foo.@"1"});
//
// 上面的例子会打印 "true false"。
//
// 嘿，等一下……
//
// 如果 .{} 本身就是 print 函数想要的，那我们还需要把 “元组” 拆开再放进另
// 一个里面吗？不！这太多余了！这段代码会打印相同的内容：
//
//     print("{} {}\n", foo);
//
// 啊哈！所以我们现在知道 print() 接收的是一个 “元组”。事情开始逐渐明朗了。
//
const print = @import("std").debug.print;

pub fn main() void {
    // 一个 “元组”：
    const foo = .{
        true,
        false,
        @as(i32, 42),
        @as(f32, 3.141592),
    };

    // 我们要实现这个：
    printTuple(foo);

    // 只是为了好玩，因为我们可以这样写：
    const nothing = .{};
    print("\n", nothing);
}

// 我们来写一个自己的通用 “元组” 打印器。它应该接收一个 “元组”，
// 并按以下格式打印出每个字段：
//
//     "name"(type):value
//
// 示例：
//
//     "0"(bool):true
//
// 你需要把它拼接起来。但别担心，所需的一切都在注释里说明了。
fn printTuple(tuple: anytype) void {
    // 1. 获取输入参数 'tuple' 的字段列表。你需要：
    //
    //     @TypeOf() - 接收一个值，返回它的类型。
    //
    //     @typeInfo() - 接收一个类型，返回一个 TypeInfo 联合，里面包含该类型的特定字段信息。
    //
    //     结构体类型的字段列表可以在 TypeInfo 的 @"struct".fields 里找到。
    //
    //     示例：
    //
    //         @typeInfo(Circle).@"struct".fields
    //
    // 这将会得到一个 StructFields 数组。
    const fields = ???;

    // 2. 遍历每个字段。必须在编译期完成。
    //
    //     提示：还记得 'inline' 循环吗？
    //
    for (fields) |field| {
        // 3. 打印字段的名字、类型和值。
        //
        //     在这个循环中，每个 'field' 是下面这样的结构：
        //
        //         pub const StructField = struct {
        //             name: [:0]const u8,
        //             type: type,
        //             default_value_ptr: ?*const anyopaque,
        //             is_comptime: bool,
        //             alignment: comptime_int,
        //         };
        //
        //     注意：我们稍后会学习 'anyopaque' 类型。
        //
        //     你需要用到这个内建函数：
        //
        //         @field(lhs: anytype, comptime field_name: []const u8)
        //
        //     第一个参数是要访问的值，第二个参数是字段名字（字符串），
        //     函数会返回该字段的值。
        //
        //     示例：
        //
        //         @field(foo, "x"); // 返回 foo.x 的值
        //
        // 第一个字段的打印结果应该是： "0"(bool):true
        print("\"{s}\"({any}):{any} ", .{
            field.???,
            field.???,
            ???,
        });
    }
}
