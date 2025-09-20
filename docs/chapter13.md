# 第13章 文件系统和输入/输出（IO） - Zig入门介绍

在本章中，我们将讨论如何使用Zig标准库中可以执行文件系统操作的跨平台结构和函数。这些函数和结构大多来自`std.fs`模块。

我们还将讨论Zig中的输入/输出（也称为IO）操作。这些操作大多是通过使用`std.io`模块中的结构和函数来完成的，该模块定义了系统_标准通道_（`stdout`和`stdin`）的文件描述符，以及创建和使用I/O流的函数。

## 输入/输出基础

如果你有高级语言的经验，你肯定以前在该语言中使用过这些输入和输出功能。换句话说，你肯定遇到过需要向用户发送一些输出或从用户接收输入的情况。

例如，在Python中，我们可以通过使用`input()`内置函数接收来自用户的一些输入。但我们也可以通过使用`print()`内置函数打印（或"显示"）一些输出给用户。所以是的，如果你以前用Python编程过，你肯定至少使用过这些函数一次。

但你知道这些函数如何与你的操作系统（OS）相关联吗？它们究竟如何与你的OS资源交互以接收或发送一些输入/输出。本质上，高级语言中的这些输入/输出函数只是对操作系统的_标准输出_和_标准输入_通道的抽象。

这意味着我们通过操作系统接收输入或发送输出。是操作系统在用户和你的程序之间架起桥梁。你的程序没有直接访问用户的权限。是操作系统中介了你的程序和用户之间交换的每条消息。

你的OS的_标准输出_和_标准输入_通道通常被称为你的OS的`stdout`和`stdin`通道。在某些情况下，它们也被称为_标准输出设备_和_标准输入设备_。顾名思义，_标准输出_是输出流动的通道，而_标准输入_是输入流动的通道。

此外，操作系统通常还会创建一个专门用于交换错误消息的通道，称为_标准错误_通道，或`stderr`通道。这是通常发送错误和警告消息的通道。这些是通常在你的终端中以红色或橙色显示的消息。

通常，每个操作系统（例如Windows、macOS、Linux等）都会为运行在你计算机上的每个程序（或进程）创建一组专用且独立的_标准输出_、_标准错误_和_标准输入_通道。这意味着你编写的每个程序都有专用的`stdin`、`stderr`和`stdout`，它们与当前运行的其他程序和进程的`stdin`、`stderr`和`stdout`是分开的。

这是你的操作系统的行为。这不是来自你使用的编程语言。因为正如我之前所说，编程语言中的输入和输出，特别是在高级语言中，只是对当前操作系统的`stdin`、`stderr`和`stdout`的简单抽象。也就是说，无论你使用什么编程语言，你的操作系统都是程序中进行的每个输入/输出操作之间的中介。

### 写入器和读取器模式

在Zig中，输入/输出（IO）有一个模式。我（本书的作者）不知道这个模式是否有官方名称。但在这里，在本书中，我将其称为"写入器和读取器模式"。本质上，Zig中的每个IO操作都是通过`Reader`或`Writer`对象进行的。

这两种数据类型来自Zig标准库的`std.io`模块。正如它们的名字所示，`Reader`是一个提供从"某处"（或"某物"）读取数据的工具的对象，而`Writer`提供将数据写入这个"某处"的工具。这个"某处"可能是不同的东西：比如存在于你的文件系统中的文件；或者，可能是你系统中的网络套接字；或者，连续的数据流，比如来自你系统的标准输入设备，可能会不断接收来自用户的新数据，或者，作为另一个例子，游戏中的实时聊天，不断接收和显示来自游戏玩家的新消息。

所以，如果你想从某处或某物**读取**数据，这意味着你需要使用`Reader`对象。但如果你需要将数据**写入**这个"某处"，那么，你需要使用`Writer`对象。这两个对象通常都是从文件描述符对象创建的。更具体地说，通过这个文件描述符对象的`writer()`和`reader()`方法。如果你不熟悉这种类型的对象，请转到下一节。

每个`Writer`对象都有像`print()`这样的方法，它允许你将格式化字符串（即，这个格式化字符串类似于Python中的`f`字符串，或类似于C的`printf()`函数）写入/发送到你正在使用的"某处"（文件、套接字、流等）。它还有一个`writeAll()`方法，允许你将字符串或字节数组写入"某处"。

同样，每个`Reader`对象都有像`readSliceAll()`这样的方法，它允许你从"某处"（文件、套接字、流等）读取数据，直到它填满一个特定的数组（即"缓冲区"）对象。换句话说，如果你向`readSliceAll()`提供一个包含300个`u8`值的数组对象，那么，这个方法会尝试从"某处"读取300字节的数据，并将它们存储到你提供的数组对象中。

