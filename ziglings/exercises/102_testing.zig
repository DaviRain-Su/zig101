//
// Zig 的一个巨大优势是集成了自带的测试系统。
// 这让测试驱动开发（TDD）的理念可以被完美实现。
// Zig 甚至比其他语言更进一步：测试可以直接写在源文件里。
//
// 这有几个好处：
// 一方面，源代码和对应的测试代码都在同一个文件里，会更加清晰。
// 另一方面，第三方要理解某个函数应该做什么时，可以直接查看源代码里的测试并对照。
//
// 尤其是当你想理解 Zig 的标准库是如何工作的，这种方式非常有帮助。
// 此外，当你要给 Zig 社区报告一个 bug 时，也很方便，
// 可以附上一个带有测试的小例子来说明问题。
//
// 因此，这个练习我们要学习 Zig 测试的基础。
// 基本上，测试的工作方式是：
// 你给函数传入一些参数，得到一个返回值（结果）。
// 然后把结果和“期望值”比较。
// 如果两者一致，测试通过；否则就会显示错误信息。
//
//          testing.expect(foo(param1, param2) == expected);
//
// 当然也可以进行其他比较，甚至可以刻意制造错误，
// 只要函数的行为符合预期，测试也会通过。
//
// 测试既可以通过 Zig 的构建系统运行，
// 也可以直接对单个模块运行： `zig test xyz.zig`。
//
// 两者都可以用脚本驱动，在比如提交代码到 Git 仓库后自动执行测试。
// Ziglings 本身也大量使用了这种方式。
//
const std = @import("std");
const testing = std.testing;

// 这是一个简单的函数，
// 它将传入的两个参数相加并返回。
fn add(a: f16, b: f16) f16 {
    return a + b;
}

// 对应的测试。
// 它总是以关键字 "test" 开始，
// 后面跟一个描述测试任务的字符串。
// 花括号里写测试用例。
test "add" {

    // 第一个测试检查 41 + 1 是否等于 42，
    // 这是正确的。
    try testing.expect(add(41, 1) == 42);

    // 另一种写法：
    try testing.expectEqual(42, add(41, 1));

    // 这次是测试一个负数相加：
    try testing.expect(add(5, -4) == 1);

    // 再来一个浮点数运算：
    try testing.expect(add(1.5, 1.5) == 3);
}

// 另一个简单函数，
// 返回两个参数相减的结果。
fn sub(a: f16, b: f16) f16 {
    return a - b;
}

// 对应的测试和前面的没什么不同。
// 只是里面包含了一个错误，需要你来修复。
test "sub" {
    try testing.expect(sub(10, 5) == 6);

    try testing.expect(sub(3, 1.5) == 1.5);
}

// 这个函数执行除法：分子 ÷ 分母。
// 这里要注意：分母不能为 0。
// 如果分母是 0，就返回一个错误。
fn divide(a: f16, b: f16) !f16 {
    if (b == 0) return error.DivisionByZero;
    return a / b;
}

test "divide" {
    try testing.expect(divide(2, 2) catch unreachable == 1);
    try testing.expect(divide(-1, -1) catch unreachable == 1);
    try testing.expect(divide(10, 2) catch unreachable == 5);
    try testing.expect(divide(1, 3) catch unreachable == 0.3333333333333333);

    // 现在我们测试当分母为 0 时，函数是否返回错误。
    // 但是我们要检查的是哪个错误呢？
    try testing.expectError(error.???, divide(15, 0));
}
