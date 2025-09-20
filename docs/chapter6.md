# 第6章 指针和可选值 - Zig语言入门

在我们的下一个项目中，我们将从头开始构建一个HTTP服务器。但为了做到这一点，我们需要了解更多关于指针以及它们在Zig中如何工作的知识。Zig中的指针类似于C中的指针。但它们在Zig中带有一些额外的优势。

指针是一个包含内存地址的对象。这个内存地址是内存中存储特定值的地址。它可以是任何值。大多数时候，它是来自我们代码中存在的另一个对象（或变量）的值。

在下面的例子中，我创建了两个对象（`number`和`pointer`）。`pointer`对象包含存储`number`对象的值（数字5）的内存地址。所以，简而言之，这就是指针。它是指向内存中特定现有值的内存地址。你也可以说，`pointer`对象指向存储`number`对象的内存地址。

```zig
const number: u8 = 5;
const pointer = &number;
_ = pointer;
```

我们通过使用`&`运算符在Zig中创建指针对象。当你将这个运算符放在现有对象的名称之前时，你会得到这个对象的内存地址作为结果。当你将这个内存地址存储在新对象中时，这个新对象就成为指针对象。因为它存储了一个内存地址。

人们主要使用指针作为访问特定值的替代方式。例如，我可以使用`pointer`对象来访问`number`对象存储的值。访问指针"指向"的值的这个操作通常称为_解引用指针_。我们可以通过使用指针对象的`*`方法在Zig中解引用指针。就像下面的例子，我们获取`pointer`对象指向的数字5，并将其加倍。

```zig
const number: u8 = 5;
const pointer = &number;
const doubled = 2 * pointer.*;
std.debug.print("{d}\n", .{doubled});
```

`10`

这种解引用指针的语法很好。因为我们可以轻松地将它与指针指向的值的方法链接起来。我们可以使用在[第2.3节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-structs-and-oop)中创建的`User`结构体作为例子。如果你回到那一节，你会看到这个结构体有一个名为`print_name()`的方法。

因此，例如，如果我们有一个用户对象，以及一个指向这个用户对象的指针，我们可以使用指针来访问这个用户对象，同时，通过将解引用方法（`*`）与`print_name()`方法链接起来，在其上调用方法`print_name()`。就像下面的例子：

```zig
const u = User.init(1, "pedro", "email@gmail.com");
const pointer = &u;
try pointer.*.print_name();
```

`pedro`

我们还可以使用指针来有效地改变对象的值。例如，我可以使用`pointer`对象将对象`number`的值设置为6，如下面的例子所示。

```zig
var number: u8 = 5;
const pointer = &number;
pointer.* = 6;
try stdout.print("{d}\n", .{number});
try stdout.flush();
```

`6`

因此，正如我之前提到的，人们使用指针作为访问特定值的替代方式。他们特别在不想"移动"这些值时使用它。有些情况下，你想在代码的不同作用域（即不同位置）访问特定值，但你不想将这个值"移动"到你所在的这个新作用域（或位置）。

如果这个值的大小很大，这一点尤其重要。因为如果是这样，那么移动这个值就成为一个昂贵的操作。计算机将不得不花费相当多的时间将这个值复制到这个新位置。

因此，许多程序员更喜欢通过指针访问这个值，从而避免将值复制到新位置的繁重操作。我们将在接下来的部分更多地讨论这个"移动操作"。现在，只需记住避免这个"移动操作"是在编程语言中使用指针的主要原因之一。

## 常量对象与变量对象

你可以有一个指向常量对象的指针，或者一个指向变量对象的指针。但无论这个指针是什么，指针**必须始终尊重它所指向的对象的特征**。因此，如果指针指向常量对象，那么，你不能使用这个指针来改变它指向的值。因为它指向一个常量值。正如我们在[第1.4节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-assignments)中讨论的，你不能改变常量值。

例如，如果我有一个`number`对象，它是常量，我不能执行下面的表达式，我试图通过`pointer`对象将`number`的值更改为6。如下所示，当你尝试做这样的事情时，你会得到一个编译时错误：

```zig
const number = 5;
const pointer = &number;
pointer.* = 6;
```

