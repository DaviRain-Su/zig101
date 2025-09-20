# 第14章 Zig与C的互操作性 - Zig入门介绍

在本章中，我们将讨论Zig与C的互操作性。我们已经在[第9.11节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-building-c-code)中讨论了如何使用`zig`编译器来构建C代码。但我们还没有讨论如何在Zig中实际使用C代码。换句话说，我们还没有讨论如何从Zig调用和使用C代码。

这是本章的主要主题。此外，在本书的下一个小项目中，我们将使用一个C库。因此，我们将在下一个项目中实践这里讨论的很多知识。

## 如何从Zig调用C代码

与C的互操作性并不是什么新鲜事。大多数高级编程语言都有FFI（外部函数接口），可以用来调用C代码。例如，Python有Cython，R有`.Call()`，Javascript有`ccall()`等。但Zig在更深层次上与C集成，这不仅影响C代码的调用方式，还影响这个C代码如何被编译并合并到你的Zig项目中。

总的来说，Zig与C有很好的互操作性。如果你想从Zig调用任何C代码，你必须执行以下步骤：

* 将C头文件导入到你的Zig代码中。
* 将你的Zig代码与C库链接。

### 导入C头文件的策略

在Zig中使用C代码总是涉及执行上述两个步骤。然而，当我们具体谈论上面列出的第一步时，目前有两种不同的方式来执行这第一步，它们是：

* 通过`zig translate-c`命令将C头文件翻译成Zig代码，然后导入并使用翻译后的Zig代码。
* 通过`@cImport()`内置函数直接将C头文件导入到你的Zig模块中。

如果你不熟悉`translate-c`，这是`zig`编译器内的一个子命令，它接受C文件作为输入，并输出这些C文件中存在的C代码的Zig表示。换句话说，这个子命令就像一个转译器。它接受C代码，并将其翻译成等效的Zig代码。

我认为将`translate-c`解释为一个生成C代码的Zig绑定的工具是可以的，类似于`rust-bindgen`工具，它生成C代码的Rust FFI绑定。但这不是对`translate-c`的精确解释。这个工具背后的想法是真正将C代码翻译成Zig代码。

现在，从表面上看，`@cImport()`与`translate-c`可能看起来像两种完全不同的策略。但实际上，它们实际上是完全相同的策略。因为在底层，`@cImport()`内置函数只是`translate-c`的快捷方式。两个工具都使用相同的"C到Zig"翻译功能。所以当你使用`@cImport()`时，你本质上是要求`zig`编译器将C头文件翻译成Zig代码，然后将这个Zig代码导入到你当前的Zig模块中。

目前，Zig项目中有一个被接受的提案，将`@cImport()`移动到Zig构建系统。如果这个提案完成，那么"使用`@cImport()`"策略将转变为"在你的Zig构建脚本中调用翻译C函数"。因此，将C代码翻译成Zig代码的步骤将被移动到你的Zig项目的构建脚本中，你只需要将翻译后的Zig代码导入到你的Zig模块中就可以开始从Zig调用C代码。

如果你思考一下这个提案，你会理解这实际上是一个小改变。我的意思是，逻辑是相同的，步骤本质上仍然是相同的。唯一的区别是其中一个步骤将被移动到你的Zig项目的构建脚本中。

### 将Zig代码与C库链接

无论你选择前一节中的哪种策略，如果你想从Zig调用C代码，你必须将你的Zig代码与包含你想要调用的C代码的C库链接。

换句话说，每次你在Zig代码中使用一些C代码时，**你在构建过程中引入了一个依赖**。这对任何有C和C++经验的人来说都不应该感到惊讶。因为在C中也没有什么不同。每次你在C代码中使用C库时，你也必须构建你的C代码并将其与你正在使用的这个C库链接。

当我们在Zig代码中使用C库时，`zig`编译器需要访问在你的Zig代码中被调用的C函数的定义。这个库的C头文件提供了这些C函数的声明，但不是它们的定义。因此，为了访问这些定义，`zig`编译器需要在构建过程中构建你的Zig代码并将其与C库链接。