另一个有用的方法是`takeDelimiterExclusive()`。在这个方法中，你指定一个"分隔符字符"。这个函数的想法是，它将尝试从"某处"读取尽可能多的数据字节，直到找到你指定的"分隔符字符"，并向你返回包含数据的切片。

这只是对这些类型对象中存在的方法的快速描述。但我建议你阅读官方文档，包括[`Writer`](https://ziglang.org/documentation/master/std/#std.io.Writer)和[`Reader`](https://ziglang.org/documentation/master/std/#std.io.Reader)。我还认为阅读Zig标准库中定义这些对象中存在的方法的模块的源代码是个好主意，它们是[`Reader.zig`](https://github.com/ziglang/zig/blob/master/lib/std/Io/Reader.zig)和[`Writer.zig`](https://github.com/ziglang/zig/blob/master/lib/std/Io/Writer.zig)。

### 介绍文件描述符

"文件描述符"对象是任何操作系统（OS）中进行的每个IO操作背后的核心组件。这样的对象是你的操作系统的特定输入/输出（IO）资源的标识符（[Wikipedia 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-wiki_file_descriptor)）。它描述并标识这个特定的资源。IO资源可能是：

* 文件系统中的现有文件。
* 现有的网络套接字。
* 其他类型的流通道。
* 终端中的管道（或简称"管道"）。

从上面列出的要点中，我们知道虽然术语"文件"存在，但"文件描述符"可能描述的不仅仅是文件。"文件描述符"的概念来自可移植操作系统接口（POSIX）API，这是一套指导世界各地的操作系统应该如何实现的标准，以保持它们之间的兼容性。

文件描述符不仅标识你用于接收或发送某些数据的输入/输出资源，还描述了该资源的位置，以及该资源当前使用的IO模式。例如，这个IO资源可能只使用"读"IO模式，这意味着该资源对"读操作"开放，而"写操作"未被授权。这些IO模式本质上是你提供给C函数`fopen()`的参数`mode`的模式，以及Python内置函数`open()`的模式。

在C中，"文件描述符"是`FILE`指针，但在Zig中，文件描述符是`File`对象。这种数据类型（`File`）在Zig标准库的`std.fs`模块中描述。我们通常不直接在Zig代码中创建`File`对象。相反，我们通常在打开IO资源时作为结果获得这样的对象。换句话说，我们通常要求我们的操作系统为我们打开一个特定的IO资源，如果操作系统成功打开这个IO资源，操作系统通常会向我们返回这个特定IO资源的文件描述符。

所以你通常通过使用Zig标准库中要求操作系统打开某些IO资源的函数和方法来获取`File`对象，比如打开文件系统中文件的`openFile()`方法。我们在[第7.4.1节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-create-socket)中创建的`net.Stream`对象也是一种文件描述符对象。

### _标准输出_

你已经在本书中看到了如何在Zig中访问和使用`stdout`来向用户发送一些输出。为此，我们使用`std.fs`模块中的`File.stdout()`函数。这个函数返回一个描述你当前操作系统的`stdout`通道的文件描述符。通过这个文件描述符对象，我们可以从`stdout`读取或向我们程序的`stdout`写入内容。

虽然我们可以读取记录在`stdout`通道中的内容，但我们通常只向这个通道写入（或"打印"）内容。原因与我们在[第7.4.3节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-read-http-message)中讨论的非常相似，当时我们正在讨论"从"与"写入"我们的小型HTTP服务器项目的连接对象意味着什么。

当我们向通道写入内容时，我们本质上是向该通道的另一端发送数据。相反，当我们从该通道读取内容时，我们本质上是读取通过该通道发送的数据。由于`stdout`是向用户发送输出的通道，这里的关键动词是**发送**。我们想向某人发送某些东西，因此，我们想**写入**某些内容到某个通道。

这就是为什么当我们访问`File.stdout()`时，大多数时候，我们还使用`stdout`文件描述符的`writer()`方法，以获取一个可以用来向这个`stdout`通道写入内容的写入器对象。正如我们在[第13.1.1节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-writer-reader)中描述的，这个`writer()`方法返回一个`Writer`对象，这个`Writer`对象的主要方法之一是`print()`方法，我们在本书中广泛使用它来向`stdout`通道写入（或"打印"）格式化字符串。

你还应该注意到，在下面的例子中，为了实例化这个`Writer`对象，我们必须向`writer()`方法提供对缓冲区对象的引用作为输入。在下面的例子中，这个缓冲区对象是`stdout_buffer`。通过提供这样的缓冲区，我们将`Writer`对象执行的IO操作转换为"缓冲IO操作"。我们将在[第13.2节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-buffered-io)中更多地讨论"缓冲IO"，所以现在不要太担心。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    try stdout.writeAll(
        "This message was written into stdout.\n"
    );
}
```

这个`Writer`对象就像你通常从文件描述符对象获得的任何其他写入器对象一样。所以，你在向文件系统写入文件时使用的写入器对象的相同方法，你也可以在这里使用它们，从`stdout`的文件描述符对象，反之亦然。

### _标准输入_

你可以通过使用`std.fs`模块中的`File.stdin()`函数在Zig中访问_标准输入_（即`stdin`）。像它的兄弟（`File.stdout()`）一样，这个函数也返回一个描述你的操作系统的`stdin`通道的文件描述符对象。

因为我们想从用户那里接收一些输入，这里的关键动词变成了**接收**，因此，我们通常想从`stdin`通道**读取**数据，而不是向其写入数据。所以，我们通常使用`File.stdin()`返回的文件描述符对象的`reader()`方法，以获取一个可以用来从`stdin`读取数据的`Reader`对象。

在下面的例子中，我们尝试使用`takeDelimiterExclusive()`方法从`stdin`读取数据（它将从`stdin`读取所有数据，直到在流中遇到换行符 - `'\n'`），并将这些数据保存到`name`对象中。

你还应该注意到，就像我们对`writer()`方法所做的那样，我们在实例化`Reader`对象时也需要向`reader()`方法提供对缓冲区对象的引用作为输入。原因完全相同。这个输入缓冲区将`Reader`对象执行的IO操作转换为"缓冲IO操作"。

如果你执行这个程序，你会注意到它停止执行，并开始无限期地等待用户的一些输入。换句话说，你需要在终端中输入你的名字，然后按Enter键将你的名字发送到`stdin`。在你将名字发送到`stdin`后，程序读取这个输入，并通过将给定的名字打印到`stdout`来继续执行。在下面的例子中，我在终端中输入了我的名字（Pedro），然后按下Enter键。

```zig
const std = @import("std");
var stdin_buffer: [1024]u8 = undefined;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
var stdin_reader = std.fs.File.stdin().reader(&stdin_buffer);
const stdin = &stdin_reader.interface;
const stdout = &stdout_writer.interface;

