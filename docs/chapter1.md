# 第1章 Zig介绍 - Zig语言入门

在这一章中，我想向你介绍Zig的世界。Zig是一门非常年轻的语言，正在积极开发中。因此，它的世界仍然非常原始，有待探索。这本书是我帮助你理解和探索Zig这个激动人心的世界的个人旅程的尝试。

我假设你在阅读本书时已经有一些编程语言的经验，不一定是低级语言。所以，如果你有Python或Javascript的经验，例如，那就足够了。但是，如果你确实有低级语言的经验，如C、C++或Rust，你可能会在本书中学得更快。

## 什么是Zig？

Zig是一门现代的、低级的、通用编程语言。一些程序员认为Zig是C的现代化和改进版本。

在作者的个人理解中，Zig与"少即是多"的理念紧密相连。Zig不是通过添加越来越多的功能来成为现代语言，而是通过移除C和C++中令人烦恼的行为/功能来带来核心改进。换句话说，Zig试图通过简化语言，并具有更一致和健壮的行为来变得更好。因此，在Zig中分析、编写和调试应用程序变得比在C或C++中更容易和简单。

这种哲学通过Zig官方网站上的以下短语变得清晰：

> "专注于调试你的应用程序，而不是调试你的编程语言知识"。

这句话对C++程序员特别真实。因为C++是一门巨大的语言，有大量的功能，而且有很多不同的"C++风格"。这些元素使C++变得如此复杂和难以学习。Zig试图朝相反的方向发展。Zig是一门非常简单的语言，更接近其他简单的语言，如C和Go。

上面的短语对C程序员也很重要。因为，即使C是一门简单的语言，有时阅读和理解C代码仍然很困难。例如，C中的预处理器宏经常是混乱的源头。有时，它们真的让调试C程序变得困难。因为宏本质上是嵌入在C中的第二语言，它们模糊了你的C代码。使用宏，你不再100%确定哪些代码片段被发送到编译器，即它们模糊了你编写的实际源代码。

在Zig中没有宏。在Zig中，你编写的代码就是编译器实际编译的代码。你也没有在幕后发生的隐藏控制流。而且，你也没有标准库中的函数或操作符在你背后进行隐藏的内存分配。

通过成为一门更简单的语言，Zig变得更清晰、更容易读写，但同时，它也达到了更健壮的状态，在边缘情况下具有更一致的行为。再一次，少即是多。

## Zig中的Hello World

我们通过创建一个小的"Hello World"程序开始我们的Zig之旅。要在你的计算机上启动一个新的Zig项目，你只需从`zig`编译器调用`init`命令。只需在你的计算机上创建一个新目录，然后在这个目录中初始化一个新的Zig项目，如下所示：

```
mkdir hello_world
cd hello_world
zig init
```

```
info: created build.zig
info: created build.zig.zon
info: created src/main.zig
info: created src/root.zig
info: see `zig build --help` for a menu of options
```

### 理解项目文件

在你从`zig`编译器运行`init`命令后，一些新文件会在你的当前目录中创建。首先，创建了一个"源"（`src`）目录，包含两个文件，`main.zig`和`root.zig`。每个`.zig`文件是一个单独的Zig模块，它只是一个包含一些Zig代码的文本文件。

按照惯例，`main.zig`模块是你的main函数所在的地方。因此，如果你正在用Zig构建一个可执行程序，你需要声明一个`main()`函数，它代表你程序的入口点，即你程序执行开始的地方。

然而，如果你正在构建一个库（而不是可执行程序），那么，正常的程序是删除这个`main.zig`文件并从`root.zig`模块开始。按照惯例，`root.zig`模块是你库的根源文件。

`tree .`

```
.
├── build.zig
├── build.zig.zon
└── src
    ├── main.zig
    └── root.zig

1 directory, 4 files
```

`init`命令还在我们的工作目录中创建了两个额外的文件：`build.zig`和`build.zig.zon`。第一个文件（`build.zig`）代表一个用Zig编写的构建脚本。当你从`zig`编译器调用`build`命令时，这个脚本会被执行。换句话说，这个文件包含执行构建整个项目所需步骤的Zig代码。

低级语言通常使用编译器将你的源代码构建成二进制可执行文件或二进制库。然而，一旦项目变得越来越大，编译源代码和从中构建二进制可执行文件或二进制库的过程在编程世界中成为了一个真正的挑战。因此，程序员创建了"构建系统"，这是一套旨在使编译和构建复杂项目的过程更容易的第二套工具。

构建系统的例子有CMake、GNU Make、GNU Autoconf和Ninja，它们用于构建复杂的C和C++项目。使用这些系统，你可以编写脚本，称为"构建脚本"。它们只是描述编译/构建项目所需步骤的脚本。

然而，这些是独立的工具，不属于C/C++编译器，如`gcc`或`clang`。因此，在C/C++项目中，你不仅需要安装和管理你的C/C++编译器，还需要单独安装和管理这些构建系统。

在Zig中，我们不需要使用单独的工具集来构建我们的项目，因为构建系统嵌入在语言本身中。我们可以使用这个构建系统在Zig中编写小脚本，描述构建/编译我们的Zig项目所需的步骤。所以，构建复杂Zig项目所需的一切就是`zig`编译器，仅此而已。

第二个生成的文件（`build.zig.zon`）是一个类似JSON的文件，你可以在其中描述你的项目，并声明你想从互联网获取的项目依赖项集。换句话说，你可以使用这个`build.zig.zon`文件在你的项目中包含外部库列表。

在你的项目中包含外部Zig库的一种可能方法是手动构建并在系统中安装库，然后在项目的构建步骤中将你的源代码与库链接。

然而，如果这个外部Zig库在GitHub上可用，例如，并且在项目的根文件夹中有一个有效的`build.zig.zon`文件来描述项目，你可以通过简单地在你的`build.zig.zon`文件中列出这个外部库来轻松地将这个库包含在你的项目中。

换句话说，这个`build.zig.zon`文件的工作方式类似于Javascript项目中的`package.json`文件，或Python项目中的`Pipfile`文件，或Rust项目中的`Cargo.toml`文件。你可以在互联网上的几篇文章中阅读更多关于这个特定文件的信息，你也可以在Zig官方仓库内的文档文件中看到这个`build.zig.zon`文件的预期模式。

### root.zig文件

让我们看看`root.zig`文件。你可能已经注意到，每行带有表达式的代码都以分号（`;`）结尾。这遵循C系列编程语言的语法。

另外，注意第一行的`@import()`调用。我们使用这个内置函数从其他Zig模块导入功能到我们的当前模块。这个`@import()`函数的工作方式类似于C或C++中的`#include`预处理器，或者Python或Javascript代码中的`import`语句。在这个例子中，我们正在导入`std`模块，它让你访问Zig标准库。

在这个`root.zig`文件中，我们还可以看到在Zig中如何进行赋值（即创建新对象）。你可以在Zig中使用语法`(const|var) name = value;`创建一个新对象。在下面的例子中，我们正在创建两个常量对象（`std`和`testing`）。在[第1.4节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-assignments)中我们将更多地讨论一般的对象。

```zig
const std = @import("std");
const testing = std.testing;

export fn add(a: i32, b: i32) i32 {
    return a + b;
}
```

在Zig中使用`fn`关键字声明函数。在这个`root.zig`模块中，我们声明了一个名为`add()`的函数，它有两个名为`a`和`b`的参数。该函数返回一个`i32`类型的整数作为结果。

Zig是一门强类型语言。有一些特定的情况下，如果`zig`编译器可以推断类型，你可以（如果你想）省略代码中对象的类型（我们在[第2.4节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-type-inference)中更多地讨论这个）。但还有其他情况下你确实需要明确。例如，你必须明确指定每个函数参数的类型，以及你在Zig中创建的每个函数的返回类型。

我们在Zig中通过在对象/函数参数名称后使用冒号字符（`:`）后跟类型来指定对象或函数参数的类型。通过表达式`a: i32`和`b: i32`，我们知道`a`和`b`参数都有类型`i32`，这是一个有符号的32位整数。在这部分，Zig的语法与Rust的语法相同，Rust也使用冒号字符来指定类型。

