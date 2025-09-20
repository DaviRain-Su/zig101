# 第2章 控制流、结构体、模块和类型 - Zig语言入门

我们在上一章已经讨论了很多Zig的语法，特别是在[第1.2.2节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-root-file)和[第1.2.3节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-main-file)。但我们仍然需要讨论语言的其他一些非常重要的元素。这些是你在日常工作中会经常使用的元素。

本章我们首先讨论Zig中与控制流相关的不同关键字和结构（如循环和if语句）。然后，我们讨论结构体以及如何使用它们在Zig中实现一些基本的面向对象（OOP）模式。我们还讨论类型推断和类型转换。最后，我们通过讨论模块以及它们与结构体的关系来结束本章。

有时，你需要在程序中做出决策。也许你需要决定是否执行特定的代码片段。或者，你需要对一系列值应用相同的操作。这些类型的任务涉及使用能够改变程序"控制流"的结构。

在计算机科学中，术语"控制流"通常指的是给定语言或程序中表达式（或命令）的评估顺序。但这个术语也用于指能够改变给定语言/程序执行命令的"评估顺序"的结构。

这些结构更常见的术语包括：循环、if/else语句、switch语句等。所以，循环和if/else语句是可以改变程序"控制流"的结构的例子。关键字`continue`和`break`也是可以改变评估顺序的符号的例子，因为它们可以将我们的程序移动到循环的下一次迭代，或完全停止循环。

### If/else语句

if/else语句执行"条件流操作"。条件流控制（或选择控制）允许你基于逻辑条件执行或忽略某个命令块。许多程序员和计算机科学专业人士在这种情况下也使用术语"分支"。本质上，if/else语句允许我们使用逻辑测试的结果来决定是否执行给定的命令块。

在Zig中，我们使用关键字`if`和`else`来编写if/else语句。我们从`if`关键字开始，后跟括号内的逻辑测试，然后是包含在逻辑测试返回值`true`时要执行的代码行的花括号。

之后，你可以选择性地添加`else`语句。要做到这一点，只需添加`else`关键字，后跟一对花括号，其中包含在`if`定义的逻辑测试返回`false`时要执行的代码行。

在下面的例子中，我们正在测试对象`x`是否包含大于10的数字。从控制台打印的输出来看，我们知道这个逻辑测试返回了`false`。因为控制台中的输出与if/else语句的`else`分支中的代码行兼容。

```zig
const x = 5;
if (x > 10) {
    try stdout.print("x > 10!\n", .{});
} else {
    try stdout.print("x <= 10!\n", .{});
}
try stdout.flush();
```

`x <= 10!`

### Switch语句

Switch语句在Zig中也可用，它们的语法与Rust中的switch语句非常相似。正如你所期望的，要在Zig中编写switch语句，我们使用`switch`关键字。我们在括号内提供要"切换"的值。然后，我们在花括号内列出可能的组合（或"分支"）。

让我们看看下面的代码示例。你可以看到我正在创建一个名为`Role`的枚举类型。我们在[第7.6节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-enum)中更多地讨论枚举。但总的来说，这个`Role`类型列出了虚构公司中不同类型的角色，如`SE`代表软件工程师，`DE`代表数据工程师，`PM`代表产品经理等。

注意我们在switch语句中使用`role`对象的值来发现需要在`area`变量对象中存储哪个确切的区域。还要注意我们在switch语句内使用类型推断，使用点字符，正如我们将在[第2.4节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-type-inference)中描述的。这使得`zig`编译器为我们推断值（`PM`、`SE`等）的正确数据类型。

还要注意，我们在switch语句的同一分支中分组多个值。我们只是用逗号分隔每个可能的值。例如，如果`role`包含`DE`或`DA`，`area`变量将包含值`"Data & Analytics"`，而不是`"Platform"`或`"Sales"`。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const Role = enum {
    SE, DPE, DE, DA, PM, PO, KS
};

pub fn main() !void {
    var area: []const u8 = undefined;
    const role = Role.SE;
    switch (role) {
        .PM, .SE, .DPE, .PO => {
            area = "Platform";
        },
        .DE, .DA => {
            area = "Data & Analytics";
        },
        .KS => {
            area = "Sales";
        },
    }
    try stdout.print("{s}\n", .{area});
    try stdout.flush();
}
```

`Platform`

#### Switch语句必须穷尽所有可能性

Zig中switch语句的一个非常重要的方面是它们必须穷尽所有现有的可能性。换句话说，`role`对象内可能找到的所有可能值都必须在这个switch语句中明确处理。

由于`role`对象的类型是`Role`，存储在这个对象中唯一可能的值是`PM`、`SE`、`DPE`、`PO`、`DE`、`DA`和`KS`。这个`role`对象中不可能存储其他值。因此，switch语句必须为这些值中的每一个都有一个组合（分支）。这就是"穷尽所有现有可能性"的含义。switch语句涵盖了每个可能的情况。

因此，你不能在Zig中编写switch语句，并留下没有明确采取行动的边缘情况。这与Rust中的switch语句的行为类似，它们也必须处理所有可能的情况。

#### else分支

以下面的`dump_hex_fallible()`函数为例。这个函数来自Zig标准库。更准确地说，来自[`debug.zig`模块](https://github.com/ziglang/zig/blob/master/lib/std/debug.zig)。这个函数中有多行，但我省略了它们，只关注在这个函数中找到的switch语句。注意这个switch语句有四个可能的情况（即四个明确的分支）。还要注意，在这种情况下我们使用了`else`分支。

switch语句中的`else`分支作为"默认分支"工作。每当你的switch语句中有多个情况想要应用完全相同的操作时，你可以使用`else`分支来做到这一点。

```zig
pub fn dump_hex_fallible(bytes: []const u8) !void {
    // 省略了许多行...
    switch (byte) {
        '\n' => try writer.writeAll("␊"),
        '\r' => try writer.writeAll("␍"),
        '\t' => try writer.writeAll("␉"),
        else => try writer.writeByte('.'),
    }
}
```

许多程序员也会使用`else`分支来处理"不支持"的情况。即，你的代码无法正确处理的情况，或者，不应该被"修复"的情况。因此，你可以使用`else`分支在程序中引发panic（或引发错误）来停止当前执行。

看看下面的代码示例。我们可以看到，我们正在处理`level`对象为1、2或3的情况。默认情况下不支持所有其他可能的情况，因此，我们通过`@panic()`内置函数在这种情况下引发运行时错误。

还要注意，我们将switch语句的结果分配给一个名为`category`的新对象。这是你可以在Zig中使用switch语句做的另一件事。如果分支输出一个值作为结果，你可以将switch语句的结果值存储到一个新对象中。

```zig
const level: u8 = 4;
const category = switch (level) {
    1, 2 => "beginner",
    3 => "professional",
    else => {
        @panic("Not supported level!");
    },
};
try stdout.print("{s}\n", .{category});
try stdout.flush();
```

```
thread 13103 panic: Not supported level!
t.zig:9:13: 0x1033c58 in main (switch2)
            @panic("Not supported level!");
            ^
