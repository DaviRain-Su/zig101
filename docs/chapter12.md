# 第12章 项目3 - 构建栈数据结构 - Zig入门介绍

在本章中，我们将实现一个栈数据结构作为本书的下一个小项目。在任何语言中实现基本数据结构都算是计算机科学（CS）中的"幼儿园任务"（如果这个术语存在的话），因为我们通常在CS的第一学期就学习并实现它们。

但这其实很好！由于这应该是一个非常简单的任务，我们不需要花太多时间解释什么是栈，然后，我们可以专注于这里真正重要的内容，即学习"泛型"的概念在Zig语言中是如何实现的，以及Zig的关键特性之一——comptime是如何工作的，并使用栈数据结构来动态演示这些概念。

但在我们开始构建栈数据结构之前，我们首先需要了解`comptime`关键字对你的代码做了什么，之后，我们还需要学习泛型在Zig中是如何工作的。

## 理解Zig中的`comptime`

Zig的关键特性之一是`comptime`。这个关键字引入了一个全新的概念和范式，与编译过程紧密相关。在[第3.1.1节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-compile-time)中，我们描述了"编译时与运行时"在Zig中扮演的重要性和角色。在那一节中，我们了解到应用于值/对象的规则会根据该值是在编译时已知还是仅在运行时已知而发生很大变化。

`comptime`关键字与这两个时间空间（编译时和运行时）密切相关。让我们快速回顾一下区别。编译时是你的Zig源代码被`zig`编译器编译的时间段，而运行时是你的Zig程序正在执行的时间段，即当我们执行由`zig`编译器生成的二进制文件时。

有三种方式可以应用`comptime`关键字，它们是：

* 在函数参数上应用`comptime`。
* 在对象上应用`comptime`。
* 在表达式块上应用`comptime`。

### 应用于函数参数

当你在函数参数上应用`comptime`关键字时，你是在告诉`zig`编译器，分配给该特定函数参数的值必须在编译时已知。我们在[第3.1.1节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-compile-time)中详细解释了"编译时已知的值"到底意味着什么。所以如果你对这个想法有任何疑问，请回顾那一节。

现在让我们思考这个想法的后果。首先，我们对该特定函数参数施加了限制或要求。如果程序员不小心尝试给这个函数参数一个不是在编译时已知的值，`zig`编译器会注意到这个问题，因此，它会引发编译错误，说它无法编译你的程序。因为你正在向必须是"编译时已知"的函数参数提供一个"运行时已知"的值。

看看下面这个非常简单的例子，我们定义了一个`twice()`函数，它简单地将名为`num`的输入值加倍。注意我们在函数参数名称之前使用`comptime`关键字。这个关键字将函数参数`num`标记为"comptime参数"。

这是一个函数参数，其值必须是编译时已知的。这就是为什么表达式`twice(5678)`是有效的，并且没有引发编译错误。因为值`5678`是编译时已知的，所以这是这个函数的预期行为。

```zig
fn twice(comptime num: u32) u32 {
    return num * 2;
}
test "test comptime" {
    _ = twice(5678);
}
```

```
1/1 file4b00475bc85e.test.test comptime...OKAll 1
   tests passed.
```

但如果我们向这个函数提供一个不是编译时已知的数字会怎样？例如，你的程序可能通过系统的`stdin`通道接收用户的一些输入。这个来自用户的输入可能是许多不同的东西，并且无法在编译时预测。这些情况使得这个"来自用户的输入"成为一个仅在运行时已知的值。

在下面的例子中，这个"来自用户的输入"最初作为字符串接收，然后被解析并转换为整数值，这个操作的结果存储在`n`对象中。

因为"用户的输入"仅在运行时已知，所以对象`n`的值仅在运行时确定。因此，我们不能将这个对象作为输入提供给`twice()`函数。`zig`编译器不会允许它，因为我们将`num`参数标记为"comptime参数"。这就是为什么`zig`编译器引发下面暴露的编译时错误：

