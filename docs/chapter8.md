# 第8章 单元测试 - Zig语言入门

在本章中，我想深入探讨如何在Zig中进行单元测试。我们将讨论Zig中的测试工作流程，以及`zig`编译器的`test`命令。

## 介绍`test`块

在Zig中，单元测试是在`test`声明内编写的，或者，我更喜欢称之为`test`块。每个`test`块都是使用关键字`test`编写的。你可以选择性地使用字符串字面量来编写标签，它负责标识你在这个特定`test`块中编写的特定单元测试组。

在下面的例子中，我们正在测试两个对象（`a`和`b`）的和是否等于4。Zig标准库中的`expect()`函数是一个接收逻辑测试作为输入的函数。如果这个逻辑测试结果为`true`，那么测试通过。但如果结果为`false`，那么测试失败。

你可以在`test`块内编写任何你想要的Zig代码。这些代码的一部分可能是设置测试环境所需的一些必要命令，或者只是初始化你在单元测试中需要使用的一些对象。

```zig
const std = @import("std");
const expect = std.testing.expect;
test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);
}
```

```
1/1 file1ed835512cf8.test.testing simple sum...OK
All 1 tests passed.
```

你可以在同一个Zig模块中编写多个`test`块。此外，你可以将`test`块与你的源代码混合在一起，没有任何问题或后果。如果你将`test`块与正常的源代码混合在一起，当你执行我们在[第1.2.4节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-compile-code)中介绍的`zig`编译器的`build`、`build-exe`、`build-obj`或`build-lib`命令时，这些`test`块会被编译器自动忽略。

换句话说，`zig`编译器只在你要求它时才构建和执行你的单元测试。默认情况下，编译器总是忽略在你的Zig模块中编写的`test`块。编译器通常只检查这些`test`块中是否有任何语法错误。