```
p.zig:6:12: error: cannot assign to constant
    pointer.* = 6;
```

如果我通过引入`var`关键字将`number`对象更改为变量对象，那么，我可以通过指针成功更改这个对象的值，如下所示：

```zig
var number: u8 = 5;
const pointer = &number;
pointer.* = 6;
try stdout.print("{d}\n", .{number});
try stdout.flush();
```

`6`

你可以在指针对象的数据类型上看到这种"常量与变量"的关系。换句话说，指针对象的数据类型已经给你一些关于它指向的值是否为常量的线索。

当指针对象指向常量值时，这个指针的数据类型为`*const T`，意思是"指向类型`T`的常量值的指针"。相反，如果指针指向变量值，那么，指针的类型通常是`*T`，这只是"指向类型`T`的值的指针"。因此，每当你看到数据类型格式为`*const T`的指针对象时，你就知道你不能使用这个指针来改变它指向的值。因为这个指针指向类型`T`的常量值。

我们已经讨论了指针指向的值是否为常量，以及由此产生的后果。但是，指针对象本身呢？我的意思是，如果指针对象本身是常量或不是，会发生什么？想想看。我们可以有一个指向常量值的常量指针。但我们也可以有一个指向常量值的变量指针。反之亦然。

到目前为止，`pointer`对象总是常量，但这对我们意味着什么？`pointer`对象是常量的后果是什么？后果是我们不能改变指针对象，因为它是常量。我们可以以多种方式使用指针对象，但我们不能改变这个指针对象内的内存地址。

然而，如果我们将`pointer`对象标记为变量对象，那么，我们可以改变这个`pointer`对象指向的内存地址。下面的例子演示了这一点。注意`pointer`对象指向的对象从`c1`变为`c2`。

```zig
const c1: u8 = 5;
const c2: u8 = 6;
var pointer = &c1;
try stdout.print("{d}\n", .{pointer.*});
pointer = &c2;
try stdout.print("{d}\n", .{pointer.*});
try stdout.flush();
```

```
5
6
```

因此，通过将`pointer`对象设置为`var`或`const`对象，你可以指定这个指针对象中包含的内存地址是否可以在你的程序中改变。另一方面，只有当指针指向的值存储在变量对象中时，你才能改变指针指向的值。如果这个值在常量对象中，那么，你不能通过指针改变这个值。

## 指针类型

在Zig中，有两种类型的指针（[Zig Software Foundation 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-zigdocs)），它们是：

* 单项指针（`*`）；
* 多项指针（`[*]`）；

单项指针对象是数据类型格式为`*T`的对象。例如，如果一个对象的数据类型为`*u32`，这意味着这个对象包含一个指向无符号32位整数值的单项指针。作为另一个例子，如果一个对象的类型为`*User`，那么，它包含一个指向`User`值的单项指针。

相反，多项指针是数据类型格式为`[*]T`的对象。注意星号（`*`）现在在一对括号（`[]`）内。如果星号在一对括号内，你就知道这个对象是多项指针。

当你对对象应用`&`运算符时，你总是会得到一个单项指针。多项指针更像是语言的"内部类型"，与切片更密切相关。因此，当你故意用`&`运算符创建指针时，你总是得到单项指针作为结果。

## 指针算术

指针算术在Zig中可用，它们的工作方式与在C中的工作方式相同。当你有一个指向数组的指针时，指针通常指向数组中的第一个元素，你可以使用指针算术来推进这个指针并访问数组中的其他元素。

注意在下面的例子中，最初，`ptr`对象指向数组`ar`中的第一个元素。但后来，我开始通过使用简单的指针算术推进指针来遍历数组。

```zig
const ar = [_]i32{ 1, 2, 3, 4 };
var ptr: [*]const i32 = &ar;
try stdout.print("{d}\n", .{ptr[0]});
ptr += 1;
try stdout.print("{d}\n", .{ptr[0]});
ptr += 1;
try stdout.print("{d}\n", .{ptr[0]});
try stdout.flush();
```

```
1
2
3
```

