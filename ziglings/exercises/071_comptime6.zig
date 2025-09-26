//
// 在我们的程序里，有好几次其实很想用循环，
// 但没办法，因为我们要做的事情只能在 **编译期** 完成。
// 最后不得不手动去做，就像普通人一样。呸！
// 我们可是程序员啊！这活儿应该让电脑来干。
//
// `inline for` 是在编译期执行的循环，
// 它允许你在某些场景下用循环来处理数据，
// 比如前面那些普通运行时 `for` 循环不允许的地方：
//
//     inline for (.{ u8, u16, u32, u64 }) |T| {
//         print("{} ", .{@typeInfo(T).Int.bits});
//     }
//
// 在上面的例子中，我们在循环一个类型的列表，
// 而这些类型是只有在编译期才存在的。
//
const print = @import("std").debug.print;

// 还记得第 065 个练习里的 Narcissus 吗？
// 当时我们用内建函数做了反射。
// 现在他又回来了，而且乐在其中。
const Narcissus = struct {
    me: *Narcissus = undefined,
    myself: *Narcissus = undefined,
    echo: void = undefined,
};

pub fn main() void {
    print("Narcissus 心中还能容纳：", .{});

    // 上一次我们检查 Narcissus 结构体的时候，
    // 不得不手动访问三个字段。
    // if 语句几乎重复了三遍，真恶心！
    //
    // 请使用 `inline for` 来实现下面这段逻辑，
    // 遍历 `fields` 里的每个字段！

    const fields = @typeInfo(Narcissus).@"struct".fields;

    ??? {
        if (field.type != void) {
            print(" {s}", .{field.name});
        }
    }

    // 写完之后，回去看看第 065 个练习，
    // 比较一下现在的写法和之前那种臃肿的写法！

    print(".\n", .{});
}