```zig
const std = @import("std");
fn twice(comptime num: u32) u32 {
    return num * 2;
}

pub fn main() !void {
    var buffer: [5]u8 = .{ 0, 0, 0, 0, 0 };
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    const stdin = std.io.getStdIn().reader();
    _ = try stdout.write("Please write a 4-digit integer number\n");
    _ = try stdin.readUntilDelimiter(&buffer, '\n');

    try stdout.print("Input: {s}", .{buffer});
    const n: u32 = try std.fmt.parseInt(
        u32, buffer[0 .. buffer.len - 1], 10
    );
    const twice_result = twice(n);
    try stdout.print("Result: {d}\n", .{twice_result});
    try stdout.flush();
}
```

```
t.zig:12:16: error: unable to resolve comptime value
    const twice_result = twice(n);
                               ^
```

Comptime参数经常用于返回某种通用结构的函数。事实上，`comptime`是在Zig中制作泛型的本质（或基础）。我们将在[第12.2节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-generics)中更多地讨论泛型。

现在，让我们看看Seguin（[2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-karlseguin_generics)）的这个代码示例。你可以看到这个`IntArray()`函数有一个名为`length`的参数。这个参数被标记为comptime，并接收类型为`usize`的值作为输入。所以给这个参数的值必须是编译时已知的。我们还可以看到这个函数返回一个`i64`值数组作为输出。

```zig
fn IntArray(comptime length: usize) type {
    return [length]i64;
}
```

现在，这个函数的关键组件是`length`参数。这个参数用于确定函数产生的数组的大小。让我们思考一下这个的后果。如果数组的大小依赖于分配给`length`参数的值，这意味着函数输出的数据类型取决于这个`length`参数的值。

让这个陈述在你的脑海中沉淀一会儿。正如我在[第1.2.2节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-root-file)中所述，Zig是一种强类型语言，特别是在函数声明上。所以每次我们在Zig中编写函数时，我们都必须注解函数返回值的数据类型。但是如果这个数据类型依赖于给函数参数的值，我们该怎么做呢？

想一想这个问题。例如，如果`length`等于3，那么函数的返回类型是`[3]i64`。但如果`length`等于40，那么返回类型就变成`[40]i64`。在这一点上，`zig`编译器会感到困惑，并引发编译错误，说一些类似这样的话：

> 嘿！你已经注解这个函数应该返回一个`[3]i64`值，但我得到了一个`[40]i64`值！这看起来不对！

那么你如何解决这个问题？我们如何克服这个障碍？这就是`type`关键字的用武之地。这个`type`关键字基本上是告诉`zig`编译器，这个函数将返回某种数据类型作为输出，但它还不知道到底是什么数据类型。我们将在[第12.2节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-generics)中更多地讨论这个。

### 应用于表达式

当你在表达式上应用`comptime`关键字时，就保证了`zig`编译器将在编译时执行这个表达式。如果由于某种原因，这个表达式无法在编译时执行（例如，也许这个表达式依赖于仅在运行时已知的值），那么`zig`编译器将引发编译错误。

看看这个来自Zig官方文档的例子（[Zig Software Foundation 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-zigdocs)）。我们在运行时和编译时都执行相同的`fibonacci()`函数。该函数默认在运行时执行，但因为我们在第二个"try表达式"中使用`comptime`关键字，所以这个表达式在编译时执行。

这对某些人来说可能有点困惑。是的！当我说这个表达式在编译时执行时，我的意思是这个表达式在`zig`编译器编译你的Zig源代码时被编译并执行。

```zig
const expect = @import("std").testing.expect;
fn fibonacci(index: u32) u32 {
    if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

test "fibonacci" {
    // 在运行时测试fibonacci
    try expect(fibonacci(7) == 13);
    // 在编译时测试fibonacci
    try comptime expect(fibonacci(7) == 13);
}
```

```
1/1 file4b007f6ded77.test.fibonacci...OKAll 1 test
  ts passed.
```

你的大量Zig源代码可能会在编译时执行，因为`zig`编译器可以计算出某些表达式的输出。特别是如果这些表达式仅依赖于编译时已知的值。我们在[第3.1.1节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-compile-time)中讨论过这个。

但当你在表达式上使用`comptime`关键字时，就不再有"它可能在编译时执行"了。使用`comptime`关键字，你是在命令`zig`编译器在编译时执行这个表达式。你正在强制执行这个规则，保证编译器将始终在编译时执行它。或者，至少，编译器会尝试执行它。如果编译器由于任何原因无法执行表达式，编译器将引发编译错误。

