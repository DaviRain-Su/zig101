//
// ‘comptime’ 函数参数的一个常见用途是 **将类型传入函数**：
//
//     fn foo(comptime MyType: type) void { ... }
//
// 事实上，类型 **只能在编译期使用**，
// 所以这里必须加上 `comptime` 关键字。
//
// 现在请你戴上系统提供的「巫师帽」🧙。
// 我们要用这种能力来实现一个 **泛型函数**。
//
const print = @import("std").debug.print;

pub fn main() void {
    // 在这里，我们在编译期通过函数调用声明了三种不同类型、不同大小的数组。很酷吧！
    const s1 = makeSequence(u8, 3);   // 创建一个 [3]u8
    const s2 = makeSequence(u32, 5);  // 创建一个 [5]u32
    const s3 = makeSequence(i64, 7);  // 创建一个 [7]i64

    print("s1={any}, s2={any}, s3={any}\n", .{ s1, s2, s3 });
}

// 这个函数很神奇，因为它在运行时执行，
// 并且会被编译进最终的程序。
// 它被编译时，数据的大小和类型是固定的。
//
// 然而，它却还能支持不同的大小和类型。
// 这似乎是个悖论。怎么会两者都成立呢？
//
// 其实，Zig 编译器会为 **每一种大小/类型组合**
// 单独生成一份函数拷贝！
// 所以在这个例子里，它会帮你生成三个不同的函数，
// 每一个都处理对应的数据大小和类型。
//
// 请修复下面这个函数，让 `size` 参数：
//
//   1) 保证在编译期已知。
//   2) 用来设置数组的大小，并返回指定类型 T 的数组。
//
fn makeSequence(comptime T: type, ??? size: usize) [???]T {
    var sequence: [???]T = undefined;
    var i: usize = 0;

    while (i < size) : (i += 1) {
        sequence[i] = @as(T, @intCast(i)) + 1;
    }

    return sequence;
}
