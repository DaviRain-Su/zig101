//
// Zig 提供了一些用于数学运算的内建函数，比如…
//
//      @sqrt        @sin           @cos
//      @exp         @log           @floor
//
// …以及许多类型转换的内建函数，比如…
//
//      @as          @errorFromInt  @floatFromInt
//      @ptrFromInt  @intFromPtr    @intFromEnum
//
// 在一个雨天花点时间翻翻 Zig 官方文档里的完整内建函数列表
// 并不是什么坏事。里面有一些非常酷的功能。
// 去看看 @call, @compileLog, @embedFile, 和 @src 吧！
//
//                            ...
//
// 现在，我们将通过探索 Zig 的**三个**内建自省功能，
// 来完成对内建函数的初步了解：
//
// 1. @This() 类型
//
// 返回某个函数调用所处的最内层 struct、enum 或 union。
//
// 2. @typeInfo(comptime T: type) @import("std").builtin.Type
//
// 返回关于任意类型的信息，具体包含什么取决于你检查的类型。
//
// 3. @TypeOf(...) type
//
// 返回输入参数的公共类型（每个参数可以是任意表达式）。
// 类型是通过编译器自己的“同类类型推导”过程解析的。
//
// （注意到这两个返回类型的函数名字首字母大写了吗？
// 这是 Zig 的标准命名惯例。）
//
const print = @import("std").debug.print;

const Narcissus = struct {
    me: *Narcissus = undefined,
    myself: *Narcissus = undefined,
    echo: void = undefined, // 可怜的 Echo！

    fn fetchTheMostBeautifulType() type {
        return @This();
    }
};

pub fn main() void {
    var narcissus: Narcissus = Narcissus{};

    // 哎呀！我们不能把 'me' 和 'myself' 字段留空。
    // 请在这里设置它们：
    narcissus.me = &narcissus;
    narcissus.??? = ???;

    // 这里通过三个引用来推导出一个“同类类型”
    // （它们恰好都是同一个对象）。
    const Type1 = @TypeOf(narcissus, narcissus.me.*, narcissus.myself.*);

    // 糟糕！我们调用这个函数时弄错了。
    // 我们把它当作方法调用了，而这只有在它有 self 参数时才行。
    // （见上面的定义。）
    //
    // 修复方法很微妙，但区别很大！
    const Type2 = narcissus.fetchTheMostBeautifulType();

    // 现在我们打印一句关于纳西瑟斯的俏皮话。
    print("一个 {s} 爱着所有 {s}们。 ", .{
        maximumNarcissism(Type1),
        maximumNarcissism(Type2),
    });

    //   当他凝望着自己熟悉的水面时
    //   他的最后一句话是：
    //       “唉，我心爱的少年啊，徒然！”
    //   水面回荡着他的每一个字。
    //   他哭喊：
    //            “永别了。”
    //   而 Echo 回应：
    //                   “永别了！”
    //
    //     ——奥维德，《变形记》
    //        伊恩·约翰斯顿译

    print("他心中所容纳的是：", .{});

    // 一个 StructFields 数组
    const fields = @typeInfo(Narcissus).@"struct".fields;

    // 'fields' 是一个 StructField 切片。声明如下：
    //
    //     pub const StructField = struct {
    //         name: [:0]const u8,
    //         type: type,
    //         default_value_ptr: ?*const anyopaque,
    //         is_comptime: bool,
    //         alignment: comptime_int,
    //
    //         defaultValue() ?sf.type  // 用于加载字段默认值的函数
    //     };
    //
    // 请完成下面的 'if' 语句：
    // 如果字段类型是 void（零位类型，不占空间），就不要打印它的名字。
    if (fields[0].??? != void) {
        print(" {s}", .{fields[0].name});
    }

    if (fields[1].??? != void) {
        print(" {s}", .{fields[1].name});
    }

    if (fields[2].??? != void) {
        print(" {s}", .{fields[2].name});
    }

    // 哎呀，看看上面那一堆重复的代码！
    // 我不知道你怎么样，但我看着就浑身难受。
    //
    // 可惜这里不能用常规的 'for' 循环，
    // 因为 'fields' 只能在编译期计算。
    // 看来我们是时候学习一下“comptime”了，对吧？
    // 别担心，我们很快就会学到。
    print(".\n", .{});
}

// 注意：这个练习原本没有下面这个函数。
// 但在 Zig 0.10.0 之后，类型名前加上了源文件名。
// “Narcissus” 变成了 “065_builtins2.Narcissus”。
//
// 为了解决这个问题，我们加了一个函数，
// 去掉类型名前的文件名前缀。
// （它返回从 “.” 之后开始的那部分切片。）
//
// 我们会在练习 070 再次看到 @typeName。
// 目前你只需要知道它接受一个类型，返回一个 u8 字符串。
fn maximumNarcissism(myType: anytype) []const u8 {
    const indexOf = @import("std").mem.indexOf;

    // 把 "065_builtins2.Narcissus" 变成 "Narcissus"
    const name = @typeName(myType);
    return name[indexOf(u8, name, ".").? + 1 ..];
}