### 应用于块

块在[第1.7节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-blocks)中描述过。当你将`comptime`关键字应用于表达式块时，你得到的效果基本上与将此关键字应用于单个表达式时相同。也就是说，整个表达式块由`zig`编译器在编译时执行。

在下面的例子中，我们将标记为`blk`的块标记为comptime块，因此，这个块内的表达式在编译时执行。

```zig
const expect = @import("std").testing.expect;
fn fibonacci(index: u32) u32 {
    if (index < 2) return index;
    return fibonacci(index - 1) + fibonacci(index - 2);
}

test "fibonacci in a block" {
    const x = comptime blk: {
        const n1 = 5;
        const n2 = 2;
        const n3 = n1 + n2;
        try expect(fibonacci(n3) == 13);
        break :blk n3;
    };
    _ = x;
}
```

```
1/1 file4b004fcd2f2.test.fibonacci in a block...OK
  KAll 1 tests passed.
```

## 介绍泛型

首先，什么是泛型？泛型是允许类型（`f64`、`u8`、`u32`、`bool`，以及用户定义的类型，如我们在[第2.3节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-structs-and-oop)中定义的`User`结构）成为方法、类和接口的参数的想法（[Geeks for Geeks 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-geeks_generics)）。换句话说，"泛型"是可以处理多种数据类型的类（或方法）。

例如，在Java中，泛型是通过操作符`<>`创建的。使用这个操作符，Java类能够接收数据类型作为输入，因此，类可以根据这个输入数据类型调整其功能。作为另一个例子，C++中的泛型是通过模板的概念支持的。C++中的类模板就是泛型。

在Zig中，泛型是通过`comptime`实现的。`comptime`关键字允许我们在编译时收集数据类型，并将此数据类型作为输入传递给一段代码。

### 泛型函数

以下面暴露的`max()`函数作为第一个例子。这个函数本质上是一个"泛型函数"。在这个函数中，我们有一个名为`T`的comptime函数参数。注意这个`T`参数有一个`type`的数据类型。奇怪吧？这个`type`关键字是Zig中"所有类型之父"，或"类型的类型"。

因为我们在`T`参数中使用了这个`type`关键字，我们告诉`zig`编译器这个`T`参数将接收某种数据类型作为输入。还要注意在这个参数中使用`comptime`关键字。正如我在[第12.1节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-comptime)中所述，每次你在函数参数中使用这个关键字时，这意味着这个参数的值必须在编译时已知。这很有道理，对吧？因为没有数据类型不是在编译时已知的。

想想这个。你将要编写的每个数据类型始终在编译时已知。特别是因为数据类型是编译器实际编译源代码的基本信息。考虑到这一点，将这个参数标记为comptime参数是有意义的。

```zig
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}
```

还要注意，`T`参数的值实际上用于定义函数中其他参数`a`和`b`的数据类型，以及函数的返回类型注解。也就是说，这些参数（`a`和`b`）的数据类型，以及函数本身的返回数据类型，由给`T`参数的输入值决定。

因此，我们有一个适用于不同数据类型的泛型函数。例如，我可以向这个`max()`函数提供`u8`值，它会按预期工作。但如果我改为提供`f64`值，它也会按预期工作。没有泛型函数，我将不得不为每种我想使用的数据类型编写不同的`max()`函数。这个泛型函数为我们提供了一个非常有用的快捷方式。

```zig
const std = @import("std");
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}
test "test max" {
    const n1 = max(u8, 4, 10);
    std.debug.print("Max n1: {d}\n", .{n1});
    const n2 = max(f64, 89.24, 64.001);
    std.debug.print("Max n2: {d}\n", .{n2});
}
```

```
Max n1: 10
Max n2: 89.24
```

### 泛型数据结构

你在Zig标准库中找到的每个数据结构（例如`ArrayList`、`HashMap`等）本质上都是泛型数据结构。这些数据结构是泛型的，因为它们可以处理你想要的任何数据类型。你只需说明将要存储在这个数据结构中的值的数据类型，它们就会按预期工作。

Zig中的泛型数据结构是你复制Java的泛型类或C++的类模板的方式。但你可能会问自己：我们如何在Zig中构建泛型数据结构？