最后，我们在行末有函数的返回类型，在我们打开花括号开始编写函数体之前。在上面的例子中，这个类型也是一个有符号的32位整数（`i32`）值。

注意我们在函数声明之前还有一个`export`关键字。这个关键字类似于C中的`extern`关键字。它暴露函数使其在库API中可用。因此，如果你正在为其他人编写一个库，你必须通过使用这个`export`关键字在这个库的公共API中暴露你编写的函数。如果我们从`add()`函数声明中删除`export`关键字，那么，这个函数将不再在`zig`编译器构建的库对象中暴露。

### main.zig文件

现在我们已经从`root.zig`文件中学到了很多关于Zig语法的知识，让我们看看`main.zig`文件。我们在`root.zig`中看到的很多元素也出现在`main.zig`中。但还有一些我们还没有见过的其他元素，所以让我们深入了解。

首先，看看这个文件中`main()`函数的返回类型。我们可以看到一个小的变化。函数的返回类型（`void`）伴随着一个感叹号（`!`）。这个感叹号告诉我们这个`main()`函数可能返回一个错误。

值得注意的是，Zig中的`main()`函数允许返回空（`void`）、或无符号8位整数（`u8`）值，或错误。换句话说，你可以在Zig中编写你的`main()`函数返回本质上什么都不返回（`void`），或者，如果你愿意，你也可以编写一个更像C的`main()`函数，它返回一个整数值，通常作为进程的"状态码"。

在这个例子中，`main()`的返回类型注释表明这个函数可以返回空（`void`），或返回一个错误。返回类型注释中的这个感叹号是Zig的一个有趣而强大的功能。总之，如果你编写一个函数，函数体内的某些内容可能返回错误，那么，你被迫：

* 要么在函数的返回类型中添加感叹号，明确表明这个函数可能返回错误。
* 要么在函数内部明确处理这个错误。

在大多数编程语言中，我们通常通过 try-catch模式处理（或处理）错误。Zig确实有`try`和`catch`关键字。但它们的工作方式与你在其他语言中习惯的有点不同。

如果我们看下面的`main()`函数，你可以看到第5行确实有一个`try`关键字。但这段代码中没有`catch`关键字。在Zig中，我们使用`try`关键字来执行可能返回错误的表达式，在这个例子中是`stdout.print()`表达式。

本质上，`try`关键字执行表达式`stdout.print()`。如果这个表达式返回一个有效值，那么，`try`关键字什么都不做。它只是向前传递值。就好像这个`try`关键字从来不存在一样。然而，如果表达式确实返回一个错误，那么，`try`关键字将解包错误值，然后，它从函数返回这个错误，并将当前堆栈跟踪打印到`stderr`。

如果你来自高级语言，这可能听起来很奇怪。因为在高级语言中，如Python，如果某个地方发生错误，这个错误会自动返回，你的程序执行会自动停止，即使你不想停止执行。你被迫面对错误。

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

你可能在这个代码示例中注意到的另一件事是，`main()`函数用`pub`关键字标记。它将`main()`函数标记为该模块的**公共函数**。你的Zig模块中的每个函数默认对这个Zig模块是私有的，只能从模块内部调用。除非，你用`pub`关键字明确将此函数标记为公共函数。

如果你仔细想想，Zig中的这个`pub`关键字本质上做的是C/C++中`static`关键字的相反。通过使函数"公共"，你允许其他Zig模块访问和调用这个函数。调用的Zig模块通过使用`@import()`内置函数导入另一个模块，这使得导入模块的所有公共函数对调用的Zig模块可见。

### 编译你的源代码

你可以通过从`zig`编译器运行`build-exe`命令将你的Zig模块编译成二进制可执行文件。你只需在`build-exe`命令后列出你想要构建的所有Zig模块，用空格分隔。在下面的例子中，我们正在编译模块`main.zig`。

`zig build-exe src/main.zig`

由于我们正在构建一个可执行文件，`zig`编译器将在你在`build-exe`命令后列出的任何文件中寻找声明的`main()`函数。如果编译器没有在某处找到声明的`main()`函数，将会引发编译错误，警告这个错误。

`zig`编译器还提供`build-lib`和`build-obj`命令，它们的工作方式与`build-exe`命令完全相同。唯一的区别是，它们分别将你的Zig模块编译成可移植的C ABI库或对象文件。

在`build-exe`命令的情况下，`zig`编译器在你项目的根目录中创建一个二进制可执行文件。如果我们现在用简单的`ls`命令查看当前目录的内容，我们可以看到编译器创建的名为`main`的二进制文件。

`ls`

`build.zig  build.zig.zon  main  src`

如果我执行这个二进制可执行文件，我会在终端中得到"Hello World"消息，正如我们预期的那样。

`./main`

`Hello, world!`

### 同时编译和执行

在前一节中，我介绍了`zig build-exe`命令，它将Zig模块编译成可执行文件。然而，这意味着，为了执行可执行文件，我们必须运行两个不同的命令。首先，`zig build-exe`命令，然后，调用编译器创建的可执行文件。

但是如果我们想一次性执行这两个步骤，在一个命令中呢？我们可以通过使用`zig run`命令来做到这一点。

`zig run src/main.zig`

`Hello, world!`

### Windows用户的重要说明

首先，这是Windows特有的事情，因此，不适用于其他操作系统，如Linux和macOS。总之，如果你有一段Zig代码，其中包含一些全局变量，其初始化依赖于运行时资源，那么，你在Windows上尝试编译这个Zig代码时可能会遇到一些麻烦。

一个例子是访问`stdout`（即系统的_标准输出_），在Zig中通常使用表达式`std.fs.File.stdout()`来完成。如果你使用这个表达式在Zig模块中实例化一个全局变量，那么，你的Zig代码的编译很可能会在Windows上失败，出现"unable to evaluate comptime expression"错误消息。

编译过程中的这个失败发生是因为Zig中的所有全局变量都在**编译时**初始化。然而，在Windows上，像访问`stdout`（或打开文件）这样的操作依赖于仅在**运行时**可用的资源（你将在[第3.1.1节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-compile-time)中了解更多关于编译时与运行时的内容）。