pub fn main() !void {
    try stdout.writeAll("Type your name\n");
    try stdout.flush();

    const name = try stdin.takeDelimiterExclusive('\n');

    try stdout.print("Your name is: {s}\n", .{name});
    try stdout.flush();
}
```

```
Type your name
Your name is: Pedro
```

### _标准错误_

_标准错误_（也称为`stderr`）的工作方式与`stdout`和`stdin`完全相同。你只需从`std.fs`模块调用`File.stderr()`函数，就可以获得`stderr`的文件描述符。理想情况下，你应该只向`stderr`写入错误或警告消息，因为这是这个通道的目的。

## 缓冲IO

正如我们在[第13.1节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-io-basics)中所述，输入/输出（IO）操作直接由操作系统执行。是操作系统管理你想用于IO操作的IO资源。这个事实的结果是IO操作严重依赖于系统调用（即直接调用操作系统）。

明确地说，系统调用本身没有什么特别错误的地方。我们在任何低级编程语言编写的任何严肃代码库中都会一直使用它们。然而，系统调用总是比许多不同类型的操作慢几个数量级。

所以偶尔使用系统调用是完全可以的。但当这些系统调用经常使用时，你大多数时候可以清楚地注意到应用程序的性能损失。所以，好的经验法则是只在需要时使用系统调用，并且只在不频繁的情况下使用，以将执行的系统调用数量减少到最少。

### 理解缓冲IO的工作原理

缓冲IO是实现更好性能的策略。它用于减少IO操作进行的系统调用数量，因此，实现更高的性能。在[图13.1](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-unbuffered-io)和[图13.2](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-buffered-io)中，你可以找到两个不同的图表，展示了在非缓冲IO环境与缓冲IO环境中执行的读操作之间的区别。

为了给这些图表提供更好的上下文，让我们假设我们的文件系统中有一个包含著名的Lorem ipsum文本的文本文件。让我们还假设[图13.1](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-unbuffered-io)和[图13.2](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-buffered-io)中的这些图表显示了我们正在执行的从这个文本文件读取Lorem ipsum文本的读操作。当你查看这些图表时，你会注意到的第一件事是，在非缓冲环境中，读操作会导致许多系统调用。更准确地说，在[图13.1](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-unbuffered-io)中显示的图表中，我们每从文本文件读取一个字节就有一个系统调用。另一方面，在[图13.2](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-buffered-io)中，我们只在最开始有一个系统调用。

当我们使用缓冲IO系统时，在我们执行的第一个读操作中，操作系统不是直接向我们的程序发送单个字节，而是首先从文件向缓冲区对象（即数组）发送一块字节。这块字节被缓存/存储在这个缓冲区对象中。

因此，从现在开始，对于你执行的每个新的读操作，这个读操作不是进行新的系统调用来向操作系统请求文件中的下一个字节，而是被重定向到缓冲区对象，该对象已经缓存了这个下一个字节并准备就绪。

![图片1](https://pedropark99.github.io/zig-book/Figures/unbuffered-io.png)

图13.1：非缓冲IO

![图片2](https://pedropark99.github.io/zig-book/Figures/buffered-io.png)

图13.2：缓冲IO

这是缓冲IO系统背后的基本逻辑。缓冲区对象的大小取决于多个因素。但它通常等于一整页内存的大小（4096字节）。如果我们遵循这个逻辑，那么，操作系统读取文件的前4096字节并将其缓存到缓冲区对象中。只要你的程序不从缓冲区消耗所有这4096字节，你就不会创建新的系统调用。

然而，一旦你从缓冲区消耗了所有这4096字节，这意味着缓冲区中没有字节了。在这种情况下，会进行新的系统调用，要求操作系统发送文件中的下一个4096字节，再一次，这些字节被缓存到缓冲区对象中，循环再次开始。

> 提示
>
> 通常，你应该始终在代码中使用缓冲IO读取器或缓冲IO写入器对象。因为它们为你的IO操作提供更好的性能。

### 在Zig中使用缓冲IO

以前，Zig中的IO操作默认不是缓冲的。然而，自从Zig 0.15中引入的新IO接口以来，`Reader`和`Writer`接口在实例化时接受缓冲区对象作为输入，就像我们在[第13.1.3节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-standard-output)中演示的那样。换句话说，必须提供缓冲区对象才能在代码中实例化`Reader`或`Writer`对象。因此，我们在Zig的最新版本中默认具有缓冲IO操作。

如果你将其与其他语言进行比较，你会注意到Zig在其"缓冲IO策略"中采用了略有不同的方法。如果我们以C为例，通过C中的`FILE`指针进行的IO操作默认是缓冲的。然而，在C中，你不需要在实例化这样的`FILE`指针时显式传递缓冲区对象，因为这个缓冲区对象是在幕后为你创建的，因此，它对程序员是不可见的。而在Zig中，你必须自己手动创建这个缓冲区对象。

所以，Zig不仅选择使用缓冲IO，而且还选择让程序员完全控制在此类操作中使用的缓冲区。你（作为程序员）可以直接控制这个缓冲区的大小，你还可以直接控制这个特定缓冲区对象在你的代码中的分配方式（即，你可以在栈上分配它，或者使用`Allocator`对象在堆上分配它），这非常符合Zig的"无隐藏分配"理念。

因此，如果你想在Zig中使用缓冲IO，只需确保将对缓冲区对象的引用作为输入传递给`writer()`或`reader()`方法，以创建默认执行缓冲IO操作的`Writer`或`Reader`对象。

### 不要忘记刷新！

当你在代码中使用缓冲IO操作时，重要的是不要忘记刷新你的缓冲区，特别是在写操作上。基本上，当我们处于缓冲IO场景中，并且我们尝试将数据写入"某处"时，这些数据首先被写入我们作为输入提供给`Writer`对象的IO缓冲区，并且IO缓冲区中的这些数据只有在我们"提交"它时才会有效地写入"某处"。我们通过"刷新我们的IO缓冲区"来"提交"写入IO缓冲区的字节到我们的目标输出。

所以，当我们刷新我们的IO缓冲区时，我们有效地提交了IO缓冲区中存在的数据块，以写入由我们的文件描述符对象描述的IO资源。如果我们不刷新我们的IO缓冲区，那么，这些数据永远不会离开IO缓冲区（即，它永远不会到达IO资源）。因此，当你忘记刷新你的IO资源时，大多数情况下发生的是你在IO资源中得不到任何类型的输出。

例如，如果你正在向`stdout`写入数据，并且你忘记刷新它，通常发生的是你在终端中得不到任何类型的写入输出。程序似乎成功运行，但你在终端中得不到任何类型的视觉输出来确认它，你会感到非常沮丧和困惑。

因此，如果你在Zig中写入数据，不要忘记通过调用`Writer`对象的`flush()`方法来刷新你的IO缓冲区。这将确保你正在写入的字节/数据有效地写入由你的文件描述符对象描述的IO资源。

> 重要提示
>
> 如果你正在写入数据，不要忘记通过调用`Writer`对象的`flush()`方法来刷新你的IO缓冲区。

## 文件系统基础

现在我们已经讨论了Zig中输入/输出操作的基础知识，我们需要讨论文件系统的基础知识，这是任何操作系统的另一个核心部分。此外，文件系统与输入/输出相关，因为我们在计算机中存储和创建的文件被视为IO资源，正如我们在[第13.1.2节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-file-descriptor)中所述。

### 当前工作目录（CWD）的概念

工作目录是你当前在计算机上所在的文件夹。换句话说，它是你的程序当前正在查看的文件夹。因此，每当你执行一个程序时，这个程序总是与计算机上的特定文件夹一起工作。程序最初会在这个文件夹中查找你需要的文件，也会在这个文件夹中最初保存你要求它保存的所有文件。

工作目录由你在终端中调用程序的文件夹决定。换句话说，如果你在你的操作系统的终端中，并且你从这个终端执行一个二进制文件（即程序），你的终端指向的文件夹就是正在执行的程序的当前工作目录。

在[图13.3](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-cwd)中，我们有一个从终端执行程序的例子。我们正在执行通过编译名为`hello.zig`的Zig模块由`zig`编译器输出的程序。在这种情况下，CWD是`zig-book`文件夹。换句话说，当`hello.zig`程序执行时，它将查看`zig-book`文件夹，我们在这个程序内执行的任何文件操作都将使用这个`zig-book`文件夹作为"起点"或"中心焦点"。

![图片3](https://pedropark99.github.io/zig-book/Figures/cwd.png)

图13.3：从终端执行程序

仅仅因为我们植根于计算机的特定文件夹（在[图13.3](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-cwd)的情况下，是`zig-book`文件夹），并不意味着我们不能访问或写入计算机其他位置的资源。当前工作目录（CWD）机制只是定义了你的程序首先查找你请求的文件的位置。这不会阻止你访问位于计算机其他地方的文件。但是，要访问不在当前工作目录中的任何文件，你必须提供该文件或文件夹的路径。

### 路径的概念

路径本质上是一个位置。它指向文件系统中的一个位置。我们使用路径来描述计算机中文件和文件夹的位置。关于路径的一个重要方面是它们总是写在字符串中，即它们总是作为文本值提供。

你可以向任何操作系统中的任何程序提供两种类型的路径：相对路径或绝对路径。绝对路径是从文件系统的根开始，一直到你所指的文件名或特定文件夹的路径。这种类型的路径被称为绝对路径，因为它指向计算机上唯一且绝对的位置。也就是说，你的计算机上没有其他现有位置对应于这个路径。它是一个唯一标识符。

在Windows中，绝对路径是以硬盘标识符开头的路径（例如`C:/Users/pedro`）。另一方面，Linux和macOS中的绝对路径是以正斜杠字符开头的路径（例如`/usr/local/bin`）。注意路径由"段"组成。每个段通过斜杠字符（`\`或`/`）相互连接。在Windows上，通常使用反斜杠（`\`）来连接路径段。而在Linux和macOS上，正斜杠（`/`）是用于连接路径段的字符。

相对路径是从CWD开始的路径。换句话说，相对路径是"相对于CWD"的。用于访问[图13.3](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-cwd)中`hello.zig`文件的路径是相对路径的一个例子。这个路径在下面重现。这个路径从CWD开始，在[图13.3](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fig-cwd)的上下文中，是`zig-book`文件夹，然后，它进入`ZigExamples`文件夹，然后进入`zig-basics`，然后到`hello.zig`文件。

```
ZigExamples/zig-basics/hello_world.zig
```

### 路径通配符

在提供路径时，特别是相对路径，你可以选择使用_通配符_。路径中有两个常用的_通配符_，它们是"一个句点"（.）和"两个句点"（..）。换句话说，这两个特定字符在路径中使用时具有特殊含义，并且可以在任何操作系统（Mac、Windows、Linux等）上使用。也就是说，它们是"跨平台的"。

"一个句点"代表当前目录的别名。这意味着相对路径`"./Course/Data/covid.csv"`和`"Course/Data/covid.csv"`是等价的。另一方面，"两个句点"指的是上一个目录。例如，路径`"Course/.."`等价于路径`"."`，即当前工作目录。

因此，路径`"Course/.."`指的是`Course`文件夹之前的文件夹。作为另一个例子，路径`"src/writexml/../xml.cpp"`指的是在`writexml`文件夹之前的文件夹内的文件`xml.cpp`，在这个例子中是`src`文件夹。因此，这个路径等价于`"src/xml.cpp"`。

## CWD处理器

在Zig中，文件系统操作通常通过目录处理器对象进行。Zig中的目录处理器是类型为`Dir`的对象，它是描述我们计算机文件系统中特定文件夹的对象。你通常通过调用`std.fs.cwd()`函数创建`Dir`对象。这个函数返回一个指向（或描述）当前工作目录（CWD）的`Dir`对象。

通过这个`Dir`对象，你可以创建新文件，或修改或读取CWD内的现有文件。换句话说，`Dir`对象是Zig中执行多种类型文件系统操作的主要入口点。在下面的例子中，我们正在创建这个`Dir`对象，并将其存储在`cwd`对象中。虽然我们在这个代码示例中没有使用这个对象，但我们将在接下来的示例中大量使用它。

```zig
const cwd = std.fs.cwd();
_ = cwd;
```

## 文件操作

### 创建文件

我们通过使用`Dir`对象的`createFile()`方法创建新文件。只需提供你想要创建的文件的名称，这个函数将执行创建此类文件的必要步骤。你也可以向这个函数提供相对路径，它将按照这个相对于CWD的路径创建文件。

这个函数可能会返回错误，所以，你应该使用`try`、`catch`或[第10章](https://pedropark99.github.io/zig-book/Chapters/09-error-handling.html)中介绍的任何其他方法来处理可能的错误。但如果一切顺利，这个`createFile()`方法会返回一个文件描述符对象（即`File`对象）作为结果，通过它你可以使用我之前介绍的IO操作向文件添加内容。

看看下面的代码示例。在这个例子中，我们正在创建一个名为`foo.txt`的新文本文件。如果函数`createFile()`成功，名为`file`的对象将包含一个文件描述符对象，我们可以使用它向文件写入（或添加）新内容，就像我们在这个例子中所做的那样，通过使用缓冲写入器对象向文件写入新的文本行。

现在，快速说明一下，当我们在C中通过使用像`fopen()`这样的C函数创建文件描述符对象时，我们必须始终在程序结束时关闭文件，或者，一旦我们完成了想要对文件执行的所有操作。在Zig中，这没有什么不同。所以每次我们创建一个新文件时，这个文件都保持"打开"状态，等待执行某些操作。一旦我们完成了它，我们总是必须关闭这个文件，以释放与它相关的资源。在Zig中，我们通过从文件描述符对象调用`close()`方法来做到这一点。

```zig
const cwd = std.fs.cwd();
const file = try cwd.createFile("foo.txt", .{});
// 不要忘记在最后关闭文件。
defer file.close();
// 对文件做一些事情...
var fw = file.writer();
_ = try fw.writeAll(
    "Writing this line to the file\n"
);
```

所以，在这个例子中，我们不仅在文件系统中创建了一个文件，而且还使用`createFile()`返回的文件描述符对象向这个文件写入了一些数据。如果你尝试创建的文件已经存在于你的文件系统中，这个`createFile()`调用将覆盖文件的内容，或者换句话说，它将擦除现有文件的所有内容。

如果你不希望这种情况发生，也就是说，你不想覆盖现有文件的内容，但你无论如何都想向这个文件写入数据（即，你想向文件追加数据），你应该使用`Dir`对象的`openFile()`方法。

关于`createFile()`的另一个重要方面是，这个方法创建的文件默认不对读操作开放。这意味着你不能读取这个文件。你不被允许。所以例如，你可能想在程序执行的开始向这个文件写入一些内容。然后，在程序的未来某个时刻，你可能需要读取你在这个文件中写的内容。如果你尝试从这个文件读取数据，你可能会得到`NotOpenForReading`错误作为结果。

但是你如何克服这个障碍？你如何创建一个对读操作开放的文件？你所要做的就是在`createFile()`的第二个参数中将`read`标志设置为true。当你将这个标志设置为true时，文件就会以"读权限"创建，因此，像下面这样的程序就变得有效：

```zig
const cwd = std.fs.cwd();
const file = try cwd.createFile(
    "foo.txt",
    .{ .read = true }
);
defer file.close();