基本思想是编写一个泛型函数，为我们想要的特定类型创建数据结构定义。换句话说，这个泛型函数表现得像一个"数据结构工厂"。泛型函数输出为特定数据类型定义此数据结构的`struct`定义。

要创建这样的函数，我们需要向这个函数添加一个comptime参数，该参数接收数据类型作为输入。我们已经在前一节（[第12.2.1节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-generic-fun)）中学习了如何做到这一点。我认为演示如何创建泛型数据结构的最佳方式是实际编写一个。这就是我们进入本书下一个小项目的地方。这是一个非常小的项目，即编写一个泛型栈数据结构。

## 什么是栈？

栈数据结构是遵循LIFO（_后进先出_）原则的结构。栈数据结构通常只支持两种操作，即`push`和`pop`。`push`操作用于向栈添加新值，而`pop`用于从栈中删除值。

当人们试图解释栈数据结构如何工作时，他们使用的最常见类比是一叠盘子。想象你有一叠盘子，例如，你桌子上的10个盘子。每个盘子代表当前存储在这个栈中的一个值。

我们从10个不同值或10个不同盘子的栈开始。现在，想象你想向这个栈添加一个新盘子（或新值），这转换为`push`操作。你会通过将新盘子放在栈顶来添加这个盘子（或这个值）。然后，你会将栈增加到11个盘子。

但是你如何从这个栈中删除盘子（或删除值）（也就是`pop`操作）？要做到这一点，我们必须删除栈顶的盘子，因此，我们会再次拥有10个盘子的栈。

