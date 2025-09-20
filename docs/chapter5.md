# 第5章 调试Zig应用程序 - Zig语言入门

能够调试应用程序对于任何想要在任何语言中进行严肃编程的程序员来说都是必不可少的。这就是为什么在本章中，我们将讨论调试用Zig编写的应用程序的可用策略和工具。

## 打印调试

我们从经典且经过实战检验的_打印调试_策略开始。调试为你提供的关键优势是_可见性_。通过_打印语句_，你可以轻松查看应用程序正在产生的结果和对象。

这就是_打印调试_的本质 - 使用打印表达式来查看程序生成的值，因此，可以更好地理解程序的行为方式。

许多程序员经常使用Zig中的打印函数，如`stdout.print()`或`std.debug.print()`，来更好地理解他们的程序。这是一种已知且古老的策略，非常简单有效，在编程社区中更广为人知的名称是_打印调试_。在Zig中，你可以将信息打印到系统的`stdout`或`stderr`流。

让我们从`stdout`开始。首先，你需要通过调用Zig标准库中的`getStdOut()`方法来访问`stdout`。这个方法返回一个_文件描述符_对象，通过这个对象你可以读取/写入`stdout`。我建议你通过[查看Zig标准库官方参考中`File`类型的页面](https://ziglang.org/documentation/master/std/#std.fs.File)来查看这个对象中可用的所有方法。

对于我们这里的目的，即向`stdout`写入内容，特别是调试我们的程序，我建议你使用`writer()`方法，它会给你一个_writer_对象。这个_writer_对象提供了一些辅助方法来将内容写入代表`stdout`流的文件描述符对象。特别是`print()`方法。

这个_writer_对象的`print()`方法是一个"打印格式化器"类型的函数。换句话说，这个方法的工作方式与C中的`printf()`函数完全相同，或者像Rust中的`println!()`。在函数的第一个参数中，你指定一个模板字符串，在第二个参数中，你提供要插入到模板消息中的值（或对象）列表。

理想情况下，第一个参数中的模板字符串应该包含一些格式说明符。每个格式说明符都与你在第二个参数中列出的值（或对象）匹配。因此，如果你在第二个参数中提供了5个不同的对象，那么，模板字符串应该包含5个格式说明符，每个提供的对象一个。

每个格式说明符由单个字母表示，你在一对花括号内提供这个格式说明符。因此，如果你想使用字符串说明符（`s`）格式化你的对象，那么，你可以在模板字符串中插入文本`{s}`。以下是最常用格式说明符的快速列表：

* `d`：用于打印整数和浮点数。
* `c`：用于打印字符。
* `s`：用于打印字符串。
* `p`：用于打印内存地址。
* `x`：用于打印十六进制值。
* `any`：使用任何兼容的格式说明符（即，它会自动为你选择格式说明符）。

下面的代码示例给出了使用`d`格式说明符的`print()`方法的使用示例。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
fn add(x: u8, y: u8) u8 {
    return x + y;
}

pub fn main() !void {
    const result = add(34, 16);
    try stdout.print("Result: {d}", .{result});
    try stdout.flush();
}
```

`Result: 50`

重要的是要强调，正如你所期望的，`stdout.print()`方法将你的模板字符串打印到系统的`stdout`流中。然而，如果你愿意，你也可以将模板字符串打印到`stderr`流中。你需要做的就是用函数`std.debug.print()`替换`stdout.print()`调用。像这样：

```zig
const std = @import("std");
fn add(x: u8, y: u8) u8 {
    return x + y;
}

pub fn main() !void {
    const result = add(34, 16);
    std.debug.print("Result: {d}\n", .{result});
}
```

`Result: 50`

你也可以通过获取`stderr`的文件描述符对象，然后创建`stderr`的_writer_对象，然后使用这个_writer_对象的`print()`方法来实现完全相同的结果，如下面的例子：

```zig
const std = @import("std");
const stderr = std.io.getStdErr().writer();
// 更多行...
try stderr.print("Result: {d}", .{result});
```

## 通过调试器调试

尽管_打印调试_是一种有效且非常有用的策略，但大多数程序员更喜欢使用调试器来调试他们的程序。由于Zig是一种低级语言，你可以使用GDB（GNU调试器）或LLDB（LLVM项目调试器）作为你的调试器。

两个调试器都可以与Zig代码一起工作，这里是个人喜好问题。你选择你喜欢的调试器，然后使用它。在本书中，我将在示例中使用LLDB作为我的调试器。

### 在调试模式下编译源代码

为了通过调试器调试你的程序，你必须在`Debug`模式下编译你的源代码。因为当你在其他模式（如`Release`）下编译源代码时，编译器通常会剥离调试器用于读取和跟踪程序的一些基本信息，如PDB（_程序数据库_）文件。

通过在`Debug`模式下编译源代码，你确保调试器将在你的程序中找到调试所需的信息。默认情况下，编译器在编译代码时使用`Debug`模式。考虑到这一点，当你使用`build-exe`命令（在[第1.2.4节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-compile-code)中描述）编译程序时，如果你不通过`-O`命令行参数明确指定模式，那么，编译器将在`Debug`模式下编译你的代码。

### 让我们调试一个程序

作为例子，让我们使用LLDB来导航和调查以下Zig代码片段：

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

fn add_and_increment(a: u8, b: u8) u8 {
    const sum = a + b;
    const incremented = sum + 1;
    return incremented;
}

pub fn main() !void {
    var n = add_and_increment(2, 3);
    n = add_and_increment(n, n);
    try stdout.print("Result: {d}!\n", .{n});
    try stdout.flush();
}
```

`Result: 13!`

这个程序没有任何问题。但这是我们的一个好的开始。首先，我们需要使用`zig build-exe`命令编译这个程序。对于这个例子，假设我已经将上面的Zig代码编译成一个名为`add_program`的二进制可执行文件。

`zig build-exe add_program.zig`

现在，我们可以像这样启动LLDB与`add_program`：

`lldb add_program`

从现在开始，LLDB已启动，你可以通过查看前缀`(lldb)`来知道我正在执行LLDB命令。如果某些内容以`(lldb)`为前缀，那么你知道它是一个LLDB命令。

我要做的第一件事是通过执行`b main`在`main()`函数处设置断点。之后，我只需使用`run`启动程序的执行。你可以在下面的输出中看到，执行在函数`main()`的第一行停止，正如我们预期的那样。

```
(lldb) b main
Breakpoint 1: where = debugging`debug1.main + 22
    at debug1.zig:11:30, address = 0x00000000010341a6
(lldb) run
Process 8654 launched: 'add_program' (x86_64)
Process 8654 stopped
* thread #1, name = 'add_program',
    stop reason = breakpoint 1.1 frame #0: 0x10341a6
    add_program`debug1.main at add_program.zig:11:30
   8    }
   9
   10   pub fn main() !void {
-> 11       var n = add_and_increment(2, 3);
   12       n = add_and_increment(n, n);
   13       try stdout.print("Result: {d}!\n", .{n});
   14   }
```

我可以开始浏览代码，并检查正在生成的对象。如果你不熟悉LLDB中可用的命令，我建议你阅读项目的官方文档。你也可以查找速查表，它们快速描述了所有可用的命令。

目前，我们在`main()`函数的第一行。在这一行中，我们通过执行`add_and_increment()`函数创建`n`对象。要执行当前代码行并转到下一行，我们可以运行LLDB命令`n`。让我们执行这个命令。

执行这一行后，我们还可以通过使用LLDB命令`p`查看存储在这个`n`对象内的值。这个命令的语法是`p <对象名称>`。

如果我们查看存储在`n`对象中的值（`p n`），注意它存储了十六进制值`0x06`，这是十进制的数字6。我们还可以看到这个值的类型是`unsigned char`，这是一个无符号8位整数。我们已经在[第1.8节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-zig-strings)中讨论过，Zig中的`u8`整数等同于C数据类型`unsigned char`。

```
(lldb) n
Process 4798 stopped
* thread #1, name = 'debugging',
    stop reason = step over frame #0: 0x10341ae
    debugging`debug1.main at debug1.zig:12:26
   9
   10   pub fn main() !void {
   11       var n = add_and_increment(2, 3);
-> 12       n = add_and_increment(n, n);
   13       try stdout.print("Result: {d}!\n", .{n});
   14   }
(lldb) p n
(unsigned char) $1 = '\x06'
```

现在，在下一行代码中，我们再次执行`add_and_increment()`函数。为什么不进入这个函数内部呢？我们来试试？我们可以通过执行LLDB命令`s`来做到这一点。注意在下面的例子中，执行这个命令后，我们已经进入了`add_and_increment()`函数的上下文。

还要注意在下面的例子中，我在函数体中又走了两行，然后执行`frame variable` LLDB命令，一次查看在当前作用域内创建的每个变量中存储的值。

你可以在下面的输出中看到，对象`sum`存储值`\f`，它代表_换页_字符。这个字符在ASCII表中对应于十六进制值`0x0C`，或者十进制数字12。因此，这意味着在第5行执行的表达式`a + b`的结果是数字12。

```
(lldb) s
Process 4798 stopped
* thread #1, name = 'debugging',
    stop reason = step in frame #0: 0x10342de
    debugging`debug1.add_and_increment(a='\x02', b='\x03')
    at debug1.zig:4:39
-> 4    fn add_and_increment(a: u8, b: u8) u8 {
   5        const sum = a + b;
   6        const incremented = sum + 1;
   7        return incremented;
(lldb) n
(lldb) n
(lldb) frame variable
(unsigned char) a = '\x06'
(unsigned char) b = '\x06'
(unsigned char) sum = '\f'
(unsigned char) incremented = '\x06'
```

## 如何调查对象的数据类型

由于Zig是一种强类型语言，与对象关联的数据类型对你的程序非常重要。因此，调试与对象关联的数据类型可能对理解程序中的错误和bug很重要。

当你用调试器遍历程序时，你可以通过使用LLDB `p`命令简单地将它们打印到控制台来检查对象的类型。但你也有嵌入在语言本身中的替代方法来访问对象的数据类型。

在Zig中，你可以通过使用内置函数`@TypeOf()`来检索对象的数据类型。只需将这个函数应用于对象，你就可以访问对象的数据类型。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
const expect = std.testing.expect;

pub fn main() !void {
    const number: i32 = 5;
    try expect(@TypeOf(number) == i32);
    try stdout.print("{any}\n", .{@TypeOf(number)});
    try stdout.flush();
}
```

`i32`

这个函数类似于Python中的`type()`内置函数，或者Javascript中的`typeof`操作符。

---

脚注翻译：

1. [https://ziglang.org/documentation/master/std/#std.fs.File](https://ziglang.org/documentation/master/std/#std.fs.File)
2. 参见[https://ziglang.org/documentation/master/#Debug](https://ziglang.org/documentation/master/#Debug)
3. [https://lldb.llvm.org/](https://lldb.llvm.org/)
4. [https://gist.github.com/ryanchang/a2f738f0c3cc6fbd71fa](https://gist.github.com/ryanchang/a2f738f0c3cc6fbd71fa)