虽然你可以像这样创建指向数组的指针，并开始使用指针算术遍历这个数组，但在Zig中，我们更喜欢使用切片，这在[第1.6节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-arrays)中介绍过。

在底层，切片已经是指针了，它们还带有`len`属性，该属性指示切片中有多少元素。这很好，因为`zig`编译器可以使用它来检查潜在的缓冲区溢出和其他类似的问题。

此外，你不需要使用指针算术来遍历切片的元素。你可以简单地使用`slice[index]`语法来直接访问切片中你想要的任何元素。正如我在[第1.6节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-arrays)中提到的，你可以通过在括号内使用范围选择器从数组获取切片。在下面的例子中，我创建了一个覆盖整个`ar`数组的切片（`sl`）。我可以从这个切片访问`ar`的任何元素，而且，切片本身在底层已经是一个指针了。

```zig
const ar = [_]i32{1,2,3,4};
const sl = ar[0..ar.len];
_ = sl;
```

## 可选值和可选指针

让我们谈谈可选值以及它们如何与Zig中的指针相关。默认情况下，Zig中的对象是**非空的**。这意味着，在Zig中，你可以安全地假设源代码中的任何对象都不是null。

与C中的开发体验相比，这是Zig的一个强大功能。因为在C中，任何对象在任何时候都可以是null，因此，C中的指针可能指向null值。这是C中未定义行为的常见来源。当程序员在C中使用指针时，他们必须不断检查他们的指针是否指向null值。

相反，在Zig中工作时，如果由于某种原因，你的Zig代码在某处产生了null值，并且这个null值最终出现在非空对象中，你的Zig程序总是会引发运行时错误。以下面的程序为例。`zig`编译器可以在编译时看到`null`值，因此，它会引发编译时错误。但是，如果在运行时产生`null`值，Zig程序也会引发运行时错误，显示"attempt to use null value"消息。

```zig
var number: u8 = 5;
number = null;
```

```
p5.zig:5:14: error: expected type 'u8',
        found '@TypeOf(null)'
    number = null;
             ^~~~
```

你在C中得不到这种类型的安全性。在C中，你不会收到关于程序中产生null值的警告或错误。如果由于某种原因，你的代码在C中产生了null值，大多数时候，你最终会得到分段错误作为结果，这可能意味着很多事情。这就是为什么程序员必须在C中不断检查null值。

Zig中的指针也默认是**非空的**。这是Zig的另一个惊人功能。因此，你可以安全地假设你在Zig代码中创建的任何指针都指向非空值。因此，你没有检查你在Zig中创建的指针是否指向null值的繁重工作。

### 什么是可选值？

好的，我们现在知道Zig中的所有对象默认都是非空的。但是如果我们实际上需要使用一个可能接收null值的对象呢？这就是可选值的用武之地。