正如我们在[第9章](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html)中讨论的，有不同的策略来将某些东西与库链接。这可能涉及首先构建C库，然后将其与Zig代码链接。或者，如果这个C库已经在你的系统中构建和安装，它也可能只涉及链接步骤。无论如何，如果你对此有疑问，请回到[第9章](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html)。

## 关于将Zig值传递给C函数

Zig对象与其C等价物之间有一些内在差异。可能最明显的是C字符串和Zig字符串之间的差异，我在[第1.8节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-zig-strings)中描述过。Zig字符串是包含任意字节数组和长度值的对象。另一方面，C字符串通常只是指向以空字符结尾的任意字节数组的指针。

由于这些内在差异，在某些特定情况下，你不能在将Zig对象转换为C兼容值之前直接将它们作为输入传递给C函数。然而，在其他一些情况下，你可以直接将Zig对象和Zig字面值作为输入传递给C函数，一切都会正常工作，因为`zig`编译器会为你处理一切。

所以我们这里描述了两种不同的场景。让我们称它们为"自动转换"和"需要转换"。"自动转换"场景是当`zig`编译器为你处理一切，并自动将你的Zig对象/值转换为C兼容值时。相反，"需要转换"场景是当你，程序员，有责任在将Zig对象传递给C代码之前将其转换为C兼容值时。