例如，如果你尝试在Windows上编译这个代码示例，你可能会得到下面显示的错误消息：

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
// 错误！编译时错误来自
// 下一行，在`stdout`对象上
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    _ = try stdout.write("Hello\n");
    try stdout.flush();
}
```

```
t.zig:2107:28: error: unable to evaluate comptime expression
    break :blk asm {
               ^~~
```

为了避免Windows上的这个问题，我们需要强制`zig`编译器仅在运行时实例化这个`stdout`对象，而不是在编译时实例化它。我们可以通过简单地将表达式移动到函数体中来实现这一点。

这解决了问题，因为Zig中函数体内的所有表达式仅在运行时评估，除非你明确使用`comptime`关键字来改变这种行为。你将在[第12.1节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-comptime)中了解更多关于这个`comptime`关键字的内容。

```zig
const std = @import("std");
pub fn main() !void {
    // 成功：Stdout在运行时初始化。
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    _ = try stdout.write("Hello\n");
    try stdout.flush();
}
```

`Hello`

你可以在Zig官方仓库开放的几个GitHub问题中阅读更多关于这个Windows特定限制的详细信息。更具体地说，问题17186和19864。

### 编译整个项目

正如我在[第1.2.1节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-project-files)中描述的，随着我们的项目规模和复杂性的增长，我们通常更喜欢使用某种"构建系统"将项目的编译和构建过程组织到构建脚本中。

换句话说，随着我们的项目规模和复杂性的增长，`build-exe`、`build-lib`和`build-obj`命令变得更难直接使用。因为然后，我们开始同时列出多个模块。我们还开始添加内置编译标志来根据我们的需要自定义构建过程等。手动编写必要的命令变成了很多工作。

在C/C++项目中，程序员通常选择使用CMake、Ninja、`Makefile`或`configure`脚本来组织这个过程。然而，在Zig中，我们在语言本身中有一个原生的构建系统。所以，我们可以在Zig中编写构建脚本来编译和构建Zig项目。然后，我们需要做的就是调用`zig build`命令来构建我们的项目。

所以，当你执行`zig build`命令时，`zig`编译器将在你的当前目录中搜索名为`build.zig`的Zig模块，这应该是你的构建脚本，包含编译和构建项目所需的代码。如果编译器确实在你的目录中找到这个`build.zig`文件，那么，编译器基本上会对这个`build.zig`文件执行`zig run`命令，以编译和执行这个构建脚本，这反过来会编译和构建你的整个项目。

`zig build`

执行这个"构建项目"命令后，在你的项目目录的根目录中创建了一个`zig-out`目录，你可以在其中找到从你的Zig模块创建的二进制可执行文件和库，根据你在`build.zig`中指定的构建命令。我们将在本书后面更多地讨论Zig中的构建系统。

在下面的例子中，我正在执行编译器在`zig build`命令后生成的名为`hello_world`的二进制可执行文件。

`./zig-out/bin/hello_world`

`Hello, world!`

## 如何学习Zig？

学习Zig的最佳策略是什么？首先，当然这本书会在你的Zig之旅中帮助你很多。但如果你想真正擅长Zig，你还需要一些额外的资源。

作为第一个提示，你可以加入一个有Zig程序员的社区来获得一些帮助，当你需要时：

* Reddit论坛：[https://www.reddit.com/r/Zig/](https://www.reddit.com/r/Zig/)；
* Ziggit社区：[https://ziggit.dev/](https://ziggit.dev/)；
* Discord、Slack、Telegram等：[https://github.com/ziglang/zig/wiki/Community](https://github.com/ziglang/zig/wiki/Community)；

现在，学习Zig的最佳方法之一是简单地阅读Zig代码。尝试经常阅读Zig代码，事情会变得更清楚。C/C++程序员也可能会给你同样的提示。因为这个策略真的有效！

现在，你在哪里可以找到Zig代码来阅读？我个人认为，阅读Zig代码的最佳方式是阅读Zig标准库的源代码。Zig标准库在Zig官方GitHub仓库的[`lib/std`文件夹](https://github.com/ziglang/zig/tree/master/lib/std)中可用。访问这个文件夹，开始探索Zig模块。

另外，一个很好的选择是从其他大型Zig代码库中阅读代码，例如：

1. [Javascript运行时Bun](https://github.com/oven-sh/bun)
2. [游戏引擎Mach](https://github.com/hexops/mach)
3. [Zig中的LLama 2 LLM模型实现](https://github.com/cgbur/llama2.zig/tree/main)
4. [金融交易数据库`tigerbeetle`](https://github.com/tigerbeetle/tigerbeetle)
5. [命令行参数解析器`zig-clap`](https://github.com/Hejsil/zig-clap)
6. [UI框架`capy`](https://github.com/capy-ui/capy)
7. [Zig的语言协议实现，`zls`](https://github.com/zigtools/zls)
8. [事件循环库`libxev`](https://github.com/mitchellh/libxev)

所有这些资产都在GitHub上可用，这很好，因为我们可以利用GitHub搜索栏来找到符合我们描述的Zig代码。例如，当你搜索特定模式时，你总是可以在GitHub搜索栏中包含`lang:Zig`。这将搜索限制为仅Zig模块。

另外，一个很好的选择是咨询在线资源和文档。这里是我个人不时使用的资源的快速列表，以每天了解更多关于语言的信息：

* Zig语言参考：[https://ziglang.org/documentation/master/](https://ziglang.org/documentation/master/)；
* Zig标准库参考：[https://ziglang.org/documentation/master/std/](https://ziglang.org/documentation/master/std/)；
* Zig指南：[https://zig.guide/](https://zig.guide/)；
* Karl Seguin博客：[https://www.openmymind.net/](https://www.openmymind.net/)；
* Zig新闻：[https://zig.news/](https://zig.news/)；
* 阅读Zig核心团队成员之一编写的代码：[https://github.com/kubkon](https://github.com/kubkon)；
* 一些实时编码会话在Zig Showtime Youtube频道传输：[https://www.youtube.com/@ZigSHOWTIME/videos](https://www.youtube.com/@ZigSHOWTIME/videos)；

学习Zig，或者说实话，学习任何你想要的语言的另一个很好的策略是通过解决练习来练习它。例如，在Zig社区中有一个著名的仓库叫做[Ziglings](https://ziglings.org/)，其中包含100多个你可以解决的小练习。这是一个用Zig编写的当前损坏的小程序的仓库，你的责任是修复这些程序，让它们再次工作。

一位著名的技术YouTuber被称为_The Primeagen_也发布了一些视频（在YouTube上），他在其中解决Ziglings的这些练习。第一个视频名为["Trying Zig Part 1"](https://www.youtube.com/watch?v=OPuztQfM3Fg&t=2524s&ab_channel=TheVimeagen)。

另一个很好的选择是解决[Advent of Code练习](https://adventofcode.com/)。有些人已经花时间学习和解决练习，他们也在GitHub上发布了他们的解决方案，所以，如果你在解决练习时需要一些资源进行比较，你可以查看这两个仓库：

* [https://github.com/SpexGuy/Zig-AoC-Template](https://github.com/SpexGuy/Zig-AoC-Template)；
* [https://github.com/fjebaker/advent-of-code-2022](https://github.com/fjebaker/advent-of-code-2022)；

## 在Zig中创建新对象（即标识符）

让我们更多地讨论Zig中的对象。有其他编程语言经验的读者可能通过不同的名称了解这个概念，例如："变量"或"标识符"。在本书中，我选择使用术语"对象"来指代这个概念。

要在Zig中创建一个新对象（或一个新的"标识符"），我们使用关键字`const`或`var`。这些关键字指定你正在创建的对象是否可变。如果你使用`const`，那么你正在创建的对象是一个常量（或不可变）对象，这意味着一旦你声明了这个对象，你就不能再改变存储在这个对象内的值。

另一方面，如果你使用`var`，那么，你正在创建一个变量（或可变）对象。你可以随意改变这个对象的值多少次。在Zig中使用关键字`var`类似于在Rust中使用关键字`let mut`。

### 常量对象与变量对象

在下面的代码示例中，我们正在创建一个名为`age`的新常量对象。这个对象存储一个代表某人年龄的数字。然而，这个代码示例无法成功编译。因为在下一行代码中，我们试图将对象`age`的值更改为25。

`zig`编译器检测到我们试图更改一个常量对象/标识符的值，因此，编译器将引发编译错误，警告我们这个错误。

```zig
const age = 24;
// 下面的行无效！
age = 25;
```

```
t.zig:10:5: error: cannot assign to constant
    age = 25;
      ~~^~~
```

所以，如果你想改变你的对象的值，你需要将你的不可变（或"常量"）对象转换为可变（或"变量"）对象。你可以通过使用`var`关键字来做到这一点。这个关键字代表"变量"，当你将这个关键字应用于某个对象时，你告诉Zig编译器与这个对象关联的值可能在某个时候改变。

因此，如果我们回到前面的例子，并更改`age`对象的声明以使用`var`关键字，那么，程序成功编译。因为现在，`zig`编译器检测到我们正在更改一个允许这种行为的对象的值，因为它是一个"变量对象"。

然而，如果你看下面的例子，你会注意到我们不仅用`var`关键字声明了`age`对象，而且这次我们还用`u8`类型明确注释了`age`对象的数据类型。基本思想是，当我们使用变量/可变对象时，Zig编译器要求我们更明确我们想要什么，更清楚我们的代码做什么。这转化为更明确我们想在对象中使用的数据类型。

因此，如果你将对象转换为变量/可变对象，只需记住始终在代码中明确注释对象的类型。否则，Zig编译器可能会引发编译错误，要求你将对象转换回`const`对象，或者给你的对象一个"明确类型"。

```zig
var age: u8 = 24;
age = 25;
```

### 声明而不带初始值

默认情况下，当你在Zig中声明一个新对象时，你必须给它一个初始值。换句话说，这意味着我们必须在源代码中声明并同时初始化我们创建的每个对象。

另一方面，事实上，你可以在源代码中声明一个新对象，而不给它一个明确的值。但我们需要为此使用一个特殊的关键字，即`undefined`关键字。

重要的是要强调，你应该尽可能避免使用`undefined`。因为当你使用这个关键字时，你让你的对象未初始化，因此，如果由于某种原因，你的代码在未初始化时使用这个对象，那么，你肯定会有未定义的行为和程序中的主要错误。

在下面的例子中，我再次声明`age`对象。但这次，我没有给它一个初始值。变量仅在第二行代码中初始化，我在这个对象中存储数字25。

```zig
var age: u8 = undefined;
age = 25;
```

记住这些要点，只需记住你应该尽可能避免在代码中使用`undefined`。始终声明并初始化你的对象。因为这给你的程序带来更多的安全性。但如果你真的需要声明一个对象而不初始化它……`undefined`关键字是在Zig中做到这一点的方法。

### 没有未使用的对象这回事

你在Zig中声明的每个对象（无论是常量还是变量）**必须以某种方式使用**。你可以将这个对象作为函数参数给函数调用，或者，你可以在另一个表达式中使用它来计算另一个对象的值，或者，你可以调用属于这个特定对象的方法。

不管你以哪种方式使用它。只要你使用它。如果你试图打破这个规则，即，如果你试图声明一个对象，但不使用它，`zig`编译器将不会编译你的Zig源代码，它会发出一个错误消息，警告你的代码中有未使用的对象。

让我们用一个例子来演示这一点。在下面的源代码中，我们声明了一个名为`age`的常量对象。如果你尝试用下面这行代码编译一个简单的Zig程序，编译器将返回如下所示的错误：

`const age = 15;`

```
t.zig:4:11: error: unused local constant
    const age = 15;
          ^~~
```

每次你在Zig中声明一个新对象时，你有两个选择：

1. 你要么使用这个对象的值；
2. 或者你明确丢弃对象的值；

要明确丢弃任何对象（常量或变量）的值，你需要做的就是将这个对象分配给Zig中的一个特殊字符，即下划线（`_`）。当你将一个对象分配给下划线时，如下面的例子中，`zig`编译器将自动丢弃这个特定对象的值。

你可以在下面的例子中看到，这次，编译器没有抱怨任何"未使用的常量"，并成功编译了我们的源代码。

```zig
// 它编译了！
const age = 15;
_ = age;
```

现在，记住，每次你将特定对象分配给下划线时，这个对象本质上被销毁了。它被编译器丢弃了。这意味着你不能再在代码中使用这个对象。它不再存在了。

所以如果你在我们丢弃它之后尝试使用下面例子中的常量`age`，你将从编译器得到一个响亮的错误消息（谈论"无意义的丢弃"）警告你这个错误。

```zig
// 它不编译。
const age = 15;
_ = age;
// 使用丢弃的值！
std.debug.print("{d}\n", .{age + 2});
```

```
t.zig:7:5: error: pointless discard
    of local constant
```

这个相同的规则适用于变量对象。每个变量对象也必须以某种方式使用。如果你将变量对象分配给下划线，这个对象也会被丢弃，你不能再使用这个对象。

### 你必须改变每个变量对象

你在源代码中创建的每个变量对象必须在某个时候被改变。换句话说，如果你将对象声明为变量对象，使用关键字`var`，并且你在未来某个时候不改变这个对象的值，`zig`编译器将检测到这一点，它将引发一个错误警告你这个错误。

这背后的概念是，你在Zig中创建的每个对象最好应该是一个常量对象，除非你真的需要一个在程序执行期间值会改变的对象。

所以，如果我尝试声明一个变量对象，如下面的`where_i_live`，并且我不以某种方式改变这个对象的值，`zig`编译器会引发一个错误消息，其中包含短语"变量从未被改变"。

```zig
var where_i_live = "Belo Horizonte";
_ = where_i_live;
```

```
t.zig:7:5: error: local variable is never mutated
t.zig:7:5: note: consider using 'const'
```

## 原始数据类型

Zig有许多不同的原始数据类型供你使用。你可以在官方[语言参考页面](https://ziglang.org/documentation/master/#Primitive-Types)上看到可用数据类型的完整列表。

但这里是一个快速列表：

* 无符号整数：`u8`，8位整数；`u16`，16位整数；`u32`，32位整数；`u64`，64位整数；`u128`，128位整数。
* 有符号整数：`i8`，8位整数；`i16`，16位整数；`i32`，32位整数；`i64`，64位整数；`i128`，128位整数。
* 浮点数：`f16`，16位浮点；`f32`，32位浮点；`f64`，64位浮点；`f128`，128位浮点；
* 布尔值：`bool`，表示true或false值。
* C ABI兼容类型：`c_long`、`c_char`、`c_short`、`c_ushort`、`c_int`、`c_uint`等许多其他。
* 指针大小的整数：`isize`和`usize`。

## 数组

你在Zig中通过使用类似C语法的语法创建数组。首先，你在一对括号内指定你想要创建的数组的大小（即将存储在数组中的元素数量）。

然后，你指定将存储在此数组中的元素的数据类型。Zig中数组中存在的所有元素必须具有相同的数据类型。例如，你不能在同一个数组中混合`f32`类型的元素和`i32`类型的元素。

之后，你只需在一对花括号内列出你想存储在这个数组中的值。在下面的例子中，我正在创建两个包含不同数组的常量对象。第一个对象包含4个整数值的数组，而第二个对象包含3个浮点值的数组。

现在，你应该注意到在对象`ls`中，我没有在括号内明确指定数组的大小。我使用特殊字符下划线（`_`）而不是使用文字值（如我在`ns`对象中使用的值4）。这个语法告诉`zig`编译器用花括号内列出的元素数量填充这个字段。所以，这个语法`[_]`是为懒惰（或聪明）的程序员准备的，他们把计算花括号中有多少元素的工作留给编译器。

```zig
const ns = [4]u8{48, 24, 12, 6};
const ls = [_]f64{432.1, 87.2, 900.05};
_ = ns; _ = ls;
```

值得注意的是，这些是静态数组，意味着它们不能增长大小。一旦你声明了你的数组，你就不能改变它的大小。这在低级语言中非常常见。因为低级语言通常想给你（程序员）对内存的完全控制，数组扩展的方式与内存管理紧密相关。

### 选择数组的元素

一个非常常见的活动是从你的源代码中的数组中选择特定部分。在Zig中，你可以通过在对象名称后的括号内提供这个特定元素的索引来从数组中选择特定元素。在下面的例子中，我从`ns`数组中选择第三个元素。注意Zig是一种"零索引"的语言，像C、C++、Rust、Python和许多其他语言一样。

```zig
const ns = [4]u8{48, 24, 12, 6};
try stdout.print("{d}\n", .{ ns[2] });
try stdout.flush();
```

`12`

相反，你也可以通过使用范围选择器来选择数组的特定切片（或部分）。一些程序员也称这些选择器为"切片选择器"，它们也存在于Rust中，并且具有与Zig中完全相同的语法。无论如何，范围选择器是Zig中定义索引范围的特殊表达式，它具有语法`start..end`。

在下面的例子中，在第二行代码中，`sl`对象存储`ns`数组的切片（或部分）。更准确地说，是`ns`数组中索引1和2的元素。

```zig
const ns = [4]u8{48, 24, 12, 6};
const sl = ns[1..3];
_ = sl;
```

当你使用`start..end`语法时，范围选择器的"结束尾部"是非包含的，意味着，结束处的索引不包含在从数组中选择的范围中。因此，语法`start..end`实际上在实践中意味着`start..end - 1`。

例如，你可以通过使用`ar[0..ar.len]`语法创建一个从数组的第一个到最后一个元素的切片。换句话说，它是一个访问数组中所有元素的切片。

```zig
const ar = [4]u8{48, 24, 12, 6};
const sl = ar[0..ar.len];
_ = sl;
```

你也可以在范围选择器中使用语法`start..`。这告诉`zig`编译器选择从`start`索引开始直到数组最后一个元素的数组部分。在下面的例子中，我们选择从索引1到数组末尾的范围。

```zig
const ns = [4]u8{48, 24, 12, 6};
const sl = ns[1..];
_ = sl;
```

### 更多关于切片

正如我们之前讨论的，在Zig中，你可以选择现有数组的特定部分。这在Zig中称为**切片**（[Sobeston 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-zigguide)），因为当你选择数组的一部分时，你从该数组创建了一个切片对象。

切片对象本质上是一个指针对象，伴随着一个长度数字。指针对象指向切片中的第一个元素，长度数字告诉`zig`编译器这个切片中有多少元素。

> 切片可以被认为是`[*]T`（指向数据的指针）和`usize`（元素计数）的配对（[Sobeston 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-zigguide)）。

通过切片内包含的指针，你可以访问你从原始数组中选择的这个范围（或部分）内的元素（或值）。但长度数字（你可以通过切片对象的`len`属性访问）是Zig在这里带来的真正大改进（例如相对于C数组）。

因为有了这个长度数字，`zig`编译器可以轻松检查你是否试图访问超出这个特定切片边界的索引，或者，你是否导致任何缓冲区溢出问题。在下面的例子中，我们访问切片`sl`的`len`属性，它告诉我们这个切片中有2个元素。

```zig
const ns = [4]u8{48, 24, 12, 6};
const sl = ns[1..3];
try stdout.print("{d}\n", .{sl.len});
try stdout.flush();
```

`2`

### 数组操作符

Zig中有两个非常有用的数组操作符。数组连接操作符（`++`），和数组乘法操作符（`**`）。顾名思义，这些是数组操作符。

关于这两个操作符的一个重要细节是，它们仅在两个操作数都有编译时已知的大小（或"长度"）时才起作用。我们将在[第3.1.1节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-compile-time)中更多地讨论"编译时已知"和"运行时已知"之间的差异。但现在，记住这个信息，你不能在每种情况下使用这些操作符。

总之，`++`操作符创建一个新数组，它是作为操作数提供的两个数组的连接。所以，表达式`a ++ b`产生一个包含数组`a`和`b`中所有元素的新数组。

```zig
const a = [_]u8{1,2,3};
const b = [_]u8{4,5};
const c = a ++ b;
try stdout.print("{any}\n", .{c});
try stdout.flush();
```

`{ 1, 2, 3, 4, 5 }`

这个`++`操作符特别适用于将字符串连接在一起。Zig中的字符串在[第1.8节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-zig-strings)中有深入描述。总之，Zig中的字符串对象本质上是字节数组。所以，你可以使用这个数组连接操作符来有效地将字符串连接在一起。

相反，`**`操作符用于多次复制数组。换句话说，表达式`a ** 3`创建一个包含数组`a`的元素重复3次的新数组。

```zig
const a = [_]u8{1,2,3};
const c = a ** 2;
try stdout.print("{any}\n", .{c});
try stdout.flush();
```

`{ 1, 2, 3, 1, 2, 3 }`

### 切片中的运行时与编译时已知长度

我们将在本书中大量讨论编译时已知和运行时已知之间的差异，特别是在[第3.1.1节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-compile-time)。但基本思想是，当我们在编译时知道关于这个东西的一切（值、属性和特征）时，一个东西是编译时已知的。相反，运行时已知的东西是当一个东西的确切值仅在运行时计算时。因此，我们在编译时不知道这个东西的值，只在运行时。

我们在[第1.6.1节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-select-array-elem)中了解到，切片是通过使用**范围选择器**创建的，它代表一个索引范围。当这个"索引范围"（即这个范围的开始和结束）在编译时已知时，创建的切片对象实际上，在底层，只是一个指向数组的单项指针。

你现在不需要准确理解这意味着什么。我们将在[第6章](https://pedropark99.github.io/zig-book/Chapters/05-pointers.html)中大量讨论指针。现在，只需理解，当索引范围在编译时已知时，创建的切片只是一个指向数组的指针，伴随着一个告诉切片大小的长度值。

如果你有这样的切片对象，即具有编译时已知范围的切片，你可以对这个切片对象使用常见的指针操作。例如，你可以通过使用`.*`方法取消引用这个切片的指针，就像你对普通指针对象所做的那样。

```zig
const arr1 = [10]u64 {
    1, 2, 3, 4, 5,
    6, 7, 8, 9, 10
};
// 这个切片有一个编译时已知的范围。
// 因为我们知道范围的开始和结束。
const slice = arr1[1..4];
_ = slice;
```

另一方面，如果索引范围在编译时不已知，那么，创建的切片对象不再是指针，因此，它不支持指针操作。例如，也许开始索引在编译时已知，但结束索引不是。在这种情况下，切片的范围仅在运行时已知。

在下面的例子中，我们正在读取一个文件，然后，我们尝试创建一个覆盖包含此文件内容的整个缓冲区的切片对象。这显然是一个运行时已知范围的例子，因为范围的结束索引在编译时不已知。

换句话说，范围的结束索引是数组`file_contents`的大小。然而，`file_contents`的大小在编译时不已知。因为我们不知道这个`shop-list.txt`文件中存储了多少字节。而且因为这是一个文件，有人可能明天编辑这个文件并添加更多行或从中删除行。因此，这个文件的大小可能从一次执行到另一次执行急剧变化。

现在，如果文件大小可以从一次运行到另一次运行变化，那么，我们可以得出结论，下面例子中暴露的表达式`file_contents.len`的值也可以从一次运行到另一次运行变化。因此，表达式`file_contents.len`的值仅在运行时已知，因此，范围`0..file_contents.len`也仅在运行时已知。

```zig
const std = @import("std");
const builtin = @import("builtin");

fn read_file(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    var reader_buffer: [1024]u8 = undefined;
    var file_buffer = try allocator.alloc(u8, 1024);
    @memset(file_buffer[0..], 0);

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var reader = file.reader(reader_buffer[0..]);
    const nbytes = try reader.read(
        file_buffer[0..]
    );
    return file_buffer[0..nbytes];
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    const path = "../ZigExamples/file-io/shop-list.txt";
    const file_contents = try read_file(allocator, path);
    const slice = file_contents[0..file_contents.len];
    _ = slice;
}
```

## 块和作用域

块在Zig中由一对花括号创建。块只是包含在一对花括号内的一组表达式（或语句）。包含在这对花括号内的所有这些表达式属于同一个作用域。

换句话说，块只是在你的代码中界定一个作用域。你在同一块内定义的对象属于同一个作用域，因此，可以从该作用域内访问。同时，这些对象在该作用域之外不可访问。所以，你也可以说块用于限制你在源代码中创建的对象的作用域。用不太技术性的术语，块用于指定你可以在源代码中的什么地方访问你在源代码中拥有的任何对象。

所以，块只是包含在一对花括号内的一组表达式。每个块都有自己的作用域，与其他块分开。函数的主体是块的经典例子。if语句、for和while循环（以及语言中使用一对花括号的任何其他结构）也是块的例子。

这意味着，你在源代码中创建的每个if语句或for循环等都有自己的独立作用域。这就是为什么你不能在外部作用域中访问你在for循环（或if语句）内定义的对象，即for循环之外的作用域。因为你试图访问属于与你当前作用域不同的作用域的对象。

你可以在块内创建块，具有多个嵌套级别。你也可以（如果你想）用冒号字符（`:`）给特定块一个标签。只需在打开界定块的花括号之前写`label:`。当你在Zig中标记一个块时，你可以使用`break`关键字从这个块返回一个值，就像它是一个函数的主体一样。你只需写`break`关键字，后跟格式`:label`中的块标签，以及定义你想要返回的值的表达式。

就像下面的例子，我们从块`add_one`返回`y`对象的值，并将结果保存在`x`对象内。

```zig
var y: i32 = 123;
const x = add_one: {
    y += 1;
    break :add_one y;
};
if (x == 124 and y == 124) {
    try stdout.print("Hey!", .{});
    try stdout.flush();
}
```

`Hey!`

## Zig中的字符串如何工作？

我们将在本书中构建和讨论的第一个项目是base64编码器/解码器（[第4章](https://pedropark99.github.io/zig-book/Chapters/01-base64.html)）。但为了我们构建这样的东西，我们需要更好地理解字符串在Zig中是如何工作的。所以让我们讨论Zig的这个特定方面。

Zig中的字符串工作方式与C中的字符串非常相似，但它们带有一些额外的注意事项，为它们增加了更多的安全性和效率。你也可以说Zig简单地使用了一种更现代和安全的方法来管理和使用字符串。

Zig中的字符串本质上是任意字节的数组，或者，更具体地说，是`u8`值的数组。这与C中的字符串非常相似，C中的字符串也被解释为任意字节的数组，或者，在C的情况下，是`char`（在大多数系统中通常代表无符号8位整数值）值的数组。

现在，因为Zig中的字符串是一个数组，你会自动获得嵌入在值本身中的字符串长度（即数组的长度）。这有很大的不同！因为现在，Zig编译器可以使用嵌入在字符串中的长度值来检查代码中的"缓冲区溢出"或"错误的内存访问"问题。

要在C中实现同样的安全性，你必须做很多看起来毫无意义的工作。所以在C中获得这种安全性不是自动的，而且要困难得多。例如，如果你想在C中跟踪你的字符串在整个程序中的长度，那么，你首先需要循环遍历代表这个字符串的字节数组，并找到null元素（`'\0'`）位置以发现数组确切结束的位置，或者，换句话说，找到字节数组包含多少元素。

要做到这一点，你需要在C中做这样的事情。在这个例子中，存储在对象`array`中的C字符串长度为25字节：

```c
#include <stdio.h>
int main() {
    char* array = "An example of string in C";
    int index = 0;
    while (1) {
        if (array[index] == '\0') {
            break;
        }
        index++;
    }
    printf("Number of elements in the array: %d\n", index);
}
```

`Number of elements in the array: 25`

你在Zig中没有这种工作。因为字符串的长度始终存在并可在字符串值本身中访问。你可以通过`len`属性轻松访问字符串的长度。例如，下面的`string_object`对象长度为43字节：

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const string_object = "This is an example of string literal in Zig";
    try stdout.print("{d}\n", .{string_object.len});
    try stdout.flush();
}
```

`43`

另一点是Zig总是假设你的字符串中的字节序列是UTF-8编码的。这可能不是你正在处理的每个字节序列都是真的，但这真的不是Zig的工作来修复你的字符串的编码（你可以为此使用[`iconv`](https://www.gnu.org/software/libiconv/)）。今天，我们现代世界中的大部分文本，特别是在网络上，应该是UTF-8编码的。所以如果你的字符串文字不是UTF-8编码的，那么，你可能会在Zig中遇到问题。

让我们以单词"Hello"为例。在UTF-8中，这个字符序列（H、e、l、l、o）由十进制数字序列72、101、108、108、111表示。在十六进制中，这个序列是`0x48`、`0x65`、`0x6C`、`0x6C`、`0x6F`。所以如果我取这个十六进制值序列，并要求Zig将这个字节序列打印为字符序列（即字符串），那么，文本"Hello"将被打印到终端：

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const bytes = [_]u8{0x48, 0x65, 0x6C, 0x6C, 0x6F};
    try stdout.print("{s}\n", .{bytes});
    try stdout.flush();
}
```

`Hello`

### 使用切片与哨兵终止数组

在内存中，Zig中的所有字符串值总是以相同的方式存储。它们只是作为任意字节的序列/数组存储。但你可以以两种不同的方式使用和访问这个字节序列。你可以将这个字节序列访问为：

* `u8`值的哨兵终止数组。
* 或作为`u8`值的切片。

#### 哨兵终止数组

Zig中的哨兵终止数组在Zig的语言参考中有描述。总之，哨兵终止数组只是一个普通数组，但区别在于它们在数组的最后一个索引/元素处包含一个"哨兵值"。使用哨兵终止数组，你将数组的长度和哨兵值都嵌入到对象的类型本身中。

例如，如果你在代码中写一个字符串文字值，并要求Zig打印这个值的数据类型，你通常会得到格式为`*const [n:0]u8`的数据类型。数据类型中的`n`表示字符串的大小（即数组的长度）。`n:`部分后的零是哨兵值本身。

```zig
// 这是一个字符串文字值：
_ = "A literal value";
try stdout.print("{any}\n", .{@TypeOf("A literal value")});
try stdout.flush();
```

`*const [15:0]u8`

所以，使用这个数据类型`*const [n:0]u8`，你本质上是在说你有一个长度为`n`的`u8`值数组，其中，数组中对应于长度`n`的索引处的元素是数字零。如果你真的思考这个描述，你会注意到这只是描述C中字符串的一种花哨方式，C中的字符串是以null终止的字节数组。C中的`NULL`值是数字零。所以，C中以null/零值结尾的数组本质上是Zig中的哨兵终止数组，其中数组的哨兵值是数字零。

因此，Zig中的字符串文字值只是指向以null终止的字节数组的指针（即类似于C字符串）。但在Zig中，字符串文字值还将字符串的长度以及它们是"NULL终止"的事实嵌入到值本身的数据类型中。

#### 切片

你也可以将代表你的字符串的任意字节序列作为`u8`值的切片访问和使用。Zig标准库中的大多数函数通常接收字符串作为`u8`值切片的输入（切片在[第1.6节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-arrays)中介绍）。

因此，你会看到很多数据类型为`[]u8`或`[]const u8`的字符串值，这取决于存储此字符串的对象是用`const`标记为常量，还是用`var`标记为变量。现在，因为在这种情况下字符串被解释为切片，这个切片不一定是以null终止的，因为现在，哨兵值不是强制性的。如果你想，你可以在切片中包含null/零值，但没有必要这样做。

```zig
// 这是一个字符串值被
// 解释为切片。
const str: []const u8 = "A string value";
try stdout.print("{any}\n", .{@TypeOf(str)});
try stdout.flush();
```

`[]const u8`

### 遍历字符串

如果你想查看在Zig中表示字符串的实际字节，你可以使用`for`循环遍历字符串中的每个字节，并要求Zig将每个字节作为十六进制值打印到终端。你可以通过使用带有`X`格式说明符的`print()`语句来做到这一点，就像你通常在C中使用[`printf()`函数](https://cplusplus.com/reference/cstdio/printf/)一样。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const string_object = "This is an example";
    try stdout.print("Bytes that represents the string object: ", .{});
    for (string_object) |byte| {
        try stdout.print("{X} ", .{byte});
    }
    try stdout.print("\n", .{});
    try stdout.flush();
}
```

```
Bytes that represents the string object: 54 68 69
   73 20 69 73 20 61 6E 20 65 78 61 6D 70 6C 65
```

### 更好地查看对象类型

现在，我们可以更好地检查Zig创建的对象的类型。要检查Zig中任何对象的类型，你可以使用`@TypeOf()`函数。如果我们查看下面`simple_array`对象的类型，你会发现这个对象是一个包含4个元素的数组。每个元素是一个32位的有符号整数，对应于Zig中的数据类型`i32`。这就是类型`[4]i32`的对象。

但如果我们仔细查看下面暴露的字符串文字值的类型，你会发现这个对象是一个常量指针（因此有`*const`注释）指向一个包含16个元素（或16字节）的数组。每个元素是一个字节（更准确地说，是一个无符号8位整数 - `u8`），这就是为什么我们有下面类型的`[16:0]u8`部分，而且，你可以看到这是一个以null终止的数组，因为数据类型中`:`字符后的零值。换句话说，下面暴露的字符串文字值长度为16字节。

现在，如果我们创建一个指向`simple_array`对象的指针，那么，我们得到一个指向4个元素数组的常量指针（`*const [4]i32`），这与字符串文字值的类型非常相似。这表明Zig中的字符串文字值已经是指向以null终止的字节数组的指针。

此外，如果我们查看`string_obj`对象的类型，你会看到它是一个切片对象（因此有类型的`[]`部分）到一系列常量`u8`值（因此有类型的`const u8`部分）。

```zig
const std = @import("std");
pub fn main() !void {
    const simple_array = [_]i32{1, 2, 3, 4};
    const string_obj: []const u8 = "A string object";
    std.debug.print(
        "Type 1: {}\n", .{@TypeOf(simple_array)}
    );
    std.debug.print(
        "Type 2: {}\n", .{@TypeOf("A string literal")}
    );
    std.debug.print(
        "Type 3: {}\n", .{@TypeOf(&simple_array)}
    );
    std.debug.print(
        "Type 4: {}\n", .{@TypeOf(string_obj)}
    );
}
```

```
Type 1: [4]i32
Type 2: *const [16:0]u8
Type 3: *const [4]i32
Type 4: []const u8
```

### 字节与unicode点

重要的是要指出，数组中的每个字节不一定是单个字符。这个事实源于单个字节和单个unicode点之间的差异。

UTF-8编码通过为字符串中的每个字符分配一个数字（称为unicode点）来工作。例

如，字符"H"在UTF-8中存储为十进制数字72。这意味着数字72是字符"H"的unicode点。每个可能出现在UTF-8编码字符串中的字符都有自己的unicode点。

例如，带笔画的拉丁大写字母A（Ⱥ）由数字（或unicode点）570表示。然而，这个十进制数字（570）高于可以存储在单个字节中的最大数字，即255。换句话说，可以用单个字节表示的最大十进制数字是255。这就是为什么，unicode点570实际上在计算机内存中存储为字节`C8 BA`。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const string_object = "Ⱥ";
    _ = try stdout.write(
        "Bytes that represents the string object: "
    );
    for (string_object) |char| {
        try stdout.print("{X} ", .{char});
    }
    try stdout.flush();
}
```

`Bytes that represents the string object: C8 BA`

这意味着要在UTF-8编码的字符串中存储字符Ⱥ，我们需要使用两个字节一起来表示数字570。这就是为什么字节和unicode点之间的关系并不总是1比1的。每个unicode点是字符串中的单个字符，但并不总是单个字节对应于单个unicode点。

所有这些意味着，如果你循环遍历Zig中字符串的元素，你将循环遍历表示该字符串的字节，而不是遍历该字符串的字符。在上面的Ⱥ例子中，for循环需要两次迭代（而不是单次迭代）来打印表示这个Ⱥ字母的两个字节。

现在，所有英文字母（或者如果你愿意的话，ASCII字母）都可以在UTF-8中用单个字节表示。因此，如果你的UTF-8字符串只包含英文字母（或ASCII字母），那么，你很幸运。因为字节数将等于该字符串中的字符数。换句话说，在这种特定情况下，字节和unicode点之间的关系是1比1的。

但另一方面，如果你的字符串包含其他类型的字母……例如，你可能正在处理包含中文、日文或拉丁字母的文本数据，那么，表示你的UTF-8字符串所需的字节数很可能远高于该字符串中的字符数。

如果你需要遍历字符串的字符，而不是它的字节，那么，你可以使用`std.unicode.Utf8View`结构来创建一个遍历字符串的unicode点的迭代器。

在下面的例子中，我们循环遍历日文字符"アメリカ"。这个字符串中的四个字符中的每一个都由三个字节表示。但for循环迭代四次，这个字符串中的每个字符/unicode点一次迭代：

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    var utf8 = try std.unicode.Utf8View.init("アメリカ");
    var iterator = utf8.iterator();
    while (iterator.nextCodepointSlice()) |codepoint| {
        try stdout.print(
            "got codepoint {x}\n",
            .{codepoint},
        );
    }

    try stdout.flush();
}
```