```

#### 在switch中使用范围

此外，你还可以在switch语句中使用值的范围。也就是说，你可以在switch语句中创建一个分支，当输入值在指定范围内时使用该分支。这些"范围表达式"是用操作符`...`创建的。重要的是要强调，此操作符创建的范围在两端都是包含的。

例如，我可以轻松更改前面的代码示例以支持0到100之间的所有级别。像这样：

```zig
const level: u8 = 4;
const category = switch (level) {
    0...25 => "beginner",
    26...75 => "intermediary",
    76...100 => "professional",
    else => {
        @panic("Not supported level!");
    },
};
try stdout.print("{s}\n", .{category});
try stdout.flush();
```

`beginner`

这很整洁，它也适用于字符范围。也就是说，我可以简单地写`'a'...'z'`，来匹配任何小写字母的字符值，它会正常工作。

#### 标记的switch语句

在[第1.7节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-blocks)中，我们讨论了标记块，以及使用这些标签从块返回值。从`zig`编译器的0.14.0版本开始，你也可以在switch语句上应用标签，这使得几乎可以实现"C `goto`"类似的模式。

例如，如果你给switch语句一个标签`xsw`，你可以将这个标签与`continue`关键字结合使用，返回到switch语句的开头。在下面的例子中，执行在结束于`3`分支之前，两次返回到switch语句的开头。

```zig
xsw: switch (@as(u8, 1)) {
    1 => {
        try stdout.print("First branch\n", .{});
        continue :xsw 2;
    },
    2 => continue :xsw 3,
    3 => return,
    4 => {},
    else => {
        try stdout.print(
            "Unmatched case, value: {d}\n", .{@as(u8, 1)}
        );
        try stdout.flush();
    },
}
```

### `defer`关键字

Zig有一个`defer`关键字，它在控制流和释放资源方面扮演着非常重要的角色。总之，`defer`关键字允许你注册一个表达式，在退出当前作用域时执行。

在这一点上，你可能会尝试将Zig的`defer`关键字与Go语言中的同胞进行比较（即[Go也有一个`defer`关键字](https://go.dev/tour/flowcontrol/12)）。然而，Go中的`defer`关键字的行为与Zig中的略有不同。更具体地说，Go中的`defer`关键字总是将表达式移动到**当前函数的退出**时执行。

如果你深入思考这个陈述，你会注意到"当前函数的退出"与"当前作用域的退出"略有不同。所以，在比较这两个关键字时要小心。Zig中的单个函数可能包含许多不同的作用域，因此，`defer`输入表达式可能在函数的不同位置执行，这取决于你当前所在的作用域。

作为第一个例子，考虑下面暴露的`foo()`函数。当我们执行这个`foo()`函数时，打印消息"Exiting function ..."的表达式仅在函数退出其作用域时执行。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
fn foo() !void {
    defer std.debug.print(
        "Exiting function ...\n", .{}
    );
    try stdout.print("Adding some numbers ...\n", .{});
    const x = 2 + 2; _ = x;
    try stdout.print("Multiplying ...\n", .{});
    const y = 2 * 8; _ = y;
    try stdout.flush();
}

pub fn main() !void {
    try foo();
}
```

```
Adding some numbers ...
Multiplying ...
Exiting function ...
```

因此，我们可以使用`defer`来声明一个表达式，当你的代码退出当前作用域时将执行该表达式。一些程序员喜欢将短语"退出当前作用域"解释为"当前作用域的结束"。但这种解释可能并不完全正确，这取决于你认为什么是"当前作用域的结束"。

我的意思是，你认为什么是当前作用域的**结束**？是作用域的右花括号（`}`）吗？是函数中最后一个表达式被执行时吗？是函数返回到前一个作用域时吗？等等。例如，将"退出当前作用域"解释为作用域的右花括号是不正确的。因为函数可能从比这个右花括号更早的位置退出（例如，在函数内的前一行生成了错误值；函数到达了更早的return语句；等等）。无论如何，对这种解释要小心。

现在，如果你记得我们在[第1.7节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-blocks)中讨论的内容，语言中有多个结构创建它们自己的独立作用域。For/while循环、if/else语句、函数、普通块等。这也影响了`defer`的解释。例如，如果你在for循环内使用`defer`，那么，给定的表达式将在这个特定的for循环每次退出其自己的作用域时执行。

在我们继续之前，值得强调的是`defer`关键字是一个"无条件的defer"。这意味着无论代码如何退出当前作用域，给定的表达式都将被执行。例如，你的代码可能因为生成了错误值而退出当前作用域，或者因为return语句，或者break语句等。

### `errdefer`关键字

在前一节中，我们讨论了`defer`关键字，你可以使用它来注册一个表达式在退出当前作用域时执行。但这个关键字有一个兄弟，即`errdefer`关键字。虽然`defer`是一个"无条件的defer"，`errdefer`关键字是一个"条件的defer"。这意味着给定的表达式仅在你在非常特定的情况下退出当前作用域时执行。