还有第三种场景在这里没有被描述，即当你在Zig代码中创建一个C对象，或C结构体，或C兼容值，并将这个C对象/值作为输入传递给Zig代码中的C函数。这种场景将在稍后的[第14.4节](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#sec-c-inputs)中描述。在本节中，我们专注于将Zig对象/值传递给C代码的场景，而不是将C对象/值传递给C代码。

### "自动转换"场景

"自动转换"场景是当`zig`编译器自动为我们将Zig对象转换为C兼容值时。这种特定场景主要发生在两种情况下：

* 字符串字面值；
* 在[第1.5节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-primitive-data-types)中介绍的任何原始数据类型。

当我们考虑上面描述的第二种情况时，`zig`编译器确实会自动将任何原始数据类型转换为其C等价物，因为编译器知道如何正确地将`i16`转换为`signed short`，或将`u8`转换为`unsigned char`等。现在，当我们考虑字符串字面值时，它们也可以自动转换为C字符串，特别是因为`zig`编译器一开始不会强制将特定的Zig数据类型强加给字符串字面值，除非你将这个字符串字面值存储到Zig对象中，并显式注解这个对象的数据类型。

因此，对于字符串字面值，`zig`编译器有更多的自由来推断每种情况下使用的适当数据类型。你可以说字符串字面值"继承其数据类型"取决于它使用的上下文。大多数时候，这个数据类型将是我们通常与Zig字符串关联的类型（`[]const u8`）。但根据情况，它可能是不同的类型。当`zig`编译器检测到你正在将字符串字面值作为输入提供给某个C函数时，编译器会自动将这个字符串字面值解释为C字符串值。

作为例子，看看下面暴露的代码。这里我们使用`fopen()` C函数来简单地打开和关闭一个文件。如果你不知道这个`fopen()`函数在C中是如何工作的，它接受两个C字符串作为输入。但在下面的代码示例中，我们直接将在Zig代码中编写的一些字符串字面值作为输入传递给这个`fopen()` C函数。

换句话说，我们没有进行从Zig字符串到C字符串的任何转换。我们只是直接将Zig字符串字面值作为输入传递给C函数。它工作得很好！因为编译器在当前上下文中将字符串`"foo.txt"`解释为C字符串。

```zig
const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
});

pub fn main() !void {
    const file = c.fopen("foo.txt", "rb");
    if (file == null) {
        @panic("Could not open file!");
    }
    if (c.fclose(file) != 0) {
        return error.CouldNotCloseFileDescriptor;
    }
}
```

让我们做一些实验，以不同的方式编写相同的代码，看看这如何影响程序。作为起点，让我们将`"foo.txt"`字符串存储在Zig对象中，如下面的`path`对象，然后，我们将这个Zig对象作为输入传递给`fopen()` C函数。

如果我们这样做，程序仍然成功编译和运行。注意我在下面的例子中省略了大部分代码。这只是为了简洁起见，因为程序的其余部分仍然相同。这个例子和前一个例子之间的唯一区别就是下面暴露的这两行。

```zig
const path = "foo.txt";
    const file = c.fopen(path, "rb");
    // 程序的其余部分
```

现在，如果你给`path`对象一个显式数据类型会发生什么？好吧，如果我通过用数据类型`[]const u8`注解`path`对象来强制`zig`编译器将这个`path`对象解释为Zig字符串对象，那么，我实际上会得到如下所示的编译错误。我们得到这个编译错误是因为现在我强制`zig`编译器将`path`解释为Zig字符串对象。

根据错误消息，`fopen()` C函数期望接收类型为`[*c]const u8`（C字符串）的输入值，而不是类型为`[]const u8`（Zig字符串）的值。更详细地说，类型`[*c]const u8`实际上是C字符串的Zig类型表示。这个类型的`[*c]`部分标识了一个C指针。所以，这个Zig类型本质上意味着：指向常量字节数组（`const u8`）的C指针（`[*c]`）。

```zig
const path: []const u8 = "foo.txt";
    const file = c.fopen(path, "rb");
    // 程序的其余部分
```

```
t.zig:2:7 error: expected type '[*c]const u8', found '[]const u8':
    const file = c.fopen(path, "rb");
                         ^~~~
```

因此，当我们专门谈论字符串字面值时，只要你不给这些字符串字面值一个显式数据类型，`zig`编译器应该能够根据需要自动将它们转换为C字符串。

但是使用在[第1.5节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-primitive-data-types)中介绍的原始数据类型之一呢？让我们以下面暴露的代码为例。在这里，我们将一些浮点字面值作为输入提供给C函数`powf()`。注意这个代码示例成功编译和运行。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const cmath = @cImport({
    @cInclude("math.h");
});

pub fn main() !void {
    const y = cmath.powf(15.68, 2.32);
    try stdout.print("{d}\n", .{y});
    try stdout.flush();
}
```

```
593.2023
```

再一次，因为`zig`编译器一开始不会将特定数据类型与字面值`15.68`和`2.32`关联，编译器可以在将这些值传递给`powf()` C函数之前，自动将它们转换为其C `float`（或`double`）等价物。现在，即使我通过将它们存储到Zig对象中并显式注解这些对象的类型来给这些字面值一个显式的Zig数据类型，代码仍然成功编译和运行。

```zig
const x: f32 = 15.68;
    const y = cmath.powf(x, 2.32);
    // 程序的其余部分
```

```
593.2023
```

### "需要转换"场景

"需要转换"场景是当我们需要在将Zig对象作为输入传递给C函数之前手动将其转换为C兼容值时。当将Zig字符串对象传递给C函数时，你会遇到这种场景。

我们已经在最后一个`fopen()`示例中看到了这种特定情况，该示例在下面重现。你可以在这个例子中看到，我们给了`path`对象一个显式的Zig数据类型（`[]const u8`），因此，我们强制`zig`编译器将这个`path`对象视为Zig字符串对象。因此，我们现在需要在将其传递给`fopen()`之前手动将这个`path`对象转换为C字符串。

```zig
const path: []const u8 = "foo.txt";
    const file = c.fopen(path, "rb");
    // 程序的其余部分
```

```
t.zig:10:26: error: expected type '[*c]const u8', found '[]const u8'
    const file = c.fopen(path, "rb");
                         ^~~~
```

有不同的方法将Zig字符串对象转换为C字符串。解决这个问题的一种方法是提供指向底层字节数组的指针，而不是直接将Zig对象作为输入提供。你可以通过使用Zig字符串对象的`ptr`属性来访问这个指针。

下面的代码示例演示了这种策略。注意，通过通过`ptr`属性给出`path`中底层数组的指针，我们在使用`fopen()` C函数时没有得到编译错误。

```zig
const path: []const u8 = "foo.txt";
    const file = c.fopen(path.ptr, "rb");
    // 程序的其余部分
```

这种策略有效是因为在`ptr`属性中找到的这个指向底层数组的指针，在语义上与指向字节数组的C指针相同，即类型为`*unsigned char`的C对象。这就是为什么这个选项也解决了将Zig字符串转换为C字符串的问题。

另一个选项是通过使用内置函数`@ptrCast()`显式地将Zig字符串对象转换为C指针。使用这个函数，我们可以将类型为`[]const u8`的对象转换为类型为`[*c]const u8`的对象。正如我在前一节中描述的，类型的`[*c]`部分意味着它是一个C指针。这种策略不推荐。但它对演示`@ptrCast()`的使用很有用。

你可能从[第2.5节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-type-cast)回忆起`@as()`和`@ptrCast()`。作为回顾，`@as()`内置函数用于显式地将Zig值从类型"x"转换（或强制转换）为类型"y"的值。但在我们这里的情况下，我们正在转换一个指针对象。每当指针涉及Zig中的某些"类型转换操作"时，就会涉及`@ptrCast()`函数。

在下面的例子中，我们使用这个函数将我们的`path`对象转换为指向字节数组的C指针。然后，我们将这个C指针作为输入传递给`fopen()`函数。注意这个代码示例成功编译，没有错误。

```zig
const path: []const u8 = "foo.txt";
    const c_path: [*c]const u8 = @ptrCast(path);
    const file = c.fopen(c_path, "rb");
    // 程序的其余部分
```

## 在Zig中创建C对象

在你的Zig代码中创建C对象，或者换句话说，创建C结构体的实例实际上是相当容易做到的。你首先需要导入定义你试图在Zig代码中实例化的C结构体的C头文件（就像我在[第14.2节](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#sec-import-c-header)中描述的那样）。之后，你可以在Zig代码中创建一个新对象，并用C结构体的数据类型注解它。

例如，假设我们有一个名为`user.h`的C头文件，这个头文件声明了一个名为`User`的新结构体。这个C头文件如下所示：

```c
#include <stdint.h>

typedef struct {
    uint64_t id;
    char* name;
} User;
```

这个`User` C结构体有两个不同的字段，或两个结构体成员，名为`id`和`name`。字段`id`是一个无符号64位整数值，而字段`name`只是一个标准C字符串。现在，假设我想在我的Zig代码中创建这个`User`结构体的实例。我可以通过将这个`user.h`头文件导入到我的Zig代码中，并创建一个类型为`User`的新对象来做到这一点。这些步骤在下面的代码示例中重现。

注意我在这个例子中使用了关键字`undefined`。这允许我创建`new_user`对象，而无需为对象提供初始值。因此，与这个`new_user`对象相关联的底层内存是未初始化的，即内存当前填充了"垃圾"值。因此，这个表达式具有与C中表达式`User new_user;`完全相同的效果，意思是"声明一个名为`new_user`的类型为`User`的新对象"。

我们有责任通过为C结构体的成员（或字段）分配有效值来正确初始化与这个`new_user`对象相关联的内存。在下面的例子中，我将整数1分配给成员`id`。我还将字符串`"pedropark99"`保存到成员`name`中。注意在这个例子中，我手动将空字符（零字节）添加到为这个字符串分配的数组的末尾。这个空字符在C中标记数组的结尾。

```zig
const std = @import("std");
const c = @cImport({
    @cInclude("user.h");
});

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var new_user: c.User = undefined;
    new_user.id = 1;
    var user_name = try allocator.alloc(u8, 12);
    defer allocator.free(user_name);
    @memcpy(user_name[0..(user_name.len - 1)], "pedropark99");
    user_name[user_name.len - 1] = 0;
    new_user.name = user_name.ptr;
}
```

所以，在上面的例子中，我们手动初始化C结构体的每个字段。我们可以说，在这个实例中，我们正在"手动实例化C结构体对象"。然而，当我们在Zig代码中使用C库时，我们很少需要像这样手动实例化C结构体。只是因为C库通常在其公共API中提供"构造函数"。因此，我们通常依赖这些构造函数来为我们正确初始化C结构体和结构体字段。

例如，考虑Harfbuzz C库。这是一个文本整形C库，它围绕一个"缓冲区对象"工作，或者更具体地说，是C结构体`hb_buffer_t`的实例。因此，如果我们想使用这个C库，我们需要创建这个C结构体的实例。幸运的是，这个库提供了函数`hb_buffer_create()`，我们可以使用它来创建这样的对象。所以创建这样的对象所需的Zig代码可能看起来像这样：

```zig
const c = @cImport({
    @cInclude("hb.h");
});
var buf: c.hb_buffer_t = c.hb_buffer_create();
// 使用"缓冲区对象"做一些事情
```

因此，我们不需要在这里手动创建C结构体`hb_buffer_t`的实例，并手动为这个C结构体中的每个字段分配有效值。因为构造函数`hb_buffer_create()`正在为我们做这项繁重的工作。

由于这个`buf`对象，以及前面例子中的`new_user`对象，都是C结构体的实例，这些对象本身就是C兼容值。它们是在我们的Zig代码中定义的C对象。因此，你可以自由地将这些对象作为输入传递给任何期望接收这种类型的C结构体作为输入的C函数。你不需要使用任何特殊语法，或者以任何特殊方式转换它们以在C代码中使用它们。这就是我们如何在Zig代码中创建和使用C对象。

## 在Zig函数之间传递C结构体

现在我们已经学会了如何在Zig代码中创建/声明C对象，我们需要学习如何将这些C对象作为输入传递给Zig函数。正如我在[第14.4节](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#sec-c-inputs)中描述的，我们可以自由地将这些C对象作为输入传递给我们从Zig代码调用的C代码。但是将这些C对象传递给Zig函数呢？

本质上，这种特定情况需要在Zig函数声明中进行一个小调整。你需要做的就是确保你将C对象_按引用_传递给函数，而不是_按值_传递。要做到这一点，你必须将接收这个C对象的函数参数的数据类型注解为"指向C结构体的指针"，而不是将其注解为"C结构体的实例"。

让我们考虑我们在[第14.4节](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#sec-c-inputs)中使用的`user.h` C头文件中的C结构体`User`。现在，考虑我们想要创建一个Zig函数来设置这个C结构体中`id`字段的值，就像下面声明的`set_user_id()`函数。注意这个函数中的`user`参数被注解为指向`c.User`对象的指针（`*`）。

因此，当将C对象传递给Zig函数时，你需要做的就是在接收C对象的函数参数的数据类型中添加`*`。这将确保C对象_按引用_传递给函数。

因为我们已经将函数参数转换为指针，每次你因为任何原因（例如，你想读取、更新或删除这个值）必须访问函数体内这个输入指针指向的值时，你必须使用我们从[第6章](https://pedropark99.github.io/zig-book/Chapters/05-pointers.html)学到的`.*`语法来解引用指针。注意`set_user_id()`函数使用这个语法来改变输入指针指向的`User`结构体的`id`字段中的值。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const c = @cImport({
    @cInclude("user.h");
});
fn set_user_id(id: u64, user: *c.User) void {
    user.*.id = id;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var new_user: c.User = undefined;
    new_user.id = 1;
    var user_name = try allocator.alloc(u8, 12);
    defer allocator.free(user_name);
    @memcpy(user_name[0..(user_name.len - 1)], "pedropark99");
    user_name[user_name.len - 1] = 0;
    new_user.name = user_name.ptr;

    set_user_id(25, &new_user);
    try stdout.print("New ID: {any}\n", .{new_user.id});
    try stdout.flush();
}
```

```
New ID: 25
```

---

## 脚注

1.   [https://github.com/rust-lang/rust-bindgen](https://github.com/rust-lang/rust-bindgen)[↩︎](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#fnref1)

2.   [https://github.com/ziglang/zig/issues/20630](https://github.com/ziglang/zig/issues/20630)[↩︎](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#fnref2)

3.   [https://cplusplus.com/reference/cstdio/printf/](https://cplusplus.com/reference/cstdio/printf/)[↩︎](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#fnref3)

4.   [https://en.cppreference.com/w/c/numeric/math/pow](https://en.cppreference.com/w/c/numeric/math/pow)[↩︎](https://pedropark99.github.io/zig-book/Chapters/14-zig-c-interop.html#fnref4)