如果你查看Zig标准库中大多数文件的源代码，你可以看到`test`块与库的正常源代码一起编写。例如，你可以在[`array_list`模块](https://github.com/ziglang/zig/blob/master/lib/std/array_list.zig)中看到这一点。因此，Zig开发人员决定采用的标准是将他们的单元测试与他们正在测试的功能的源代码放在一起。

每个程序员对此可能有不同的看法。他们中的一些人可能更喜欢将单元测试与应用程序的实际源代码分开。如果这是你的情况，你可以简单地在项目中创建一个单独的`tests`文件夹，并开始编写只包含单元测试的Zig模块（就像你通常在使用`pytest`的Python项目中所做的那样），一切都会正常工作。这归结为你在这里的偏好。

## 如何运行你的测试

如果`zig`编译器默认忽略任何`test`块，你如何编译和运行你的单元测试？答案是`zig`编译器的`test`命令。通过运行`zig test`命令，编译器将在你的Zig模块中找到`test`块的每个实例，并且它将编译和运行你编写的单元测试。

`zig test simple_sum.zig`

```
1/1 simple_sum.test.testing simple sum... OK
All 1 tests passed.
```

## 测试内存分配

Zig的优势之一是它提供了帮助我们程序员避免（但也检测）内存问题的优秀工具，如内存泄漏和双重释放。`defer`关键字在这方面特别有用。

在开发源代码时，你，程序员，有责任确保你的代码不会产生这些问题。然而，你也可以在Zig中使用一种特殊类型的分配器对象，它能够自动为你检测这些问题。这就是`std.testing.allocator`对象。这个分配器对象提供了一些基本的内存安全检测功能，能够检测内存泄漏。

正如我们在[第3.1.5节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-heap)中描述的，要在堆上分配内存，你需要使用分配器对象，而使用这些对象在堆上分配内存的函数应该接收分配器对象作为其输入之一。你使用这些分配器对象在堆上分配的每个内存，也必须使用同一个分配器对象释放。

因此，如果你想测试你的函数执行的内存分配，并确保你在这些分配中没有问题，你可以简单地为这些函数编写单元测试，在其中你向这些函数提供`std.testing.allocator`对象作为输入。

看看下面的例子，我定义了一个明显导致内存泄漏的函数。因为我们分配了内存，但同时，我们在任何时候都没有释放这个分配的内存。因此，当函数返回时，我们失去了对包含分配内存的`buffer`对象的引用，因此，我们不能再释放这个内存。

注意，在`test`块内，我使用`std.testing.allocator`执行这个函数。分配器对象能够深入查看我们的程序，并检测内存泄漏。结果，这个分配器对象返回"memory leaked"的错误消息，以及显示内存泄漏确切位置的堆栈跟踪。

```zig
const std = @import("std");
const Allocator = std.mem.Allocator;
fn some_memory_leak(allocator: Allocator) !void {
    const buffer = try allocator.alloc(u32, 10);
    _ = buffer;
    // 返回而不释放
    // 分配的内存
}

test "memory leak" {
    const allocator = std.testing.allocator;
    try some_memory_leak(allocator);
}
```

```
Test [1/1] leak_memory.test.memory leak...
    [gpa] (err): memory address 0x7c1fddf39000 leaked:
./ZigExamples/debugging/leak_memory.zig:4:39: 0x10395f2
    const buffer = try allocator.alloc(u32, 10);
                                      ^
./ZigExamples/debugging/leak_memory.zig:12:25: 0x10398ea
    try some_memory_leak(allocator);

... more stack trace
```

## 测试错误

单元测试的一种常见风格是那些在函数中查找特定错误的测试。换句话说，你编写一个单元测试，试图断言特定的函数调用是否返回任何错误，或特定类型的错误。

在C++中，你通常会使用例如[`Catch2`测试框架](https://github.com/catchorg/Catch2/tree/devel)的`REQUIRE_THROWS()`或`CHECK_THROWS()`函数来编写这种风格的单元测试。在Python项目的情况下，你可能会使用[`pytest`的`raises()`函数](https://docs.pytest.org/en/7.1.x/reference/reference.html#pytest-raises)。而在Rust中，你可能会将`assert_eq!()`与`Err()`结合使用。

但在Zig中，我们使用`std.testing`模块的`expectError()`函数。使用这个函数，你可以测试特定的函数调用是否返回你期望它返回的确切错误类型。要使用这个函数，你首先写`try expectError()`。然后，在第一个参数中，你提供你期望从函数调用中得到的错误类型。然后，在第二个参数中，你编写你期望失败的函数调用。

下面的代码示例演示了Zig中这种类型的单元测试。注意，在函数`alloc_error()`内部，我们为对象`ibuffer`分配了100字节的内存，或者说，一个100个元素的数组。然而，在`test`块中，我们使用的是`FixedBufferAllocator()`分配器对象，它被限制为10字节的空间，因为我们提供给分配器对象的对象`buffer`只有10字节的空间。

这就是为什么`alloc_error()`函数在这种情况下引发`OutOfMemory`错误。因为这个函数试图分配比分配器对象允许的更多空间。所以，本质上，我们正在测试特定类型的错误，即`OutOfMemory`。如果`alloc_error()`函数返回任何其他类型的错误，那么，`expectError()`函数将使整个测试失败。

```zig
const std = @import("std");
const Allocator = std.mem.Allocator;
const expectError = std.testing.expectError;
fn alloc_error(allocator: Allocator) !void {
    var ibuffer = try allocator.alloc(u8, 100);
    defer allocator.free(ibuffer);
    ibuffer[0] = 2;
}

test "testing error" {
    var buffer: [10]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();
    try expectError(error.OutOfMemory, alloc_error(allocator));
}
```

```
1/1 file1ed878d2d839.test.testing error...OK
All 1 tests passed.
```

## 测试简单的相等性

在Zig中，有一些不同的方法可以测试相等性。你已经看到我们可以使用`expect()`与逻辑运算符`==`来本质上重现相等性测试。但我们还有一些其他你应该知道的辅助函数，特别是`expectEqual()`、`expectEqualSlices()`和`expectEqualStrings()`。

`expectEqual()`函数，顾名思义，是一个经典的测试相等性函数。它接收两个对象作为输入。第一个对象是你期望在第二个对象中的值。而第二个对象是你拥有的对象，或者你的应用程序作为结果产生的对象。所以，使用`expectEqual()`，你本质上是在测试存储在这两个对象内的值是否相等。

你可以在下面的例子中看到，`expectEqual()`执行的测试失败了。因为对象`v1`和`v2`包含不同的值。

```zig
const std = @import("std");
test "values are equal?" {
    const v1 = 15;
    const v2 = 18;
    try std.testing.expectEqual(v1, v2);
}
```

```
1/1 ve.test.values are equal?...
    expected 15, found 18
    FAIL (TestExpectedEqual)
ve.zig:5:5: test.values are equal? (test)
    try std.testing.expectEqual(v1, v2);
    ^
0 passed; 0 skipped; 1 failed.
```

虽然有用，但`expectEqual()`函数不适用于数组。要测试两个数组是否相等，你应该使用`expectEqualSlices()`函数。这个函数有三个参数。首先，你提供你试图比较的两个数组中包含的数据类型。而第二个和第三个参数对应于你想要比较的数组对象。

在下面的例子中，我们使用这个函数来测试两个数组对象（`array1`和`array2`）是否相等。由于它们实际上是相等的，单元测试没有错误地通过了。

```zig
const std = @import("std");
test "arrays are equal?" {
    const array1 = [3]u32{1, 2, 3};
    const array2 = [3]u32{1, 2, 3};
    try std.testing.expectEqualSlices(
        u32, &array1, &array2
    );
}
```

```
1/1 file1ed83cbad6df.test.arrays are equal?...OK
All 1 tests passed.
```

最后，你可能还想使用`expectEqualStrings()`函数。顾名思义，你可以使用这个函数来测试两个字符串是否相等。只需提供你想要比较的两个字符串对象作为函数的输入。

如果函数发现两个字符串之间存在任何差异，那么，函数将引发错误，并且还会打印一条错误消息，显示提供的两个字符串对象之间的确切差异，如下面的例子所示：

```zig
const std = @import("std");
test "strings are equal?" {
    const str1 = "hello, world!";
    const str2 = "Hello, world!";
    try std.testing.expectEqualStrings(
        str1, str2
    );
}
```

```
1/1 t.test.strings are equal?...
====== expected this output: =========
hello, world!␃
======== instead found this: =========
Hello, world!␃
======================================
First difference occurs on line 1:
expected:
hello, world!
^ ('\x68')
found:
Hello, world!
^ ('\x48')
```

---

脚注翻译：

1. [https://github.com/ziglang/zig/tree/master/lib/std](https://github.com/ziglang/zig/tree/master/lib/std)
2. [https://github.com/ziglang/zig/blob/master/lib/std/array_list.zig](https://github.com/ziglang/zig/blob/master/lib/std/array_list.zig)
3. [https://github.com/catchorg/Catch2/tree/devel](https://github.com/catchorg/Catch2/tree/devel)
4. [https://docs.pytest.org/en/7.1.x/reference/reference.html#pytest-raises](https://docs.pytest.org/en/7.1.x/reference/reference.html#pytest-raises)