```
got codepoint e382a2
got codepoint e383a1
got codepoint e383aa
got codepoint e382ab
```

### 一些对字符串有用的函数

在本节中，我只想快速描述Zig标准库中一些在处理字符串时非常有用的函数。最值得注意的是：

* `std.mem.eql()`：比较两个字符串是否相等。
* `std.mem.splitScalar()`：根据分隔符值将字符串分割成子字符串数组。
* `std.mem.splitSequence()`：根据子字符串分隔符将字符串分割成子字符串数组。
* `std.mem.startsWith()`：检查字符串是否以子字符串开头。
* `std.mem.endsWith()`：检查字符串是否以子字符串结尾。
* `std.mem.trim()`：从字符串的开头和结尾删除特定值。
* `std.mem.concat()`：将字符串连接在一起。
* `std.mem.count()`：计算字符串中子字符串的出现次数。
* `std.mem.replace()`：替换字符串中子字符串的出现。

注意所有这些函数都来自Zig标准库的`mem`模块。这个模块包含多个对处理内存和一般字节序列有用的函数和方法。

`eql()`函数用于检查两个数据数组是否相等。由于字符串只是任意的字节数组，我们可以使用这个函数来比较两个字符串。这个函数返回一个布尔值，指示两个字符串是否相等。这个函数的第一个参数是正在比较的数组的元素的数据类型。