Zig中的可选对象与[C++中的`std::optional`对象](https://en.cppreference.com/w/cpp/utility/optional.html)相当相似。它是一个可以包含值或根本没有任何内容（也就是说，对象可以是null）的对象。要在我们的Zig代码中将对象标记为"可选"，我们使用`?`运算符。当你在对象的数据类型之前放置这个`?`运算符时，你将这个数据类型转换为可选数据类型，对象变成可选对象。

以下面的代码片段为例。我们正在创建一个名为`num`的新变量对象。这个对象的数据类型为`?i32`，这意味着这个对象包含有符号的32位整数（`i32`）或null值。两种选择都是`num`对象的有效值。这就是为什么我实际上可以将这个对象的值更改为null，并且`zig`编译器不会引发任何错误，如下所示：

```zig
var num: ?i32 = 5;
num = null;
```

### 可选指针

你也可以将指针对象标记为可选指针，这意味着这个对象包含null值或指向值的指针。当你将指针标记为可选时，这个指针对象的数据类型变为`?*const T`或`?*T`，具体取决于指针指向的值是否为常量值。`?`将对象标识为可选，而`*`将其标识为指针对象。

在下面的例子中，我们创建了一个名为`num`的变量对象和一个名为`ptr`的可选指针对象。注意对象`ptr`的数据类型表明它要么是null值，要么是指向`i32`值的指针。另外，注意即使对象`num`不是可选的，指针对象（`ptr`）也可以标记为可选。

这段代码告诉我们的是，`num`变量永远不会包含null值。这个变量将始终包含有效的`i32`值。但相反，`ptr`对象可能包含null值或指向`i32`值的指针。

```zig
var num: i32 = 5;
var ptr: ?*i32 = &num;
ptr = null;
num = 6;
```

但是如果我们反过来，将`num`对象标记为可选，而不是指针对象，会发生什么。如果我们这样做，那么，指针对象就不再是可选的了。这将是一个相似（尽管不同）的结果。因为那样，我们将有一个指向可选值的指针。换句话说，一个指向要么是null值要么是非null值的值的指针。

在下面的例子中，我们正在重新创建这个想法。现在，`ptr`对象的数据类型为`*?i32`，而不是`?*i32`。注意这次`*`符号在`?`之前。所以现在，我们有一个指向要么是null要么是有符号32位整数的值的指针。

```zig
var num: ?i32 = 5;
// ptr的类型是`*?i32`，而不是`?*i32`。
const ptr = &num;
_ = ptr;
```

### 可选值中的null处理

当你的Zig代码中有可选对象时，你必须明确处理这个对象为null的可能性。这就像使用`try`和`catch`进行错误处理。在Zig中，你也必须像处理一种错误类型一样处理null值。

我们可以通过使用以下任一方法来做到这一点：

* if语句，就像你在C中做的那样。
* `orelse`关键字。
* 使用`?`方法解包可选值。

当你使用if语句时，你使用一对管道来解包可选值，并在if块内使用这个"解包的对象"。以下面的例子为参考，如果对象`num`是null，那么，if语句内的代码不会执行。否则，if语句将把对象`num`解包到`not_null_num`对象中。这个`not_null_num`对象在if语句的作用域内保证不为null。

```zig
const num: ?i32 = 5;
if (num) |not_null_num| {
    try stdout.print("{d}\n", .{not_null_num});
    try stdout.flush();
}
```

`5`

现在，`orelse`关键字的行为类似于二元运算符。你用这个关键字连接两个表达式。在`orelse`的左侧，你提供可能导致null值的表达式，在`orelse`的右侧，你提供另一个不会导致null值的表达式。

`orelse`关键字背后的想法是：如果左侧的表达式导致非null值，那么，使用这个非null值。但是，如果左侧的这个表达式导致null值，那么，使用右侧表达式的值。

看看下面的例子，由于`x`对象当前为null，`orelse`决定使用替代值，即数字15。

```zig
const x: ?i32 = null;
const dbl = (x orelse 15) * 2;
try stdout.print("{d}\n", .{dbl});
try stdout.flush();
```

`30`

当你想解决（或处理）这个null值时，你可以使用if语句或`orelse`关键字。但是，如果这个null值没有明确的解决方案，并且最合逻辑和理智的路径是在遇到这个null值时简单地panic并在程序中引发响亮的错误，你可以使用可选对象的`?`方法。

本质上，当你使用这个`?`方法时，可选对象被解包。如果在可选对象中找到非null值，那么，使用这个非null值。否则，使用`unreachable`关键字。你可以在[官方文档中阅读更多关于这个`unreacheable`关键字的内容](https://ziglang.org/documentation/master/#unreachable)。但本质上，当你使用构建模式`ReleaseSafe`或`Debug`构建Zig源代码时，这个`unreacheable`关键字会导致程序在运行时panic并引发错误，如下面的例子所示：

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
fn return_null(n: i32) ?i32 {
    if (n == 5) return null;
    return n;
}

pub fn main() !void {
    const x: i32 = 5;
    const y: ?i32 = return_null(x);
    try stdout.print("{d}\n", .{y.?});
    try stdout.flush();
}
```

```
thread 12767 panic: attempt to use null value
p7.zig:12:34: 0x103419d in main (p7):
    try stdout.print("{d}\n", .{y.?});
                                 ^
```

---

脚注翻译：

1. [https://ziglang.org/documentation/master/#unreachable](https://ziglang.org/documentation/master/#unreachable)