这演示了LIFO概念，因为栈中的第一个盘子，即栈底的盘子，总是最后一个离开栈的盘子。想想看。为了从栈中删除这个特定的盘子，我们必须删除栈中的所有盘子。所以栈中的每个操作，无论是插入还是删除，总是在栈顶进行。下面的[图12.1](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#fig-stack)直观地展示了这个逻辑：

![图片1](https://pedropark99.github.io/zig-book/Figures/lifo-stack.svg)

图12.1：栈结构图解。来源：维基百科，自由的百科全书。

## 编写栈数据结构

我们将分两步编写栈数据结构。首先，我们将实现一个只能存储`u32`值的栈。然后，之后，我们将扩展我们的实现使其成为泛型，以便它可以处理我们想要的任何数据类型。

首先，我们需要决定值将如何存储在栈内。有多种方法可以实现栈结构背后的存储。有些人喜欢使用双向链表，其他人喜欢使用动态数组等。在这个例子中，我们将在底层使用数组来存储栈中的值，这是我们`Stack`结构定义的`items`数据成员。

还要注意在我们的`Stack`结构中，我们有其他三个数据成员：`capacity`、`length`和`allocator`。`capacity`成员包含存储栈中值的底层数组的容量。`length`包含当前存储在栈中的值数量。`allocator`包含分配器对象，栈结构在需要为正在存储的值分配更多空间时将使用它。

我们首先定义这个结构的`init()`方法，它将负责实例化一个`Stack`对象。注意，在这个`init()`方法内部，我们首先分配一个具有`capacity`参数中指定容量的数组。

```zig
const std = @import("std");
const Allocator = std.mem.Allocator;
const Stack = struct {
    items: []u32,
    capacity: usize,
    length: usize,
    allocator: Allocator,

    pub fn init(allocator: Allocator, capacity: usize) !Stack {
        var buf = try allocator.alloc(u32, capacity);
        return .{
            .items = buf[0..],
            .capacity = capacity,
            .length = 0,
            .allocator = allocator,
        };
    }
};
```

### 实现`push`操作

现在我们已经编写了创建新`Stack`对象的基本逻辑，我们可以开始编写负责执行push操作的逻辑。记住，栈数据结构中的push操作是负责向栈添加新值的操作。

那么我们如何向我们拥有的`Stack`对象添加新值呢？下面暴露的`push()`函数是这个问题的一个可能答案。记住我们在[第12.3节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-what-stack)中讨论的，值总是添加到栈顶。这意味着这个`push()`函数必须始终找到底层数组中当前代表栈顶位置的元素，然后在那里添加输入值。

首先，我们在这个函数中有一个if语句。这个if语句正在检查我们是否需要扩展底层数组来存储我们正在添加到栈的这个新值。换句话说，也许底层数组没有足够的容量来存储这个新值，在这种情况下，我们需要扩展我们的数组以获得我们需要的容量。

所以，如果这个if语句中的逻辑测试返回true，这意味着数组没有足够的容量，我们需要在存储这个新值之前扩展它。所以在这个if语句内部，我们正在执行扩展底层数组所需的表达式。注意我们使用分配器对象来分配一个比当前数组大两倍的新数组（`self.capacity * 2`）。

之后，我们使用另一个名为`@memcpy()`的内置函数。这个内置函数相当于C标准库的`memcpy()`函数。它用于将值从一个内存块复制到另一个内存块。换句话说，你可以使用这个函数将值从一个数组复制到另一个数组。

我们使用这个`@memcpy()`内置函数将当前存储在栈对象的底层数组（`self.items`）中的值复制到我们分配的新的更大数组（`new_buf`）中。执行这个函数后，`new_buf`包含`self.items`中存在的值的副本。

现在我们已经在`new_buf`对象中保护了当前值的副本，我们现在可以释放当前在`self.items`分配的内存。之后，我们只需要将新的更大数组分配给`self.items`。这是扩展数组所需的步骤序列。

```zig
pub fn push(self: *Stack, val: u32) !void {
    if ((self.length + 1) > self.capacity) {
        var new_buf = try self.allocator.alloc(
            u32, self.capacity * 2
        );
        @memcpy(
            new_buf[0..self.capacity], self.items
        );
        self.allocator.free(self.items);
        self.items = new_buf;
        self.capacity = self.capacity * 2;
    }

    self.items[self.length] = val;
    self.length += 1;
}
```

在我们确保有足够的空间存储我们正在添加到栈的这个新值之后，我们所要做的就是将这个值分配给栈中的顶部元素，并将`length`属性的值增加一。我们通过使用`length`属性找到栈中的顶部元素。

### 实现`pop`操作

现在我们可以实现栈对象的pop操作。这是一个更容易实现的操作，下面的`pop()`方法总结了所需的所有逻辑。

我们只需要找到底层数组中当前代表栈顶的元素，并将此元素设置为"undefined"，以指示此元素为"空"。之后，我们还需要将栈的`length`属性减一。

如果栈的当前长度为零，这意味着当前栈中没有存储任何值。所以，在这种情况下，我们可以直接从函数返回，什么都不做。这就是函数内部的if语句正在检查的内容。

```zig
pub fn pop(self: *Stack) void {
    if (self.length == 0) return;

    self.items[self.length - 1] = undefined;
    self.length -= 1;
}
```

### 实现`deinit`方法

我们已经实现了负责与栈数据结构相关的两个主要操作的方法，即`pop()`和`push()`，我们还实现了负责实例化新`Stack`对象的方法，即`init()`方法。

但现在，我们还需要实现负责销毁`Stack`对象的方法。在Zig中，这个任务通常与名为`deinit()`的方法相关联。Zig中的大多数结构对象都有这样的方法，它通常被昵称为"析构方法"。

理论上，销毁`Stack`对象我们所要做的就是确保使用存储在`Stack`对象内部的分配器对象释放为底层数组分配的内存。这就是下面的`deinit()`方法正在做的。

```zig
pub fn deinit(self: *Stack) void {
    self.allocator.free(self.items);
}
```

## 使其成为泛型

现在我们已经实现了栈数据结构的基本骨架，我们现在可以专注于讨论如何使其成为泛型。我们如何使这个基本骨架不仅可以处理`u32`值，还可以处理我们想要的任何其他数据类型？例如，我们可能需要创建一个栈对象来存储`User`值。我们如何使这成为可能？答案在于使用泛型和`comptime`。

正如我在[第12.2.2节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-generic-struct)中所述，基本思想是编写一个返回结构定义作为输出的泛型函数。理论上，我们不需要太多就可以将我们的`Stack`结构转换为泛型数据结构。我们需要做的就是将栈的底层数组转换为泛型数组。

换句话说，这个底层数组需要是一个"变色龙"。它需要适应，并将其转换为我们想要的任何数据类型的数组。例如，如果我们需要创建一个将存储`u8`值的栈，那么这个底层数组需要是一个`u8`数组（即`[]u8`）。但如果我们需要存储`User`值，那么，这个数组需要是一个`User`数组（即`[]User`）。等等。

我们通过使用泛型函数来做到这一点。因为泛型函数可以接收数据类型作为输入，我们可以将此数据类型传递给我们`Stack`对象的结构定义。因此，我们可以使用泛型函数创建一个可以存储我们想要的数据类型的`Stack`对象。如果我们想创建一个存储`User`值的栈结构，我们将`User`数据类型传递给这个泛型函数，它将为我们创建描述可以在其中存储`User`值的`Stack`对象的结构定义。

看看下面的代码示例。为了简洁起见，我省略了`Stack`结构定义的某些部分。但是，如果我们的`Stack`结构的特定部分没有在这个例子中暴露，那是因为这部分与前面的例子相比没有改变。它保持不变。

```zig
fn Stack(comptime T: type) type {
    return struct {
        items: []T,
        capacity: usize,
        length: usize,
        allocator: Allocator,
        const Self = @This();

        pub fn init(allocator: Allocator,
                    capacity: usize) !Stack(T) {
            var buf = try allocator.alloc(T, capacity);
            return .{
                .items = buf[0..],
                .capacity = capacity,
                .length = 0,
                .allocator = allocator,
            };
        }

        pub fn push(self: *Self, val: T) !void {
        // 截断结构的其余部分
    };
}
```

注意我们在这个例子中创建了一个名为`Stack()`的函数。这个函数接受一个类型作为输入，并将此类型传递给我们`Stack`对象的结构定义。数据成员`items`现在是类型`T`的数组，这是我们作为输入提供给函数的数据类型。`push()`函数中的函数参数`val`现在也是类型`T`的值。

我们可以向这个函数提供一个数据类型，它将创建一个可以存储我们提供的数据类型值的`Stack`对象的定义。在下面的例子中，我们正在创建可以存储`u8`值的`Stack`对象的定义。这个定义存储在`Stacku8`对象中。这个`Stacku8`对象成为我们的新结构，我们将使用它来创建我们的`Stack`对象。

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
const Stacku8 = Stack(u8);
var stack = try Stacku8.init(allocator, 10);
defer stack.deinit();
try stack.push(1);
try stack.push(2);
try stack.push(3);
try stack.push(4);
try stack.push(5);
try stack.push(6);

std.debug.print("Stack len: {d}\n", .{stack.length});
std.debug.print("Stack capacity: {d}\n", .{stack.capacity});

stack.pop();
std.debug.print("Stack len: {d}\n", .{stack.length});
stack.pop();
std.debug.print("Stack len: {d}\n", .{stack.length});
std.debug.print(
    "Stack state: {any}\n",
    .{stack.items[0..stack.length]}
);
```

```
Stack len: 6
Stack capacity: 10
Stack len: 5
Stack len: 4
Stack state: { 1, 2, 3, 4, 0, 0, 0, 0, 0, 0 }
```

Zig标准库中的每个泛型数据结构（`ArrayList`、`HashMap`、`SinglyLinkedList`等）都是通过这个逻辑实现的。它们使用泛型函数创建可以处理你作为输入提供的数据类型的结构定义。

## 结论

本章讨论的栈结构的完整源代码可在本书的官方存储库中免费获得。只需查看存储库的`ZigExamples`文件夹中可用的[`stack.zig`](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/data-structures/stack.zig)以获取我们栈的`u32`版本，以及[`generic_stack.zig`](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/data-structures/generic_stack.zig)以获取泛型版本。

---

## 脚注

1.   [https://www.tutorialspoint.com/c_standard_library/c_function_memcpy.htm](https://www.tutorialspoint.com/c_standard_library/c_function_memcpy.htm)[↩︎](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#fnref1)

2.   [https://github.com/pedropark99/zig-book/tree/main/ZigExamples/data-structures/stack.zig](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/data-structures/stack.zig)[↩︎](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#fnref2)

3.   [https://github.com/pedropark99/zig-book/tree/main/ZigExamples/data-structures/generic_stack.zig](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/data-structures/generic_stack.zig)[↩︎](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#fnref3)