```zig
const name: []const u8 = "Pedro";
try stdout.print(
    "{any}\n", .{std.mem.eql(u8, name, "Pedro")}
);
try stdout.flush();
```

`true`

`splitScalar()`和`splitSequence()`函数用于将字符串分割成多个片段，就像Python字符串的`split()`方法一样。这两种方法之间的区别是`splitScalar()`使用单个字符作为分隔符来分割字符串，而`splitSequence()`使用字符序列（也就是子字符串）作为分隔符。本书后面有这些函数的实际例子。

`startsWith()`和`endsWith()`函数非常直接。它们返回一个布尔值，指示字符串（或者更准确地说，数据数组）是否以提供的序列开始（`startsWith`）或结束（`endsWith`）。

```zig
const name: []const u8 = "Pedro";
try stdout.print(
    "{any}\n", .{std.mem.startsWith(u8, name, "Pe")}
);
try stdout.flush();
```

`true`

`concat()`函数，顾名思义，将两个或多个字符串连接在一起。因为连接字符串的过程涉及分配足够的空间来容纳所有字符串，这个`concat()`函数接收一个分配器对象作为输入。

```zig
const str1 = "Hello";
const str2 = " you!";
const str3 = try std.mem.concat(
    allocator, u8, &[_][]const u8{ str1, str2 }
);
try stdout.print("{s}\n", .{str3});
try stdout.flush();
```