更详细地说，给予`errdefer`的表达式仅在当前作用域中发生错误时执行。因此，如果函数（或for/while循环、if/else语句等）在正常情况下退出当前作用域，没有错误，给予`errdefer`的表达式不会被执行。

这使得`errdefer`关键字成为Zig中可用的许多错误处理工具之一。在本节中，我们更关心`errdefer`周围的控制流方面。但我们将在[第10.2.4节](https://pedropark99.github.io/zig-book/Chapters/09-error-handling.html#sec-errdefer2)中讨论`errdefer`作为错误处理工具。

下面的代码示例演示了三件事：

* `defer`是一个"无条件的defer"，因为无论函数`foo()`如何退出其自己的作用域，给定的表达式都会被执行。
* `errdefer`被执行是因为函数`foo()`返回了一个错误值。
* `defer`和`errdefer`表达式以LIFO（_后进先出_）顺序执行。

```zig
const std = @import("std");
fn foo() !void { return error.FooError; }
pub fn main() !void {
    var i: usize = 1;
    errdefer std.debug.print("Value of i: {d}\n", .{i});
    defer i = 2;
    try foo();
}
```

```
Value of i: 2
error: FooError
/t.zig:6:5: 0x1037e48 in foo (defer)
    return error.FooError;
    ^
```

当我说"defer表达式"以LIFO顺序执行时，我想说的是代码中最后的`defer`或`errdefer`表达式是第一个被执行的。你也可以将其解释为："defer表达式"从下到上执行，或者从最后到第一个执行。

因此，如果我改变`defer`和`errdefer`表达式的顺序，你会注意到打印到控制台的`i`的值变为1。这并不意味着在这种情况下`defer`表达式没有被执行。这实际上意味着`defer`表达式仅在`errdefer`表达式之后执行。下面的代码示例演示了这一点：

```zig
const std = @import("std");
fn foo() !void { return error.FooError; }
pub fn main() !void {
    var i: usize = 1;
    defer i = 2;
    errdefer std.debug.print("Value of i: {d}\n", .{i});
    try foo();
}
```

```
Value of i: 1
error: FooError
/t.zig:6:5: 0x1037e48 in foo (defer)
    return error.FooError;
    ^
```

### For循环

循环允许你多次执行相同的代码行，从而在程序的执行流中创建一个"重复空间"。当我们想要在不同的输入上复制相同的函数（或相同的命令集）时，循环特别有用。

Zig中有不同类型的循环可用。但其中最重要的可能是_for循环_。for循环用于对切片或数组的元素应用相同的代码片段。

Zig中的for循环使用的语法可能对来自其他语言的程序员来说不熟悉。你从`for`关键字开始，然后，在一对括号内列出你想要迭代的项目。然后，在一对管道符（`|`）内，你应该声明一个标识符，作为你的迭代器，或者"循环的重复索引"。

```zig
for (items) |value| {
    // 要执行的代码
}
```

因此，Zig中的for循环使用语法`(items) |value|`，而不是使用`(value in items)`语法。在下面的例子中，你可以看到我们正在循环遍历存储在对象`name`中的数组的项目，并打印到控制台这个数组中每个字符的十进制表示。

如果我们想要，我们也可以遍历数组的切片（或部分），而不是遍历存储在`name`对象中的整个数组。只需使用范围选择器来选择你想要的部分。例如，我可以向for循环提供表达式`name[0..3]`，只遍历数组中的前3个元素。

```zig
const name = [_]u8{'P','e','d','r','o'};
for (name) |char| {
    try stdout.print("{d} | ", .{char});
}
try stdout.flush();
```

`80 | 101 | 100 | 114 | 111 |`

在上面的例子中，我们使用数组中每个元素的实际值作为我们的迭代器。但有很多情况下，我们需要使用索引而不是项目的实际值。

你可以通过提供第二组要迭代的项目来做到这一点。更准确地说，你向for循环提供范围选择器`0..`。所以，是的，你可以在Zig的for循环中同时使用两个不同的迭代器。

但请记住[第1.4节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-assignments)，你在Zig中创建的每个对象都必须以某种方式使用。所以如果你在for循环中声明两个迭代器，你必须在for循环体内使用两个迭代器。但如果你只想使用索引迭代器，而不使用"值迭代器"，那么，你可以通过将值项匹配到下划线字符来丢弃值迭代器，如下面的例子：

```zig
const name = "Pedro";
for (name, 0..) |_, i| {
    try stdout.print("{d} | ", .{i});
}
try stdout.flush();
```

`0 | 1 | 2 | 3 | 4 |`

### While循环

while循环是从`while`关键字创建的。`for`循环遍历数组的项目，但`while`循环将连续无限地循环，直到逻辑测试（由你指定）变为false。

你从`while`关键字开始，然后，在一对括号内定义一个逻辑表达式，循环的主体在一对花括号内提供，如下面的例子：

```zig
var i: u8 = 1;
while (i < 5) {
    try stdout.print("{d} | ", .{i});
    i += 1;
}
try stdout.flush();
```

`1 | 2 | 3 | 4 |`

你也可以在while循环开始时指定要使用的增量表达式。要做到这一点，我们在冒号字符（`:`）后的一对括号内写增量表达式。下面的代码示例演示了这种其他模式。

```zig
var i: u8 = 1;
while (i < 5) : (i += 1) {
    try stdout.print("{d} | ", .{i});
}
try stdout.flush();
```

`1 | 2 | 3 | 4 |`

### 使用`break`和`continue`

在Zig中，你可以通过分别使用关键字`break`和`continue`来明确停止循环的执行，或跳转到循环的下一次迭代。下一个代码示例中的`while`循环乍一看是一个无限循环。因为括号内的逻辑值将始终等于`true`。但是什么让这个`while`循环在`i`对象达到计数10时停止？是`break`关键字！

在while循环内，我们有一个if语句，不断检查`i`变量是否等于10。由于我们在while循环的每次迭代中增加`i`的值，这个`i`对象最终会等于10，当它等于10时，if语句将执行`break`表达式，结果，while循环的执行被停止。

注意在while循环后使用来自Zig标准库的`expect()`函数。这个`expect()`函数是一个"断言"类型的函数。这个函数检查提供的逻辑测试是否等于true。如果是，函数什么也不做。否则（即，逻辑测试等于false），函数引发断言错误。

```zig
var i: usize = 0;
while (true) {
    if (i == 10) {
        break;
    }
    i += 1;
}
try std.testing.expect(i == 10);
try stdout.print("Everything worked!", .{});
try stdout.flush();
```

`Everything worked!`

由于这个代码示例被`zig`编译器成功执行，没有引发任何错误，我们知道，在while循环执行后，`i`对象等于10。因为如果它不等于10，`expect()`会引发错误。

现在，在下一个例子中，我们有一个`continue`关键字的用例。if语句不断检查当前索引是否是2的倍数。如果是，我们跳转到循环的下一次迭代。否则，循环只是将当前索引打印到控制台。

```zig
const ns = [_]u8{1,2,3,4,5,6};
for (ns) |i| {
    if ((i % 2) == 0) {
        continue;
    }
    try stdout.print("{d} | ", .{i});
}
try stdout.flush();
```

`1 | 3 | 5 |`

## 函数参数是不可变的

我们已经在[第1.2.2节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-root-file)和[第1.2.3节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-main-file)中讨论了很多函数声明背后的语法。但我想强调Zig中函数参数（也称为函数参数）的一个有趣事实。总之，函数参数在Zig中是不可变的。

看看下面的代码示例，我们声明了一个简单的函数，它只是尝试向输入整数添加一些量，并返回结果。如果你仔细查看这个`add2()`函数的主体，你会注意到我们尝试将结果保存回函数参数`x`。

换句话说，这个函数不仅使用通过函数参数`x`接收的值，还尝试通过将加法结果分配给`x`来更改这个函数参数的值。然而，Zig中的函数参数是不可变的。你不能改变它们的值，或者，你不能在函数体内为它们分配值。

这就是为什么下面的代码示例无法成功编译的原因。如果你尝试编译这个代码示例，你将收到关于"尝试更改不可变（即常量）对象的值"的编译错误消息。

```zig
const std = @import("std");
fn add2(x: u32) u32 {
    x = x + 2;
    return x;
}

pub fn main() !void {
    const y = add2(4);
    std.debug.print("{d}\n", .{y});
}
```

```
t.zig:3:5: error: cannot assign to constant
    x = x + 2;
    ^
```

### 一个免费的优化

如果函数参数接收的输入对象的数据类型是我们在[第1.5节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-primitive-data-types)中列出的任何原始类型，这个对象总是按值传递给函数。换句话说，这个对象被复制到函数栈帧中。

然而，如果输入对象具有更复杂的数据类型，例如，它可能是一个结构体实例，或数组，或联合值等，在这种情况下，`zig`编译器将自由地为你决定哪种策略是最好的。因此，`zig`编译器将按值或按引用将你的对象传递给函数。编译器将始终选择对你来说更快的策略。你免费获得的这种优化只有在Zig中函数参数不可变时才可能。

### 如何克服这个障碍

有一些情况下，你可能需要直接在函数体内更改函数参数的值。当我们将C结构体作为输入传递给Zig函数时，这种情况更常见。

在这种情况下，你可以通过使用指针来克服这个障碍。换句话说，你可以传递"指向值的指针"而不是将值作为参数的输入。你可以通过解引用指针来更改指针指向的值。

因此，如果我们采用前面的`add2()`示例，我们可以通过将`x`参数标记为"指向`u32`值的指针"（即`*u32`数据类型）而不是`u32`值来更改函数体内函数参数`x`的值。通过使其成为指针，我们最终可以直接在`add2()`函数体内更改这个函数参数的值。你可以看到下面的代码示例成功编译。

```zig
const std = @import("std");
fn add2(x: *u32) void {
    const d: u32 = 2;
    x.* = x.* + d;
}

pub fn main() !void {
    var x: u32 = 4;
    add2(&x);
    std.debug.print("Result: {d}\n", .{x});
}
```

`Result: 6`

即使在上面的代码示例中，`x`参数仍然是不可变的。这意味着指针本身是不可变的。因此，你不能更改它指向的内存地址。但是，你可以解引用指针来访问它指向的值，如果需要，还可以更改这个值。

## 结构体和OOP

Zig是一种与C（这是一种过程式语言）更密切相关的语言，而不是与C++或Java（这些是面向对象的语言）相关。因此，你在Zig中没有高级的OOP（面向对象编程）模式，如类、接口或类继承。尽管如此，通过使用结构体定义，Zig中的OOP仍然是可能的。

通过结构体定义，你可以在Zig中创建（或定义）新的数据类型。这些结构体定义的工作方式与它们在C中的工作方式相同。你给这个新结构体（或你正在创建的这个新数据类型）一个名称，然后，列出这个新结构体的数据成员。你还可以在这个结构体内注册函数，它们成为这个特定结构体（或数据类型）的方法，这样，你用这个新类型创建的每个对象都将始终有这些方法可用并与它们关联。

在C++中，当我们创建一个新类时，我们通常有一个构造方法（或构造函数），用于构造（或实例化）这个特定类的每个对象，我们还有一个析构方法（或析构函数），它是负责销毁这个类的每个对象的函数。

在Zig中，我们通常通过在结构体内声明`init()`和`deinit()`方法来声明我们结构体的构造函数和析构函数方法。这只是一个命名约定，你会在整个Zig标准库中找到。所以，在Zig中，结构体的`init()`方法通常是由这个结构体表示的类的构造方法。而`deinit()`方法是用于销毁该结构体的现有实例的方法。

`init()`和`deinit()`方法在Zig代码中都被广泛使用，当我们在[第3.3节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-allocators)中讨论分配器时，你会看到它们都被使用。但是，作为另一个例子，让我们构建一个简单的`User`结构体来表示某种系统的用户。

如果你看下面的`User`结构体，你可以看到`struct`关键字。注意这个结构体的数据成员：`id`、`name`和`email`。每个数据成员都有其类型明确注释，使用我们之前在[第1.2.2节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-root-file)中描述的冒号字符（`:`）语法。但还要注意，结构体主体中描述数据成员的每一行都以逗号字符（`,`）结尾。所以每次你在Zig代码中声明数据成员时，总是用逗号字符结束该行，而不是用传统的分号字符（`;`）结束。

接下来，我们将`init()`函数注册为这个`User`结构体的方法。这个`init()`方法是我们将用来实例化每个新`User`对象的构造方法。这就是为什么这个`init()`函数返回一个新的`User`对象作为结果。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const User = struct {
    id: u64,
    name: []const u8,
    email: []const u8,

    fn init(id: u64,
            name: []const u8,
            email: []const u8) User {

        return User {
            .id = id,
            .name = name,
            .email = email
        };
    }

    fn print_name(self: User) !void {
        try stdout.print("{s}\n", .{self.name});
        try stdout.flush();
    }
};

pub fn main() !void {
    const u = User.init(1, "pedro", "email@gmail.com");
    try u.print_name();
}
```

`pedro`

### `pub`关键字

`pub`关键字在结构体声明和Zig中的OOP中扮演着重要角色。本质上，这个关键字是"public"的缩写，它使项目/组件在声明该项目/组件的模块之外可用。换句话说，如果我不在某些东西上应用`pub`关键字，这意味着这个"某些东西"只能从声明这个"某些东西"的模块内部调用/使用。

为了演示这个关键字的效果，让我们再次关注我们在前一节中声明的`User`结构体。对于我们这里的例子，让我们假设这个`User`结构体在一个名为`user.zig`的Zig模块中声明。如果我不在`User`结构体上使用`pub`关键字，这意味着我只能从声明`User`结构体的模块内创建`User`对象并调用它的方法（`print_name()`和`init()`），在这种情况下是`user.zig`模块。

这就是为什么前面的代码示例工作正常。因为我们在同一个模块内声明并使用`User`结构体。但当我们尝试从另一个模块导入并调用/使用这个结构体时，问题开始出现。例如，如果我创建一个名为`register.zig`的新模块，并将`user.zig`模块导入其中，并尝试用`User`类型注释任何变量，我会从编译器得到错误。

```zig
// register.zig
const user = @import("user.zig");
pub fn main() !void {
    const u: user.User = undefined;
    _ = u;
}
```

```
register.zig:3:18: error: 'User' is not marked 'pub'
    const u: user.User = undefined;
             ~~~~^~~~~
user.zig:3:1: note: declared here
const User = struct {
^~~~~
```

因此，如果你想在声明这个"某些东西"的模块之外使用某些东西，你必须用`pub`关键字标记它。这个"某些东西"可以是模块、结构体、函数、对象等。

对于我们这里的例子，如果我们回到`user.zig`模块，并将`pub`关键字添加到`User`结构体声明中，那么，我可以成功编译`register.zig`模块。

```zig
// user.zig
// 向`User`添加了`pub`关键字
pub const User = struct {
// ...
```

```zig
// register.zig
// 现在这工作正常！
const user = @import("user.zig");
pub fn main() !void {
    const u: user.User = undefined;
    _ = u;
}
```

现在，你认为如果我尝试从`register.zig`实际调用`User`结构体的任何方法会发生什么？例如，如果我尝试调用`init()`方法？答案是：我得到一个类似的错误消息，警告我`init()`方法没有标记为`pub`，如下所示：

```zig
const user = @import("user.zig");
pub fn main() !void {
    const u: user.User = user.User.init(
        1, "pedro", "email@gmail.com"
    );
    _ = u;
}
```

```
register.zig:3:35: error: 'init' is not marked 'pub'
    const u: user.User = user.User.init(
                         ~~~~~~~~~^~~~~
user.zig:8:5: note: declared here
    fn init(id: u64,
    ^~~~~~~
```

因此，仅仅因为我们在结构体声明上应用了`pub`关键字，这并不会使该结构体的方法也公开。如果我们想在声明该结构体的模块之外使用结构体的任何方法（如`init()`方法），我们也必须用`pub`关键字标记该方法。

回到`user.zig`模块，并用`pub`关键字标记`init()`和`print_name()`方法，使它们都可供外部世界使用，因此，使前面的代码示例工作。

```zig
// user.zig
// 向`User.init`添加了`pub`关键字
    pub fn init(
// ...
// 向`User.print_name`添加了`pub`关键字
    pub fn print_name(self: User) !void {
// ...
```

```zig
// register.zig
// 现在这工作正常！
const user = @import("user.zig");
pub fn main() !void {
    const u: user.User = user.User.init(
        1, "pedro", "email@gmail.com"
    );
    _ = u;
}
```

### 匿名结构体字面量

你可以将结构体对象声明为字面值。当我们这样做时，我们通常通过在左花括号之前写其数据类型来指定这个结构体字面量的数据类型。例如，我可以像这样写一个我们在前一节中定义的`User`类型的结构体字面值：

```zig
const eu = User {
    .id = 1,
    .name = "Pedro",
    .email = "someemail@gmail.com"
};
_ = eu;
```

然而，在Zig中，我们也可以写一个匿名结构体字面量。也就是说，你可以写一个结构体字面量，但不明确指定这个特定结构体的类型。匿名结构体是使用语法`.{}`编写的。所以，我们基本上用点字符（`.`）替换了结构体字面量的显式类型。

正如我们在[第2.4节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-type-inference)中描述的，当你在结构体字面量之前放置一个点时，`zig`编译器会自动推断这个结构体字面量的类型。本质上，`zig`编译器将寻找该结构体类型的一些提示。这个提示可以是函数参数的类型注释，或者你正在使用的函数的返回类型注释，或者现有对象的类型注释。如果编译器确实找到了这样的类型注释，它将在你的字面结构体中使用这个类型。

匿名结构体在Zig中非常常用作函数参数的输入。你已经经常看到的一个例子是`stdout`对象的`print()`函数。这个函数接受两个参数。第一个参数是一个模板字符串，它应该包含字符串格式说明符，告诉第二个参数中提供的值应该如何打印到消息中。

而第二个参数是一个结构体字面量，列出要打印到第一个参数中指定的模板消息中的值。你通常想在这里使用匿名结构体字面量，以便`zig`编译器为你完成指定这个特定匿名结构体类型的工作。

```zig
const std = @import("std");
pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("Hello, {s}!\n", .{"world"});
    try stdout.flush();
}
```

`Hello, world!`

### 结构体声明必须是常量

Zig中的类型必须是`const`或`comptime`（我们将在[第12.1节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-comptime)中更多地讨论comptime）。这意味着你不能创建新的数据类型，并用`var`关键字将其标记为变量。所以结构体声明总是常量。你不能使用`var`关键字声明新的结构体类型。它必须是`const`。

在下面的`Vec3`示例中，这个声明是允许的，因为我使用`const`关键字来声明这个新的数据类型。

```zig
const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,
};
```

### `self`方法参数

在每种具有OOP的语言中，当我们声明某个类或结构体的方法时，我们通常将此方法声明为具有`self`参数的函数。这个`self`参数是对调用该方法的对象本身的引用。

使用这个`self`参数不是强制性的。但为什么你不使用这个`self`参数呢？没有理由不使用它。因为获取存储在结构体数据成员中的数据的唯一方法是通过这个`self`参数访问它们。如果你不需要在方法内使用结构体数据成员中的数据，你很可能不需要方法。你可以在结构体声明之外将这个逻辑声明为一个简单的函数。

看看下面的`Vec3`结构体。在这个`Vec3`结构体内，我们声明了一个名为`distance()`的方法。这个方法通过遵循欧几里得空间中的距离公式计算两个`Vec3`对象之间的距离。注意这个`distance()`方法接受两个`Vec3`对象作为输入，`self`和`other`。

```zig
const std = @import("std");
const m = std.math;
const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn distance(self: Vec3, other: Vec3) f64 {
        const xd = m.pow(f64, self.x - other.x, 2.0);
        const yd = m.pow(f64, self.y - other.y, 2.0);
        const zd = m.pow(f64, self.z - other.z, 2.0);
        return m.sqrt(xd + yd + zd);
    }
};
```

`self`参数对应于调用这个`distance()`方法的`Vec3`对象。而`other`是作为输入给这个方法的单独的`Vec3`对象。在下面的例子中，`self`参数对应于对象`v1`，因为`distance()`方法是从`v1`对象调用的，而`other`参数对应于对象`v2`。

```zig
const v1 = Vec3 {
    .x = 4.2, .y = 2.4, .z = 0.9
};
const v2 = Vec3 {
    .x = 5.1, .y = 5.6, .z = 1.6
};

std.debug.print(
    "Distance: {d}\n",
    .{v1.distance(v2)}
);
```

`Distance: 3.3970575502926055`

### 关于结构体状态

有时你不需要关心结构体对象的状态。有时，你只需要实例化和使用对象，而不改变它们的状态。当你的结构体声明中有方法可能使用数据成员中存在的值，但它们不以任何方式改变结构体的这些数据成员中的值时，你可以注意到这一点。

在[第2.3.4节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-self-arg)中介绍的`Vec3`结构体就是一个例子。这个结构体有一个名为`distance()`的单一方法，这个方法确实使用了结构体所有三个数据成员（`x`、`y`和`z`）中存在的值。但同时，这个方法在任何时候都不会改变这些数据成员的值。

因此，当我们创建`Vec3`对象时，我们通常将它们创建为常量对象，就像[第2.3.4节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-self-arg)中介绍的`v1`和`v2`对象。如果我们想要，我们可以用`var`关键字将它们创建为变量对象。但因为这个`Vec3`结构体的方法在任何时候都不会改变对象的状态，所以将它们标记为变量对象是不必要的。

但为什么？我为什么在这里谈论这个？这是因为方法中的`self`参数会受到影响，这取决于结构体中存在的方法是否改变对象本身的状态。更具体地说，当你在结构体中有一个改变对象状态（即改变数据成员的值）的方法时，这个方法中的`self`参数必须以不同的方式注释。

正如我在[第2.3.4节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-self-arg)中描述的，结构体方法中的`self`参数是接收调用该方法的对象作为输入的参数。我们通常在方法中通过写`self`，后跟冒号字符（`:`），以及方法所属结构体的数据类型（例如`User`、`Vec3`等）来注释这个参数。

如果我们以前一节中定义的`Vec3`结构体为例，我们可以在`distance()`方法中看到这个`self`参数被注释为`self: Vec3`。因为`Vec3`对象的状态从未被这个方法改变。

但是，如果我们确实有一个方法通过改变其数据成员的值来改变对象的状态，在这种情况下我们应该如何注释`self`？答案是："我们应该将`self`注释为`x`的指针，而不仅仅是`x`"。换句话说，你应该将`self`注释为`self: *x`，而不是将其注释为`self: x`。

如果我们在`Vec3`对象内创建一个新方法，例如，通过将其坐标乘以2倍来扩展向量，那么，我们需要遵循前一段中指定的规则。下面的代码示例演示了这个想法：

```zig
const std = @import("std");
const m = std.math;
const Vec3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn distance(self: Vec3, other: Vec3) f64 {
        const xd = m.pow(f64, self.x - other.x, 2.0);
        const yd = m.pow(f64, self.y - other.y, 2.0);
        const zd = m.pow(f64, self.z - other.z, 2.0);
        return m.sqrt(xd + yd + zd);
    }

    pub fn twice(self: *Vec3) void {
        self.x = self.x * 2.0;
        self.y = self.y * 2.0;
        self.z = self.z * 2.0;
    }
};
```

注意在上面的代码示例中，我们向`Vec3`结构体添加了一个名为`twice()`的新方法。这个方法将我们的向量对象的坐标值加倍。在`twice()`方法的情况下，我们将`self`参数注释为`*Vec3`，表示这个参数接收指向`Vec3`对象的指针（或引用，如果你更喜欢这样称呼它）作为输入。

```zig
var v3 = Vec3 {
    .x = 4.2, .y = 2.4, .z = 0.9
};
v3.twice();
std.debug.print("Doubled: {d}\n", .{v3.x});
```

`Doubled: 8.4`

现在，如果你将这个`twice()`方法中的`self`参数更改为`self: Vec3`，就像在`distance()`方法中一样，你将得到下面暴露的编译器错误作为结果。注意这个错误消息显示了`twice()`方法主体的一行，表明你不能改变`x`数据成员的值。

```zig
// 如果我们将double的函数签名更改为：
    pub fn twice(self: Vec3) void {
```

```
t.zig:16:13: error: cannot assign to constant
        self.x = self.x * 2.0;
        ~~~~^~
```

这个错误消息表明`x`数据成员属于一个常量对象，因此，它不能被更改。最终，这个错误消息告诉我们`self`参数是常量。

如果你花一些时间，认真思考这个错误消息，你会理解它。你已经有了理解为什么我们会收到这个错误消息的工具。我们已经在[第2.2节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-fun-pars)中讨论过它。所以记住，Zig中的每个函数参数都是不可变的，`self`也不例外。

在这个例子中，我们将`v3`对象标记为变量对象。但这并不重要。因为这不是关于输入对象，而是关于函数参数。

当我们尝试直接改变`self`的值时，问题就开始了，`self`是一个函数参数，而每个函数参数默认都是不可变的。你可能会问自己如何克服这个障碍，再一次，解决方案也在[第2.2节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-fun-pars)中讨论过。我们通过明确将`self`参数标记为指针来克服这个障碍。

注意

如果你的`x`结构体的方法通过更改任何数据成员的值来改变对象的状态，那么，记住在这个方法的函数签名中使用`self: *x`，而不是`self: x`。

你也可以将本节中讨论的内容解释为："如果你需要在其中一个方法中改变`x`结构体对象的状态，你必须明确地通过引用将`x`结构体对象传递给这个方法的`self`参数"。

## 类型推断

Zig是一种强类型语言。但是，有一些情况下，你不必在源代码中明确编写每个对象的类型，就像你从传统的强类型语言（如C和C++）中期望的那样。

在某些情况下，`zig`编译器可以使用类型推断为你解决数据类型，减轻你作为开发人员承担的一些负担。最常见的方式是通过接收结构体对象作为输入的函数参数。

一般来说，Zig中的类型推断是通过使用点字符（`.`）完成的。每当你看到在结构体字面量之前、枚举值之前或类似的东西之前写的点字符，你就知道这个点字符在这个地方扮演着特殊的角色。更具体地说，它告诉`zig`编译器类似这样的内容："嘿！你能为我推断这个值的类型吗？拜托！"。换句话说，这个点字符扮演着类似于C++中`auto`关键字的角色。

我在[第2.3.2节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-anonymous-struct-literals)中给了你一些这方面的例子，我们使用了匿名结构体字面量。匿名结构体字面量是使用类型推断来推断这个特定结构体字面量的确切类型的结构体字面量。这种类型推断是通过寻找正确数据类型的一些最小提示来完成的。你可以说`zig`编译器寻找任何可能告诉它正确类型的邻近类型注释。

我们在Zig中使用类型推断的另一个常见地方是在switch语句中（我们在[第2.1.2节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-switch)中讨论过）。我还在[第2.1.2节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-switch)中给出了类型推断的其他一些例子，我们在switch语句内列出的枚举值的数据类型进行推断（例如`.DE`）。但作为另一个例子，看看下面复制的`fence()`函数，它来自Zig标准库的[`atomic.zig`模块](https://github.com/ziglang/zig/blob/master/lib/std/atomic.zig)。

这个函数中有很多我们还没有讨论过的东西，例如：`comptime`是什么意思？`inline`？`extern`？让我们忽略所有这些东西，只关注这个函数内的switch语句。

我们可以看到这个switch语句使用`order`对象作为输入。这个`order`对象是这个`fence()`函数的输入之一，我们可以在类型注释中看到，这个对象的类型是`AtomicOrder`。我们还可以在switch语句内看到一堆以点字符开头的值，如`.release`和`.acquire`。

因为这些奇怪的值在它们之前包含一个点字符，我们要求`zig`编译器推断switch语句内这些值的类型。然后，`zig`编译器查看使用这些值的当前上下文，并尝试推断这些值的类型。

由于它们在switch语句内使用，`zig`编译器查看给switch语句的输入对象的类型，在这种情况下是`order`对象。因为这个对象的类型是`AtomicOrder`，`zig`编译器推断这些值是这个`AtomicOrder`类型的数据成员。

```zig
pub inline fn fence(self: *Self, comptime order: AtomicOrder) void {
    // 省略了许多行代码...
    if (builtin.sanitize_thread) {
        const tsan = struct {
            extern "c" fn __tsan_acquire(addr: *anyopaque) void;
            extern "c" fn __tsan_release(addr: *anyopaque) void;
        };

        const addr: *anyopaque = self;
        return switch (order) {
            .unordered, .monotonic => @compileError(
                @tagName(order)
                ++ " only applies to atomic loads and stores"
            ),
            .acquire => tsan.__tsan_acquire(addr),
            .release => tsan.__tsan_release(addr),
            .acq_rel, .seq_cst => {
                tsan.__tsan_acquire(addr);
                tsan.__tsan_release(addr);
            },
        };
    }

    return @fence(order);
}
```

这就是Zig中基本类型推断的完成方式。如果我们在这个switch语句内的值之前不使用点字符，那么，我们将被迫明确编写这些值的数据类型。例如，我们将不得不写`AtomicOrder.release`而不是写`.release`。我们将不得不为这个switch语句中的每个值都这样做，这是很多工作。这就是为什么类型推断在Zig的switch语句中常用的原因。

## 类型转换

在本节中，我想与你讨论类型转换（或类型转换）。当我们有一个类型为"x"的对象，并且我们想将其转换为类型为"y"的对象时，我们使用类型转换，即我们想要更改对象的数据类型。

大多数语言都有执行类型转换的正式方法。例如，在Rust中，我们通常使用关键字`as`，在C中，我们通常使用类型转换语法，例如`(int) x`。在Zig中，我们使用`@as()`内置函数将类型为"x"的对象转换为类型为"y"的对象。

这个`@as()`函数是在Zig中执行类型转换（或类型转换）的首选方法。因为它是明确的，而且，它也只在转换是明确和安全的情况下执行转换。要使用这个函数，你只需在第一个参数中提供目标数据类型，并在第二个参数中提供你想要转换的对象。

```zig
const std = @import("std");
const expect = std.testing.expect;
test {
    const x: usize = 500;
    const y = @as(u32, x);
    try expect(@TypeOf(y) == u32);
}
```

```
1/1 file51b479756626.test_0...OK
All 1 tests passed.
```

这是在Zig中执行类型转换的一般方法。但请记住，`@as()`仅在转换是明确和安全的情况下工作。有许多情况下这些假设不成立。例如，

当将整数值转换为浮点值，或反之亦然时，编译器不清楚如何安全地执行此转换。

因此，我们需要在这种情况下使用专门的"转换函数"。例如，如果你想将整数值转换为浮点值，那么，你应该使用`@floatFromInt()`函数。在相反的情况下，你应该使用`@intFromFloat()`函数。

在这些函数中，你只需提供要转换的对象作为输入。然后，"类型转换操作"的目标数据类型由保存结果的对象的类型注释决定。在下面的例子中，我们将对象`x`转换为类型`f32`的值，因为对象`y`（我们保存结果的地方）被注释为类型`f32`的对象。

```zig
const std = @import("std");
const expect = std.testing.expect;
test {
    const x: usize = 565;
    const y: f32 = @floatFromInt(x);
    try expect(@TypeOf(y) == f32);
}
```

```
1/1 file51b47d8b5914.test_0...OK
All 1 tests passed.
```

执行类型转换操作时非常有用的另一个内置函数是`@ptrCast()`。本质上，当我们想要明确地将Zig值/对象从类型"x"转换（或转换）为类型"y"等时，我们使用`@as()`内置函数。然而，指针（我们将在[第6章](https://pedropark99.github.io/zig-book/Chapters/05-pointers.html)中更深入地讨论指针）是Zig中的特殊类型的对象，即它们与"普通对象"的处理方式不同。

每当指针涉及Zig中的某些"类型转换操作"时，就会使用`@ptrCast()`函数。这个函数的工作方式类似于`@floatFromInt()`。你只需提供要转换的指针对象作为这个函数的输入，目标数据类型再次由存储结果的对象的类型注释决定。

```zig
const std = @import("std");
const expect = std.testing.expect;
test {
    const bytes align(@alignOf(u32)) = [_]u8{
        0x12, 0x12, 0x12, 0x12
    };
    const u32_ptr: *const u32 = @ptrCast(&bytes);
    try expect(@TypeOf(u32_ptr) == *const u32);
}
```

```
1/1 file51b423a155ad.test_0...OK
All 1 tests passed.
```

## 模块

我们已经讨论了什么是模块，以及如何通过_import语句_将其他模块导入到当前模块中。你在项目中编写的每个Zig模块（即`.zig`文件）在内部都存储为结构体对象。以下面暴露的行为例。在这一行中，我们将Zig标准库导入到当前模块中。

`const std = @import("std");`

当我们想要访问标准库的函数和对象时，我们基本上是在访问存储在`std`对象中的结构体的数据成员。这就是为什么我们使用与普通结构体中相同的语法，使用点操作符（`.`）来访问结构体的数据成员和方法。

当这个"import语句"被执行时，这个表达式的结果是一个包含Zig标准库模块、全局变量、函数等的结构体对象。这个结构体对象被保存（或存储）在名为`std`的常量对象中。

以[项目`zap`的`thread_pool.zig`模块](https://github.com/kprotty/zap/blob/blog/src/thread_pool.zig)为例。这个模块被编写得好像它是一个大结构体。这就是为什么我们在这个模块中编写了一个顶级的公共`init()`方法。想法是在这个模块中编写的所有顶级函数都是结构体的方法，所有顶级对象和结构体声明都是这个结构体的数据成员。模块就是结构体本身。

所以你会通过做这样的事情来导入和使用这个模块：

```zig
const std = @import("std");
const ThreadPool = @import("thread_pool.zig");
const num_cpus = std.Thread.getCpuCount()
    catch @panic("failed to get cpu core count");
const num_threads = std.math.cast(u16, num_cpus)
    catch std.math.maxInt(u16);
const pool = ThreadPool.init(
    .{ .max_threads = num_threads }
);
```

---

脚注翻译：

1. [https://github.com/ziglang/zig/blob/master/lib/std/debug.zig](https://github.com/ziglang/zig/blob/master/lib/std/debug.zig)
2. [https://github.com/ziglang/zig/blob/master/lib/std/atomic.zig](https://github.com/ziglang/zig/blob/master/lib/std/atomic.zig)
3. [https://github.com/kprotty/zap/blob/blog/src/thread_pool.zig](https://github.com/kprotty/zap/blob/blog/src/thread_pool.zig)
