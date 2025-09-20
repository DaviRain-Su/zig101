//
// 让我们学习一些数组基础知识。数组的声明方式如下：
//
//   var foo: [3]u32 = [3]u32{ 42, 108, 5423 };
//
// 当 Zig 可以推断数组大小时，你可以使用 '_' 表示大小。
// 你也可以让 Zig 推断值的类型，这样声明就简洁多了。
//
//   var foo = [_]u32{ 42, 108, 5423 };
//
// 使用 array[index] 表示法获取数组的值：
//
//     const bar = foo[2]; // 5423
//
// 使用 array[index] 表示法设置数组的值：
//
//     foo[2] = 16;
//
// 使用 len 属性获取数组的长度：
//
//     const length = foo.len;
//
const std = @import("std");

pub fn main() void {
    // (问题 1)
    // 这个 "const" 稍后会导致问题 - 你能看出是什么问题吗？
    // 我们该如何修复它？
    const some_primes = [_]u8{ 1, 3, 5, 7, 11, 13, 17, 19 };

    // 可以使用 '[]' 表示法设置单个值。
    // 示例：这一行将第一个质数改为 2（这是正确的）：
    some_primes[0] = 2;

    // 也可以使用 '[]' 表示法访问单个值。
    // 示例：这一行将第一个质数存储在 "first" 中：
    const first = some_primes[0];

    // (问题 2)
    // 看起来我们需要完成这个表达式。使用上面的示例
    // 将 "fourth" 设置为 some_primes 数组的第四个元素：
    const fourth = some_primes[???];

    // (问题 3)
    // 使用 len 属性获取数组的长度：
    const length = some_primes.???;

    std.debug.print("First: {}, Fourth: {}, Length: {}\n", .{
        first, fourth, length,
    });
}
