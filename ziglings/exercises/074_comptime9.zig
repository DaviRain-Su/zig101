//
// 除了知道 **什么时候该用** `comptime` 关键字，
// 还需要知道 **什么时候不需要用** 它。
//
// 以下这些场景已经是 **隐式地** 在编译期求值了，
// 再加上 `comptime` 关键字就显得多余、累赘、甚至“有味道”了：
//
//    * 容器级作用域（即源文件中，所有函数之外的范围）
//    * 类型声明中的：
//        * 变量
//        * 函数（参数类型和返回值类型）
//        * 结构体 (structs)
//        * 联合体 (unions)
//        * 枚举 (enums)
//    * `inline for` 和 `while` 循环中的测试表达式
//    * 传递给内建函数 `@cImport()` 的表达式
//
// 多写一段 Zig，你就会逐渐形成对这些场景的直觉。
// 我们现在就来练习一下。
//
// 在下面的程序里，你只有 **一个** `comptime` 可以用。
// 就是这里：
//
//     comptime
//
// 只要用一次就够了。好好利用它！
//
const print = @import("std").debug.print;

// 因为位于容器级作用域，下面这个值在编译期必须已知。
const llama_count = 5;

// 同样，这个值的类型和大小也必须在编译期已知，
// 不过我们让编译器通过函数返回值类型来推断。
const llamas = makeLlamas(llama_count);

// 下面是函数。注意它的返回值类型依赖于其中一个输入参数！
fn makeLlamas(count: usize) [count]u8 {
    var temp: [count]u8 = undefined;
    var i = 0;

    // 注意：这里并不需要 `inline while`。
    while (i < count) : (i += 1) {
        temp[i] = i;
    }

    return temp;
}

pub fn main() void {
    print("My llama value is {}.\n", .{llamas[2]});
}
//
// 这里的教训是：不要随便在程序里乱加 `comptime`。
// 在隐式编译期上下文 + Zig 对可在编译期确定的表达式的积极求值
// 的共同作用下，实际上真正需要 `comptime` 的地方非常少。
// 有时候少到会让你惊讶。