正如你可以想象的，`replace()`函数用于用另一个子字符串替换字符串中的子字符串。这个函数的工作方式与Python字符串的`replace()`方法非常相似。因此，你提供一个要搜索的子字符串，每次`replace()`函数在输入字符串中找到这个子字符串时，它都会用你作为输入提供的"替换子字符串"替换这个子字符串。

在下面的例子中，我们取输入字符串"Hello"，并用"34"替换这个输入字符串中所有出现的子字符串"el"，并将结果保存在`buffer`对象中。结果，`replace()`函数返回一个`usize`值，指示执行了多少次替换。

```zig
const str1 = "Hello";
var buffer: [5]u8 = undefined;
const nrep = std.mem.replace(
    u8, str1, "el", "34", buffer[0..]
);
try stdout.print("New string: {s}\n", .{buffer});
try stdout.print("N of replacements: {d}\n", .{nrep});
try stdout.flush();
```

```
New string: H34lo
N of replacements: 1
```

## Zig中的安全性

现代低级编程语言的一个普遍趋势是安全性。随着我们的现代世界与技术和计算机的联系越来越紧密，所有这些技术产生的数据成为我们拥有的最重要（也是最危险）的资产之一。

这可能是现代低级编程语言一直非常关注安全性，特别是内存安全性的主要原因，因为内存损坏仍然是黑客利用的主要目标。现实是我们没有一个简单的解决方案来解决这个问题。目前，我们只有缓解这些问题的技术和策略。

