//
// 如果你觉得上一个练习已经够深入了，那么抓紧你的帽子，
// 因为我们即将深入计算机的熔融核心。
//
// （大喊）在这里，比特和字节像炽热的流体一样从内存流向 CPU。
// 力量巨大无比。但这一切和我们 Zig 程序中的数据有什么关系呢？
// 让我们回到文本编辑器里看看吧。
//
// 啊，这样好多了。现在我们可以看看一些熟悉的 Zig 代码了。
//
// @import() 会把导入的代码添加到你的程序中。在这里，标准库的代码
// 会被添加并和你的程序一起编译。当程序运行时，它们会一起被加载到
// 内存中。我们把它命名为 “const std”，其实它就是一个 struct！
//
const std = @import("std");

// 还记得我们的 RPG 角色 Character 吗？Struct 其实就是一种
// 很方便的内存管理方式。这些字段（gold、health、experience）
// 都是固定大小的值，把它们加起来就是整个 struct 的大小。

const Character = struct {
    gold: u32 = 0,
    health: u8 = 100,
    experience: u32 = 0,
};

// 这里我们创建了一个名为 “the_narrator” 的角色，它是一个常量
// （不可变）的 Character 实例。它作为数据存储在你的程序里，
// 就像指令代码一样，在运行时会被加载到内存中。
// 它在内存中的位置是硬编码的，既不会改变地址，也不会改变值。

const the_narrator = Character{
    .gold = 12,
    .health = 99,
    .experience = 9000,
};

// “global_wizard” 与它很相似。不过它是 var 而不是 const，
// 所以地址不会变，但数据本身可以改变。

var global_wizard = Character{};

// 函数是位于特定地址的指令代码。在 Zig 中，函数参数总是不可变的。
// 它们存储在“栈”中。栈是一种数据结构，而“调用栈”是内存中专门
// 分配给你程序的一块区域。CPU 对栈有专门的硬件支持，因此栈的存取
// 十分快速。
//
// 当函数执行时，输入参数通常会被加载到 CPU 内部的寄存器中。
//
// 我们的 main() 函数没有输入参数，但它依然会在栈上有一个“栈帧”
// （stack frame）。
//
pub fn main() void {

    // “glorp” 角色会分配在栈上，因为每次调用 main 时它都是一个
    // 独立的可变实例。

    var glorp = Character{
        .gold = 30,
    };

    // “reward_xp” 值很有意思。它是不可变的，所以尽管它是局部变量，
    // 编译器可以把它放在全局数据段里在多个调用间共享。
    // 不过因为它很小，编译器也可能直接在指令中内联。
    // 具体方式由编译器决定。

    const reward_xp: u32 = 200;

    // 现在回到最开始我们导入的 “std”。
    // 导入后它就是一个普通的 Zig 值，因此我们可以重新命名它的字段
    // 或函数。比如 “debug” 是一个 struct，而 “print” 是它的公有函数。
    //
    // 我们可以把 std.debug.print 赋给一个叫 “print” 的常量，
    // 以后就能用这个简短的名字调用它啦！

    const print = ???;

    // 接下来看看在 Zig 中赋值和指针的使用。
    //
    // 我们要用三种不同方式访问 glorp，并修改它的字段。
    //
    // “glorp_access1” 名字起得不太对！
    // 因为 Zig 会单独分配一个 Character，所以 glorp 被复制了一份。
    // 修改它不会影响原始 glorp。
    var glorp_access1: Character = glorp;
    glorp_access1.gold = 111;
    print("1:{}!. ", .{glorp.gold == glorp_access1.gold});

    // 如果这里用的是 const Character，那么尝试修改 gold 字段
    // 会报编译错误，因为 const 不可变！

    // “glorp_access2” 做的是我们想要的。它是指针，指向 glorp 的地址。
    // 访问 gold 字段和直接访问 glorp 一样。
    var glorp_access2: *Character = &glorp;
    glorp_access2.gold = 222;
    print("2:{}!. ", .{glorp.gold == glorp_access2.gold});

    // “glorp_access3” 也是指针，但它是 const 指针。
    // 这是否意味着不能改 glorp 呢？不是！
    // const 限制的是指针本身不能指向别的东西，但地址里的值仍然可变。
    const glorp_access3: *Character = &glorp;
    glorp_access3.gold = 333;
    print("3:{}!. ", .{glorp.gold == glorp_access3.gold});

    // 注意：如果这里用的是 *const Character，那么值就变成不可改，
    // 会报编译错误。

    // 接下来...
    //
    // 当参数传入函数时，在函数内部它们**总是 const**，
    // 无论调用处是 var 还是 const。
    //
    // 示例：
    // fn foo(arg: u8) void {
    //    arg = 42; // 错误！arg 是 const
    // }
    //
    // fn bar() void {
    //    var arg: u8 = 12;
    //    foo(arg);
    // }
    //
    // 知道这一点后，请修复 levelUp() 使其能按预期工作，
    // 给角色增加经验值。
    //
    print("XP before:{}, ", .{glorp.experience});

    // 修复点 1/2 在这里：
    levelUp(glorp, reward_xp);

    print("after:{}.\n", .{glorp.experience});
}

// 修复点 2/2 在这里：
fn levelUp(character_access: Character, xp: u32) void {
    character_access.experience += xp;
}