var fw = file.writer();
_ = try fw.writeAll("We are going to read this line\n");

var buffer: [300]u8 = undefined;
@memset(buffer[0..], 0);
try file.seekTo(0);
var fr = file.reader();
_ = try fr.readAll(buffer[0..]);
try stdout.print("{s}\n", .{buffer});
try stdout.flush();
```

```
We are going to read this line
```

如果你不熟悉位置指示器，你可能不认识`seekTo()`方法。如果是这种情况，不要担心，我们将在[第13.6节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-indicators)中更多地讨论这个方法。但本质上这个方法是将位置指示器移回文件的开头，以便我们可以从头开始读取文件的内容。

### 打开文件并向其追加数据

打开文件很容易。只需使用`openFile()`方法而不是`createFile()`。在`openFile()`的第一个参数中，你提供要打开的文件的路径。然后，在第二个参数中，你提供决定文件如何打开的标志（或选项）。

你可以通过访问[`OpenFlags`](https://ziglang.org/documentation/master/std/#std.fs.File.OpenFlags)的文档来查看`openFile()`的完整选项列表。但你最肯定会使用的主要标志是`mode`标志。这个标志指定文件打开时将使用的IO模式。有三种IO模式，或者说，你可以为这个标志提供三个值，它们是：

* `read_only`，只允许对文件进行读操作。所有写操作都被阻止。
* `write_only`，只允许对文件进行写操作。所有读操作都被阻止。
* `read_write`，允许对文件进行写和读操作。

这些模式类似于你提供给Python内置函数`open()`的`mode`参数的模式，或C函数`fopen()`的`mode`参数。在下面的代码示例中，我们以`write_only`模式打开`foo.txt`文本文件，并在文件末尾追加新的文本行。我们这次使用`seekFromEnd()`来保证我们将文本追加到文件末尾。再一次，像`seekFromEnd()`这样的方法在[第13.6节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-indicators)中有更深入的描述。

```zig
const cwd = std.fs.cwd();
const file = try cwd.openFile(
    "foo.txt", .{ .mode = .write_only }
);
defer file.close();
try file.seekFromEnd(0);
var fw = file.writer();
_ = try fw.writeAll("Some random text to write\n");
```

### 删除文件

有时，我们只需要删除/移除我们拥有的文件。为此，我们使用`deleteFile()`方法。你只需提供要删除的文件的路径，这个方法将尝试删除位于此路径的文件。

```zig
const cwd = std.fs.cwd();
try cwd.deleteFile("foo.txt");
```

### 复制文件

要复制现有文件，我们使用`copyFile()`方法。这个方法的第一个参数是你想要复制的文件的路径。第二个参数是`Dir`对象，即目录处理器，更具体地说，是指向你想要将文件复制到的计算机文件夹的`Dir`对象。第三个参数是文件的新路径，或者换句话说，文件的新位置。第四个参数是复制操作中使用的选项（或标志）。

你作为输入提供给这个方法的`Dir`对象将用于将文件复制到新位置。你可以在调用`copyFile()`方法之前创建这个`Dir`对象。也许你计划将文件复制到计算机中完全不同的位置，所以可能值得为该位置创建一个目录处理器。但如果你将文件复制到CWD的子文件夹，那么，你可以简单地将CWD处理器传递给这个参数。

```zig
const cwd = std.fs.cwd();
try cwd.copyFile(
    "foo.txt",
    cwd,
    "ZigExamples/file-io/foo.txt",
    .{}
);
```

### 阅读文档！

`Dir`对象中还有一些其他用于文件操作的有用方法，比如`writeFile()`方法，但我建议你阅读[`Dir`类型](https://ziglang.org/documentation/master/std/#std.fs.Dir)的文档来探索其他可用的方法，因为我已经谈论了太多关于它们的内容。

## 位置指示器

位置指示器就像一种游标或索引。这个"索引"标识你拥有的文件描述符对象当前正在查看的文件（或数据流）中的当前位置。当你创建文件描述符时，位置指示器从文件的开头或流的开头开始。当你从这个文件描述符对象描述的文件（或套接字、或数据流等）读取或写入时，你最终会移动位置指示器。

换句话说，任何IO操作都有一个常见的副作用，即移动位置指示器。例如，假设我们有一个总大小为300字节的文件。如果你从文件中读取100字节，那么，位置指示器向前移动100字节。如果你尝试向同一文件写入50字节，这50字节将从位置指示器指示的当前位置写入。由于指示器距文件开头100字节，这50字节将写入文件中间。

这就是为什么我们在[第13.5.1节](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#sec-creating-files)中提供的最后一个代码示例中使用了`seekTo()`方法。我们使用这个方法将位置指示器移回文件的开头，这将确保我们将想要写的文本从文件的开头写入，而不是从文件中间写入。因为在写操作之前，我们执行了读操作，这意味着位置指示器在这个读操作中被移动了。

文件描述符对象的位置指示器可以通过使用此文件描述符的"seek"方法来更改（或改变），它们是：`seekTo()`、`seekFromEnd()`和`seekBy()`。这些方法具有与C函数[`fseek()`](https://en.cppreference.com/w/c/io/fseek)相同的效果或相同的责任。

考虑到`offset`指的是你作为输入提供给这些"seek"方法的索引，下面的要点总结了每个方法的效果。作为快速说明，在`seekFromEnd()`和`seekBy()`的情况下，提供的`offset`可以是正索引或负索引。

* `seekTo()`将位置指示器移动到距文件开头`offset`字节的位置。
* `seekFromEnd()`将位置指示器移动到距文件末尾`offset`字节的位置。
* `seekBy()`将位置指示器移动到距文件当前位置`offset`字节的位置。

## 目录操作

### 遍历目录中的文件

与文件系统相关的最经典任务之一是能够遍历目录中的现有文件。要遍历目录中的文件，我们需要创建一个迭代器对象。

你可以通过使用`Dir`对象的`iterate()`或`walk()`方法生成这样的迭代器对象。两个方法都返回一个迭代器对象作为输出，你可以使用`next()`方法来推进它。这些方法之间的区别是，`iterate()`返回一个非递归迭代器，而`walk()`返回递归迭代器。这意味着`walk()`返回的迭代器不仅会遍历当前目录中可用的文件，还会遍历当前目录内找到的任何子目录中的文件。

在下面的例子中，我们正在显示存储在目录`ZigExamples/file-io`中的文件名称。注意我们必须通过`openDir()`函数打开这个目录。还要注意，我们在`openDir()`的第二个参数中提供了`iterate`标志。这个标志很重要，因为没有这个标志，我们将不被允许遍历这个目录中的文件。

```zig
const cwd = std.fs.cwd();
const dir = try cwd.openDir(
    "ZigExamples/file-io/",
    .{ .iterate = true }
);
var it = dir.iterate();
while (try it.next()) |entry| {
    try stdout.print(
        "File name: {s}\n",
        .{entry.name}
    );
}
try stdout.flush();
```

```
File name: create_file_and_write_toit.zig
File name: create_file.zig
File name: lorem.txt
File name: iterate.zig
File name: delete_file.zig
File name: append_to_file.zig
File name: user_input.zig
File name: foo.txt
File name: create_file_and_read.zig
File name: buff_io.zig
File name: copy_file.zig
```

### 创建新目录

在创建目录时有两个重要的方法，它们是`makeDir()`和`makePath()`。这两个方法之间的区别是，`makeDir()`在每次调用中只能在当前目录中创建一个目录，而`makePath()`能够在同一调用中递归创建子目录。

这就是为什么这个方法的名称是"make path"。它将创建创建你作为输入提供的路径所需的尽可能多的子目录。所以，如果你向这个方法提供路径`"sub1/sub2/sub3"`作为输入，它将在同一函数调用中创建三个不同的子目录，`sub1`、`sub2`和`sub3`。相反，如果你向`makeDir()`提供这样的路径作为输入，你可能会得到一个错误作为结果，因为这个方法只能创建一个子目录。

```zig
const cwd = std.fs.cwd();
try cwd.makeDir("src");
try cwd.makePath("src/decoders/jpg/");
```

### 删除目录

要删除目录，只需将要删除的目录的路径作为输入提供给`Dir`对象的`deleteDir()`方法。在下面的例子中，我们正在删除我们刚刚在前面的例子中创建的`src`目录。

```zig
const cwd = std.fs.cwd();
try cwd.deleteDir("src");
```

## 结论

在本章中，我描述了如何在Zig中执行最常见的文件系统和IO操作。但你可能会感觉本章缺少一些其他不太常见的操作，例如：如何重命名文件，或如何打开目录，或如何创建符号链接，或如何使用`access()`来测试特定路径是否存在于你的计算机中。但对于所有这些不太常见的任务，我建议你阅读[`Dir`类型](https://ziglang.org/documentation/master/std/#std.fs.Dir)的文档，因为你可以在那里找到这些情况的良好描述。

---

## 脚注

1. 以前，这些对象被称为`GenericReader`和`GenericWriter`对象。但这两种类型在0.15中都被弃用了。[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref1)

2. 我们在[第7.4.1节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-create-socket)中创建的套接字对象是网络套接字的例子。[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref2)

3. [https://ziglang.org/documentation/master/std/#std.io.Writer](https://ziglang.org/documentation/master/std/#std.io.Writer).[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref3)

4. [https://ziglang.org/documentation/master/std/#std.io.Reader](https://ziglang.org/documentation/master/std/#std.io.Reader).[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref4)

5. [https://github.com/ziglang/zig/blob/master/lib/std/Io/Reader.zig](https://github.com/ziglang/zig/blob/master/lib/std/Io/Reader.zig).[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref5)

6. [https://github.com/ziglang/zig/blob/master/lib/std/Io/Writer.zig](https://github.com/ziglang/zig/blob/master/lib/std/Io/Writer.zig).[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref6)

7. 管道是进程间通信或进程间IO的机制。你也可以将管道解释为"通过系统的标准输入/输出设备链接在一起的一组进程"。例如在Linux中，管道是在终端内创建的，通过用"管道"字符（`|`）连接两个或多个终端命令。[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref7)

8. [https://www.lipsum.com/](https://www.lipsum.com/).[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref8)

9. [https://ziglang.org/documentation/master/std/#std.fs.File.OpenFlags](https://ziglang.org/documentation/master/std/#std.fs.File.OpenFlags)[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref9)

10. [https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files](https://docs.python.org/3/tutorial/inputoutput.html#reading-and-writing-files)[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref10)

11. [https://www.tutorialspoint.com/c_standard_library/c_function_fopen.htm](https://www.tutorialspoint.com/c_standard_library/c_function_fopen.htm)[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref11)

12. [https://ziglang.org/documentation/master/std/#std.fs.Dir](https://ziglang.org/documentation/master/std/#std.fs.Dir)[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref12)

13. [https://en.cppreference.com/w/c/io/fseek](https://en.cppreference.com/w/c/io/fseek)[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref13)

14. [https://ziglang.org/documentation/master/std/#std.fs.Dir](https://ziglang.org/documentation/master/std/#std.fs.Dir)[↩︎](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html#fnref14)