正如Richard Feldman在他[最近的GOTO会议演讲](https://www.youtube.com/watch?v=jIZpKpLCOiU&ab_channel=GOTOConferences)中解释的那样，我们还没有找到在技术中实现**真正安全**的方法。换句话说，我们还没有找到一种方法来构建100%确定不会被利用的软件。我们可以通过确保内存安全等方式大大降低软件被利用的风险。但这还不足以达到"真正安全"的领域。

因为即使你用"安全语言"编写程序，黑客仍然可以利用运行程序的操作系统中的故障（例如，也许运行你代码的系统有一个"后门漏洞"，仍然可以以意想不到的方式影响你的代码），或者，他们也可以利用计算机架构的功能。最近发现的涉及通过ARM芯片中存在的"内存标签"功能进行内存无效化的漏洞就是一个例子（[Kim et al. 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-exploit1)）。

问题是：Zig和其他语言一直在做什么来缓解这个问题？如果我们以Rust为例，Rust在大多数情况下是一种通过对开发人员强制执行特定规则的内存安全语言。换句话说，Rust的关键功能**借用检查器**，强制你在编写Rust代码时遵循特定的逻辑，每当你试图偏离这种模式时，Rust编译器总是会抱怨。

相比之下，Zig语言默认不是内存安全语言。你在Zig中免费获得一些内存安全功能，特别是在数组和指针对象中。但语言提供的其他工具默认不使用。换句话说，`zig`编译器不强制你使用这些工具。

下面列出的工具与内存安全有关。也就是说，它们帮助你在Zig代码中实现内存安全：

* `defer`允许你将释放操作物理上保持在分配附近。这有助于你避免内存泄漏、"释放后使用"和"双重释放"问题。此外，它还在逻辑上将释放操作绑定到当前作用域的末尾，这大大减少了关于对象生命周期的心理负担。
* `errdefer`帮助你保证即使发生运行时错误，你的程序也会释放分配的内存。
* 指针和对象默认不可为空。这有助于你避免可能由于取消引用空指针而产生的内存问题。
* Zig提供了一些可以检测内存泄漏和双重释放的原生类型的分配器（称为"测试分配器"）。这些类型的分配器广泛用于单元测试，因此它们将你的单元测试转变为可以用来检测代码中内存问题的武器。
* Zig中的数组和切片在对象本身中嵌入了它们的长度，这使得`zig`编译器在检测"索引超出范围"类型的错误和避免缓冲区溢出方面非常有效。

尽管Zig提供了这些与内存安全问题相关的功能，该语言还有一些规则，帮助你实现另一种类型的安全性，这更多地与程序逻辑安全有关。这些规则是：

* 指针和对象默认不可为空。这消除了可能破坏程序逻辑的边缘情况。
* switch语句必须穷尽所有可能的选项。
* `zig`编译器强制你处理程序中的每个可能的错误。

## Zig的其他部分

我们已经学到了很多关于Zig语法的知识，以及一些关于它的相当技术性的细节。作为快速回顾：

* 我们在[第1.2.2节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-root-file)和[第1.2.3节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-main-file)中讨论了如何在Zig中编写函数。
* 如何在[第1.2.2节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-root-file)，特别是在[第1.4节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-assignments)中创建新对象/标识符。
* 字符串如何在Zig中工作在[第1.8节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-zig-strings)。
* 如何在[第1.6节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-arrays)中使用数组和切片。
* 如何在[第1.2.2节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-root-file)中从其他Zig模块导入功能。

但是，现在，这些知识量足以让我们继续本书。稍后，在接下来的章节中，我们仍将讨论Zig语法的其他同样重要的部分。例如：

* 如何在[第2.3节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-structs-and-oop)中通过_结构声明_在Zig中进行面向对象编程。
* 基本控制流语法在[第2.1节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-zig-control-flow)。
* 枚举在[第7.6节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-enum)；
* 指针和可选类型在[第6章](https://pedropark99.github.io/zig-book/Chapters/05-pointers.html)；
* 使用`try`和`catch`进行错误处理在[第10章](https://pedropark99.github.io/zig-book/Chapters/09-error-handling.html)；
* 单元测试在[第8章](https://pedropark99.github.io/zig-book/Chapters/03-unittests.html)；
* 向量在[第17章](https://pedropark99.github.io/zig-book/Chapters/15-vectors.html)；
* 构建系统在[第9章](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html)；

---

脚注翻译：

1. [https://ziglang.org/learn/overview/#zig-build-system](https://ziglang.org/learn/overview/#zig-build-system)
2. [https://zig.news/edyu/zig-package-manager-wtf-is-zon-558e](https://zig.news/edyu/zig-package-manager-wtf-is-zon-558e)
3. [https://medium.com/@edlyuu/zig-package-manager-2-wtf-is-build-zig-zon-and-build-zig-0-11-0-update-5bc46e830fc1](https://medium.com/@edlyuu/zig-package-manager-2-wtf-is-build-zig-zon-and-build-zig-0-11-0-update-5bc46e830fc1)
4. [https://github.com/ziglang/zig/blob/master/doc/build.zig.zon.md](https://github.com/ziglang/zig/blob/master/doc/build.zig.zon.md)
5. [https://en.wikipedia.org/wiki/List_of_C-family_programming_languages](https://en.wikipedia.org/wiki/List_of_C-family_programming_languages)
6. 你可以在[`return-integer.zig`](https://github.com/pedropark99/zig-book/blob/main/ZigExamples/zig-basics/return-integer.zig)文件中看到一个返回`u8`值的`main()`函数的例子
7. [https://github.com/ziglang/zig/issues/17186](https://github.com/ziglang/zig/issues/17186)
8. [https://github.com/ziglang/zig/issues/19864](https://github.com/ziglang/zig/issues/19864)
9. [https://github.com/ziglang/zig/tree/master/lib/std](https://github.com/ziglang/zig/tree/master/lib/std)
10. [https://github.com/oven-sh/bun](https://github.com/oven-sh/bun)
11. [https://github.com/hexops/mach](https://github.com/hexops/mach)
12. [https://github.com/cgbur/llama2.zig/tree/main](https://github.com/cgbur/llama2.zig/tree/main)
13. [https://github.com/tigerbeetle/tigerbeetle](https://github.com/tigerbeetle/tigerbeetle)
14. [https://github.com/Hejsil/zig-clap](https://github.com/Hejsil/zig-clap)
15. [https://github.com/capy-ui/capy](https://github.com/capy-ui/capy)
16. [https://github.com/zigtools/zls](https://github.com/zigtools/zls)
17. [https://github.com/mitchellh/libxev](https://github.com/mitchellh/libxev)
18. [https://ziglings.org](https://ziglings.org/)
19. [https://www.youtube.com/watch?v=OPuztQfM3Fg](https://www.youtube.com/watch?v=OPuztQfM3Fg)
20. [https://adventofcode.com/](https://adventofcode.com/)
21. [https://ziglang.org/documentation/master/#Primitive-Types](https://ziglang.org/documentation/master/#Primitive-Types)
22. [https://www.gnu.org/software/libiconv/](https://www.gnu.org/software/libiconv/)
23. [https://ziglang.org/documentation/master/#Sentinel-Terminated-Arrays](https://ziglang.org/documentation/master/#Sentinel-Terminated-Arrays)
24. [https://cplusplus.com/reference/cstdio/printf/](https://cplusplus.com/reference/cstdio/printf/)
25. [https://www.youtube.com/watch?v=jIZpKpLCOiU](https://www.youtube.com/watch?v=jIZpKpLCOiU)
26. 实际上，许多现有的Rust代码仍然是内存不安全的，因为它们通过FFI（**外部函数接口**）与外部库通信，这通过`unsafe`关键字禁用了借用检查器功能。
