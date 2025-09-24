# 第9章 构建系统 - Zig入门介绍

在本章中，我们将讨论构建系统，以及如何在Zig中构建整个项目。Zig的一个关键优势是它包含了一个内嵌在语言本身中的构建系统。这很棒，因为你不需要依赖一个独立于编译器的外部系统来构建你的代码。

你可以在Zig官方网站的[《构建系统》](https://ziglang.org/learn/build-system/#user-provided-options)文章中找到关于Zig构建系统的详细描述。我们还有[Felix撰写的优秀系列文章](https://zig.news/xq/zig-build-explained-part-1-59lf)。因此，本章为你提供了一个额外的咨询和参考资源。

构建代码是Zig最擅长的事情之一。在C/C++甚至Rust中特别困难的一件事是将源代码交叉编译到多个目标（例如多种计算机架构和操作系统），而`zig`编译器被公认为是处理这项特定任务的最佳现有软件之一。

## 源代码是如何构建的？

我们已经在[第1.2.1节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-project-files)中讨论了在低级语言中构建源代码的挑战。如该节所述，程序员发明了构建系统来克服在低级语言中构建源代码过程中的这些挑战。

低级语言使用编译器将你的源代码编译（或构建）成二进制指令。在C和C++中，我们通常使用像`gcc`、`g++`或`clang`这样的编译器来将C和C++源代码编译成这些指令。每种语言都有自己的编译器，Zig也不例外。

在Zig中，我们有`zig`编译器来将我们的Zig源代码编译成可以被计算机执行的二进制指令。在Zig中，编译（或构建）过程涉及以下组件：

* 包含你源代码的Zig模块；
* 库文件（动态库或静态库）；
* 根据你的需求定制构建过程的编译器标志。

这些是你需要连接在一起以在Zig中构建源代码的东西。在C和C++中，你会有一个额外的组件，即你正在使用的库的头文件。但Zig中不存在头文件，所以，只有当你将Zig源代码与C库链接时才需要关心它们。如果不是这种情况，你可以忽略它。

你的构建过程通常组织在一个构建脚本中。在Zig中，我们通常将这个构建脚本写入项目根目录中名为`build.zig`的Zig模块中。你编写这个构建脚本，然后，当你运行它时，你的项目就会被构建成可以使用并分发给用户的二进制文件。

这个构建脚本通常围绕**目标对象**组织。目标是要构建的东西，或者换句话说，它是你希望`zig`编译器为你构建的东西。"目标"这个概念存在于大多数构建系统中，特别是在CMake中。

在Zig中有四种类型的目标对象可以构建，它们是：

* 可执行文件（例如Windows上的`.exe`文件）。
* 共享库（例如Linux中的`.so`文件或Windows上的`.dll`文件）。
* 静态库（例如Linux中的`.a`文件或Windows上的`.lib`文件）。
* 仅执行单元测试的可执行文件（或"单元测试可执行文件"）。

我们将在[第9.3节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-targets)中更多地讨论这些目标对象。

## `build()`函数

Zig中的构建脚本始终包含一个声明的公共（顶级）`build()`函数。它就像我们在[第1.2.3节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-main-file)中讨论的项目主Zig模块中的`main()`函数。但这个`build()`函数不是创建代码的入口点，而是构建过程的入口点。

这个`build()`函数应该接受一个指向`Build`对象的指针作为输入，并应该使用这个"构建对象"来执行构建项目所需的步骤。此函数的返回类型始终是`void`，并且这个`Build`结构直接来自Zig标准库（`std.Build`）。因此，你只需将Zig标准库导入到你的`build.zig`模块中即可访问此结构。

作为一个非常简单的例子，这里你可以看到从`hello.zig` Zig模块构建可执行文件所需的源代码。

```zig
const std = @import("std");
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("hello.zig"),
        .target = b.host,
    });
    b.installArtifact(exe);
}
```

你可以在这个构建脚本中定义和使用其他函数和对象。你也可以像在项目的任何其他模块中一样导入其他Zig模块。这个构建脚本的唯一真正要求是定义一个公共的顶级`build()`函数，该函数接受指向`Build`结构的指针作为输入。

## 目标对象

正如我们在前面章节中所述，构建脚本是围绕目标对象组成的。每个目标对象通常是你想从构建过程中获得的二进制文件（或输出）。你可以在构建脚本中列出多个目标对象，这样构建过程就会一次为你生成多个二进制文件。

例如，也许你是一名开发跨平台应用程序的开发人员，由于该应用程序是跨平台的，你可能需要为应用程序支持的每个操作系统向最终用户发布软件的二进制文件。因此，你可以在构建脚本中为每个你想发布软件的操作系统（Windows、Linux等）定义不同的目标对象。这将使`zig`编译器一次将你的项目构建到多个目标操作系统。Zig构建系统官方文档有一个[很好的代码示例来演示这种策略](https://ziglang.org/learn/build-system/#handy-examples)。

目标对象由我们在[第9.2节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-build-fun)中介绍的`Build`结构的以下方法创建：

* `addExecutable()`创建可执行文件；
* `addSharedLibrary()`创建共享库文件；
* `addStaticLibrary()`创建静态库文件；
* `addTest()`创建执行单元测试的可执行文件。

这些函数是你作为`build()`函数输入接收的`Build`结构的方法。它们都创建一个`Compile`对象作为输出，该对象表示要由`zig`编译器编译的目标对象。所有这些函数都接受类似的结构字面量作为输入。这个结构字面量定义了你正在构建的目标对象的三个基本规格：`name`、`target`和`root_source_file`。

我们已经在前面的例子中看到了这三个选项的使用，我们使用`addExecutable()`方法创建了一个可执行目标对象。这个例子在下面重现。注意使用`Build`结构的`path()`方法来定义`root_source_file`选项中的路径。

```zig
const exe = b.addExecutable(.{
    .name = "hello",
    .root_source_file = b.path("hello.zig"),
    .target = b.host,
});
```

`name`选项指定你要给这个目标对象定义的二进制文件的名称。所以，在这个例子中，我们正在构建一个名为`hello`的可执行文件。通常将这个`name`选项设置为你的项目名称。

此外，`target`选项指定此二进制文件的目标计算机架构（或目标操作系统）。例如，如果你希望此目标对象在使用`x86_64`架构的Windows机器上运行，你可以将此`target`选项设置为`x86_64-windows-gnu`。这将使`zig`编译器将项目编译为在`x86_64` Windows机器上运行。你可以通过在终端中运行`zig targets`命令来查看`zig`编译器支持的架构和操作系统的完整列表。

现在，如果你正在构建项目以在当前用于运行此构建脚本的机器上运行，你可以将此`target`选项设置为`Build`对象的`host`方法，就像我们在上面的例子中所做的那样。这个`host`方法识别你当前运行`zig`编译器的当前机器。

最后，`root_source_file`选项指定项目的根Zig模块。这是包含应用程序入口点（即`main()`函数）的Zig模块，或者库的主API。这也意味着，组成项目的所有Zig模块都会从这个"根源文件"内的导入语句自动发现。`zig`编译器可以通过导入语句检测一个Zig模块何时依赖于另一个，因此，它可以发现项目中使用的整个Zig模块映射。

这很方便，并且与其他构建系统中发生的情况不同。例如在CMake中，你必须显式列出要包含在构建过程中的所有源文件的路径。这可能是C和C++编译器"缺乏条件编译"的症状。由于它们缺少此功能，你必须显式选择应该发送给C/C++编译器的源文件，因为并非每个C/C++代码都是可移植的或在每个操作系统中都受支持，因此会在C/C++编译器中导致编译错误。

现在，关于构建过程的一个重要细节是，你必须**显式安装你在构建脚本中创建的目标对象**，通过使用`Build`结构的`installArtifact()`方法。

每次你通过调用`zig`编译器的`build`命令来调用项目的构建过程时，都会在项目的根目录中创建一个名为`zig-out`的新目录。这个新目录包含构建过程的输出，即从源代码构建的二进制文件。

`installArtifact()`方法所做的是将你定义的构建目标对象安装（或复制）到这个`zig-out`目录。这意味着，如果你不安装在构建脚本中定义的目标对象，这些目标对象本质上会在构建过程结束时被丢弃。

例如，你可能正在构建一个使用与项目一起构建的第三方库的项目。所以，当你构建项目时，你首先需要构建第三方库，然后将其与项目的源代码链接。所以，在这种情况下，我们有两个在构建过程中生成的二进制文件（项目的可执行文件和第三方库）。但只有一个是感兴趣的，即我们项目的可执行文件。我们可以通过不将第三方库的二进制文件安装到这个`zig-out`目录中来丢弃它。

这个`installArtifact()`方法非常简单。只需记住将其应用于你想保存到`zig-out`目录的每个目标对象，如下面的例子所示：

```zig
const exe = b.addExecutable(.{
    .name = "hello",
    .root_source_file = b.path("hello.zig"),
    .target = b.host,
});

b.installArtifact(exe);
```

## 设置构建模式

我们已经讨论了创建新目标对象时设置的三个基本选项。但还有第四个选项可以用来设置此目标对象的构建模式，即`optimize`选项。这个选项之所以这样命名，是因为Zig中的构建模式更多地被视为"优化vs安全"问题。所以优化在这里扮演着重要角色。别担心，我很快就会回到这个问题。

在Zig中，我们有四种构建模式（如下所列）。每一种构建模式都提供不同的优势和特征。正如我们在[第5.2.1节](https://pedropark99.github.io/zig-book/Chapters/02-debugging.html#sec-compile-debug-mode)中所述，当你没有显式选择构建模式时，`zig`编译器默认使用`Debug`构建模式。

* `Debug`，在构建过程的输出（即目标对象定义的二进制文件）中生成并包含调试信息的模式；
* `ReleaseSmall`，试图生成体积较小的二进制文件的模式；
* `ReleaseFast`，试图优化你的代码，以生成尽可能快的二进制文件的模式；
* `ReleaseSafe`，试图在可能的情况下通过包含保护措施来使你的代码尽可能安全的模式。

所以，当你构建项目时，你可以将目标对象的构建模式设置为例如`ReleaseFast`，这将告诉`zig`编译器在你的代码中应用重要的优化。这创建了一个在大多数情况下运行更快的二进制文件，因为它包含了更优化的代码版本。然而，结果是，我们经常在代码中失去一些安全特性。因为从最终二进制文件中删除了一些安全检查，这使你的代码运行更快，但安全性较低。

这个选择取决于你当前的优先级。如果你正在构建加密或银行系统，你可能更愿意在代码中优先考虑安全性，因此，你会选择`ReleaseSafe`构建模式，它运行速度稍慢，但更安全，因为它在构建过程中构建的二进制文件中包含了所有可能的运行时安全检查。另一方面，如果你正在编写游戏，你可能更愿意通过使用`ReleaseFast`构建模式来优先考虑性能而不是安全性，这样你的用户可以在游戏中体验更快的帧率。

在下面的例子中，我们创建了在前面例子中使用的相同目标对象。但这次，我们将此目标对象的构建模式指定为`ReleaseSafe`模式。

```zig
const exe = b.addExecutable(.{
    .name = "hello",
    .root_source_file = b.path("hello.zig"),
    .target = b.host,
    .optimize = .ReleaseSafe
});
b.installArtifact(exe);
```

## 设置构建版本

每次在构建脚本中构建目标对象时，你都可以按照语义版本控制框架为这个特定构建分配版本号。你可以通过访问[语义版本控制网站](https://semver.org/)了解更多关于语义版本控制的信息。无论如何，在Zig中，你可以通过向`version`选项提供`SemanticVersion`结构来指定构建的版本，如下面的例子所示：

```zig
const exe = b.addExecutable(.{
    .name = "hello",
    .root_source_file = b.path("hello.zig"),
    .target = b.host,
    .version = .{
        .major = 2, .minor = 9, .patch = 7
    }
});
b.installArtifact(exe);
```

## 在构建脚本中检测操作系统

在构建系统中很常见的是根据构建过程中目标的操作系统（OS）使用不同的选项，或包含不同的模块，或链接不同的库。

在Zig中，你可以通过查看Zig库的`builtin`模块中的`os.tag`来检测构建过程的目标操作系统。在下面的例子中，我们使用if语句在构建过程的目标是Windows系统时运行一些任意代码。

```zig
const builtin = @import("builtin");
if (builtin.target.os.tag == .windows) {
    // 仅当编译过程的目标是Windows时运行的代码
}
```

## 向构建过程添加运行步骤

Rust中一个很棒的功能是你可以用Rust编译器的一个命令（`cargo run`）编译并运行源代码。我们在[第1.2.5节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-compile-run-code)中看到了如何在Zig中执行类似的工作，通过`zig`编译器的`run`命令构建和运行我们的Zig源代码。

但是我们如何在构建脚本中同时构建和运行目标对象指定的二进制文件呢？答案是在我们的构建脚本中包含一个"运行工件"。运行工件是通过`Build`结构的`addRunArtifact()`方法创建的。我们只需向这个函数提供描述我们想要执行的二进制文件的目标对象作为输入。结果，这个函数创建了一个能够执行此二进制文件的运行工件。

在下面的例子中，我们定义了一个名为`hello`的可执行二进制文件，并使用这个`addRunArtifact()`方法创建一个将执行这个`hello`可执行文件的运行工件。

```zig
const exe = b.addExecutable(.{
    .name = "hello",
    .root_source_file = b.path("src/hello.zig"),
    .target = b.host
});
b.installArtifact(exe);
const run_arti = b.addRunArtifact(exe);
```

现在我们已经创建了这个运行工件，我们需要将其包含在构建过程中。我们通过在构建脚本中声明一个新步骤来调用此工件，通过`Build`结构的`step()`方法。

我们可以给这个步骤任何我们想要的名称，但是，对于我们这里的上下文，我将把这个步骤命名为"run"。另外，我给这个步骤一个简短的描述（"运行项目"）。

```zig
const run_step = b.step(
    "run", "Run the project"
);
```

现在我们已经声明了这个"运行步骤"，我们需要告诉Zig这个"运行步骤"依赖于运行工件。换句话说，运行工件总是依赖于一个"步骤"才能有效执行。通过创建这种依赖关系，我们最终建立了从构建脚本构建和运行可执行文件所需的命令。

我们可以通过使用运行步骤的`dependsOn()`方法在运行步骤和运行工件之间建立依赖关系。所以，我们首先创建运行步骤，然后通过使用运行步骤的这个`dependsOn()`方法将其与运行工件链接。

```zig
run_step.dependOn(&run_arti.step);
```

我们在本节中逐步编写的这个特定构建脚本的完整源代码可在`build_and_run.zig`模块中找到。你可以通过[访问本书的官方存储库](https://github.com/pedropark99/zig-book/blob/main/ZigExamples/build_system/build_and_run.zig)来查看此模块。

当你在构建脚本中声明一个新步骤时，这个步骤就可以通过`zig`编译器的`build`命令使用。你实际上可以通过在终端中运行`zig build --help`来看到这个步骤，如下面的例子所示，我们可以看到我们在构建脚本中声明的这个新"run"步骤出现在输出中。

```bash
zig build --help
```

```
Steps:
  ...
  run   Run the project
  ...
```

现在，我们需要做的就是调用我们在构建脚本中创建的这个"run"步骤。我们通过在`zig`编译器的`build`命令后使用我们给这个步骤的名称来调用它。这将导致编译器同时构建我们的可执行文件并执行它。

```bash
zig build run
```

## 在项目中构建单元测试

我们在[第8章](https://pedropark99.github.io/zig-book/Chapters/03-unittests.html)中详细讨论了在Zig中编写单元测试，我们也讨论了如何通过`zig`编译器的`test`命令执行这些单元测试。然而，就像我们在上一节中对`run`命令所做的那样，我们也可能想在构建脚本中包含一些命令来构建和执行项目中的单元测试。

所以，再一次，我们将讨论`zig`编译器的特定内置命令（在本例中是`test`命令）如何在Zig的构建脚本中使用。这就是"测试目标对象"发挥作用的地方。正如在[第9.3节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-targets)中所述，我们可以通过使用`Build`结构的`addTest()`方法创建测试目标对象。我们需要做的第一件事是在构建脚本中声明一个测试目标对象。

```zig
const test_exe = b.addTest(.{
    .name = "unit_tests",
    .root_source_file = b.path("src/main.zig"),
    .target = b.host,
});
b.installArtifact(test_exe);
```

测试目标对象本质上选择项目中所有Zig模块中的所有`test`块，并仅构建项目中这些`test`块中存在的源代码。结果，此目标对象创建了一个仅包含项目中所有这些`test`块（即单元测试）中存在的源代码的可执行文件。

完美！现在我们已经声明了这个测试目标对象，当我们使用`build`命令触发构建脚本时，`zig`编译器会构建一个名为`unit_tests`的可执行文件。构建过程完成后，我们可以简单地在终端中执行这个`unit_tests`可执行文件。

然而，如果你还记得上一节，我们已经学习了如何在构建脚本中创建运行步骤，以执行由构建脚本构建的可执行文件。

所以，我们可以简单地在构建脚本中添加一个运行步骤来从`zig`编译器的单个命令运行这些单元测试，使我们的生活更轻松。在下面的例子中，我们演示了在构建脚本中注册一个名为"tests"的新构建步骤来运行这些单元测试的命令。

```zig
const run_arti = b.addRunArtifact(test_exe);
const run_step = b.step("tests", "Run unit tests");
run_step.dependOn(&run_arti.step);
```

现在我们注册了这个新的构建步骤，我们可以通过在终端中调用下面的命令来触发它。你也可以在[本书的官方存储库](https://github.com/pedropark99/zig-book/blob/main/ZigExamples/build_system/build_tests.zig)的`build_tests.zig`模块中查看这个特定构建脚本的完整源代码。

```bash
zig build tests
```

## 使用用户提供的选项定制构建过程

有时，你希望创建一个可由项目用户自定义的构建脚本。你可以通过在构建脚本中创建用户提供的选项来实现这一点。我们通过使用`Build`结构的`option()`方法创建用户提供的选项。

使用这个方法，我们创建一个"构建选项"，可以在命令行中传递给`build.zig`脚本。用户有权在`zig`编译器的`build`命令中设置这个选项。换句话说，我们创建的每个构建选项都成为通过编译器的`build`命令可访问的新命令行参数。

这些"用户提供的选项"通过在命令行中使用前缀`-D`来设置。例如，如果我们声明一个名为`use_zlib`的选项，它接收一个布尔值，指示我们是否应该将源代码链接到`zlib`，我们可以在命令行中使用`-Duse_zlib`设置这个选项的值。下面的代码示例演示了这个想法：

```zig
const std = @import("std");
pub fn build(b: *std.Build) void {
    const use_zlib = b.option(
        bool,
        "use_zlib",
        "Should link to zlib?"
    ) orelse false;
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("example.zig"),
        .target = b.host,
    });
    if (use_zlib) {
        exe.linkSystemLibrary("zlib");
    }
    b.installArtifact(exe);
}
```

```bash
zig build -Duse_zlib=false
```

## 链接到外部库

每个构建过程的一个基本部分是链接阶段。这个阶段负责将代表你代码的多个目标文件组合成一个单一的可执行文件。如果你在代码中使用任何外部库，它也会将这个可执行文件链接到外部库。

在Zig中，我们有两个"库"的概念，它们是：1）系统库；2）本地库。系统库只是已经安装在你系统中的库。而本地库是属于当前项目的库；存在于你的项目目录中的库，并且你正在与项目源代码一起构建的库。

两者之间的基本区别是，系统库已经在你的系统中构建和安装，据说，你需要做的就是将源代码链接到这个库以开始使用它。我们通过使用`Compile`对象的`linkSystemLibrary()`方法来做到这一点。此方法接受字符串形式的库名称作为输入。请记住，从[第9.3节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-targets)，`Compile`对象是你在构建脚本中声明的目标对象。

当你将特定目标对象与系统库链接时，`zig`编译器将使用`pkg-config`来查找系统中这个库的二进制文件和头文件的位置。当它找到这些文件时，`zig`编译器中的链接器将把你的目标文件与这个库的文件链接，为你生成一个单一的二进制文件。

在下面的例子中，我们创建了一个名为`image_filter`的可执行文件，并且，我们使用`linkLibC()`方法将这个可执行文件链接到C标准库，但我们也将这个可执行文件链接到当前安装在我系统中的C库`libpng`。

```zig
const std = @import("std");
pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "image_filter",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    exe.linkSystemLibrary("png");
    b.installArtifact(exe);
}
```

如果你在项目中链接C库，通常最好也将你的代码与C标准库链接。因为这个C库很可能在某个时候使用C标准库的某些功能。C++库也是如此。所以，如果你链接C++库，最好使用`linkLibCpp()`方法将项目与C++标准库链接。

另一方面，当你想链接本地库时，你应该使用`Compile`对象的`linkLibrary()`方法。此方法期望接收另一个`Compile`对象作为输入。也就是说，在你的构建脚本中定义的另一个目标对象，使用`addStaticLibrary()`或`addSharedLibrary()`方法定义要构建的库。

正如我们前面讨论的，本地库是项目本地的库，正在与项目一起构建。所以，你需要在构建脚本中创建一个目标对象来构建这个本地库。然后，你将项目中感兴趣的目标对象与标识这个本地库的目标对象链接。

看看这个从[`libxev`库](https://github.com/mitchellh/libxev/tree/main)的构建脚本中提取的例子。你可以在这个片段中看到，我们从`c_api.zig`模块声明了一个共享库文件。然后，在构建脚本的后面，我们声明了一个名为`"dynamic-binding-test"`的可执行文件，它链接到我们之前在脚本中定义的这个共享库。

```zig
const optimize = b.standardOptimizeOption(.{});
const target = b.standardTargetOptions(.{});

const dynamic_lib = b.addSharedLibrary(.{
    .name = dynamic_lib_name,
    .root_source_file = b.path("src/c_api.zig"),
    .target = target,
    .optimize = optimize,
});
b.installArtifact(dynamic_lib);
// ... 脚本中的更多行
const dynamic_binding_test = b.addExecutable(.{
    .name = "dynamic-binding-test",
    .target = target,
    .optimize = optimize,
});
dynamic_binding_test.linkLibrary(dynamic_lib);
```

## 构建C代码

`zig`编译器内嵌了一个C编译器。换句话说，你可以使用`zig`编译器来构建C项目。这个C编译器可以通过`zig`编译器的`cc`命令使用。

作为一个例子，让我们使用著名的[FreeType库](https://freetype.org/)。FreeType是世界上使用最广泛的软件之一。它是一个旨在生成高质量字体的C库。但它也在行业中被大量用于在计算机屏幕上本地渲染文本和字体。

在本节中，我们将逐步编写一个能够从源代码构建FreeType项目的构建脚本。你可以在GitHub上的[`freetype-zig`存储库](https://github.com/pedropark99/freetype-zig/tree/main)中找到这个构建脚本的源代码。

从官方网站下载FreeType的源代码后，你可以开始编写`build.zig`模块。我们首先定义定义我们要编译的二进制文件的目标对象。

作为一个例子，我将使用`addStaticLibrary()`方法将项目构建为静态库文件以创建目标对象。另外，由于FreeType是一个C库，我还将通过`linkLibC()`方法将库链接到`libc`，以保证编译过程中涵盖对C标准库的任何使用。

```zig
const target = b.standardTargetOptions(.{});
const opti = b.standardOptimizeOption(.{});
const lib = b.addStaticLibrary(.{
    .name = "freetype",
    .optimize = opti,
    .target = target,
});
lib.linkLibC();
```

### 创建C编译器标志

编译器标志也被许多程序员称为"编译器选项"，或者在GCC官方文档中称为"命令选项"。将它们称为C编译器的"命令行参数"也是公平的。通常，我们使用编译器标志来打开（或关闭）编译器的某些功能，或调整编译过程以适应我们项目的需求。

在用Zig编写的构建脚本中，我们通常在一个简单的数组中列出编译过程中要使用的C编译器标志，如下面的例子所示。

```zig
const c_flags = [_][]const u8{
    "-Wall",
    "-Wextra",
    "-Werror",
};
```

理论上，没有什么能阻止你使用这个数组向编译过程添加"包含路径"（使用`-I`标志）或"库路径"（使用`-L`标志）。但在Zig中有正式的方法在编译过程中添加这些类型的路径。两者都在[第9.11.5节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-include-paths)和[第9.11.4节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-library-paths)中讨论。

无论如何，在Zig中，我们通过使用`addCSourceFile()`和`addCSourceFiles()`方法将C标志与我们想要编译的C文件一起添加到构建过程中。在上面的例子中，我们刚刚声明了我们想要使用的C标志。但我们还没有将它们添加到构建过程中。要做到这一点，我们还需要列出要编译的C文件。

### 列出你的C文件

包含"跨平台"源代码的C文件列在下面的`c_source_files`对象中。这些是FreeType库支持的每个平台默认包含的C文件。现在，由于FreeType库中的C文件数量很大，为了简洁起见，我在下面的代码示例中省略了其余的文件。

```zig
const c_source_files = [_][]const u8{
    "src/autofit/autofit.c",
    "src/base/ftbase.c",
    // ... 以及许多其他C文件。
};
```

现在，除了"跨平台"源代码外，FreeType项目中还有一些特定于平台的C文件，这意味着它们包含只能在特定平台上编译的源代码，因此，它们仅包含在这些特定目标平台的构建过程中。列出这些C文件的对象在下面的代码示例中展示。

```zig
const windows_c_source_files = [_][]const u8{
    "builds/windows/ftdebug.c",
    "builds/windows/ftsystem.c"
};
const linux_c_source_files = [_][]const u8{
    "src/base/ftsystem.c",
    "src/base/ftdebug.c"
};
```

现在我们已经声明了要包含的文件和要使用的C编译器标志，我们可以通过使用`addCSourceFile()`和`addCSourceFiles()`方法将它们添加到描述FreeType库的目标对象中。

这两个函数都是`Compile`对象（即目标对象）的方法。`addCSourceFile()`方法能够向目标对象添加单个C文件，而`addCSourceFiles()`方法用于在单个命令中添加多个C文件。当你需要在项目中的特定C文件上使用不同的编译器标志时，你可能更喜欢使用`addCSourceFile()`。但是，如果你可以在所有C文件中使用相同的编译器标志，那么你可能会发现`addCSourceFiles()`是更好的选择。

注意，我们在下面的例子中使用`addCSourceFiles()`方法来添加C文件和C编译器标志。还要注意，我们使用在[第9.6节](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#sec-detect-os)中学到的`os.tag`来添加特定于平台的C文件。

```zig
const builtin = @import("builtin");
lib.addCSourceFiles(
    &c_source_files, &c_flags
);

switch (builtin.target.os.tag) {
    .windows => {
        lib.addCSourceFiles(
            &windows_c_source_files,
            &c_flags
        );
    },
    .linux => {
        lib.addCSourceFiles(
            &linux_c_source_files,
            &c_flags
        );
    },
    else => {},
}
```

### 定义C宏

C宏是C编程语言的重要组成部分，它们通常通过C编译器的`-D`标志定义。在Zig中，你可以通过使用定义你正在构建的二进制文件的目标对象的`defineCMacro()`方法来定义要在构建过程中使用的C宏。

在下面的例子中，我们使用在前面部分中定义的`lib`对象来定义FreeType项目在编译过程中使用的一些C宏。这些C宏指定FreeType是否应该（或不应该）包含来自不同外部库的功能。

```zig
lib.defineCMacro("FT_DISABLE_ZLIB", "TRUE");
lib.defineCMacro("FT_DISABLE_PNG", "TRUE");
lib.defineCMacro("FT_DISABLE_HARFBUZZ", "TRUE");
lib.defineCMacro("FT_DISABLE_BZIP2", "TRUE");
lib.defineCMacro("FT_DISABLE_BROTLI", "TRUE");
lib.defineCMacro("FT2_BUILD_LIBRARY", "TRUE");
```

### 添加库路径

库路径是计算机中C编译器将查找（或搜索）库文件以链接你的源代码的路径。换句话说，当你在C源代码中使用库，并要求C编译器将源代码与该库链接时，C编译器将在这个"库路径"集合中列出的路径中搜索该库的二进制文件。

这些路径是特定于平台的，默认情况下，C编译器首先查看计算机中预定义的一组位置。但你可以向此列表添加更多路径（或更多位置）。例如，你可能在计算机的非常规位置安装了一个库，你可以通过将此路径添加到这个预定义路径列表中，让C编译器"看到"这个"非常规位置"。

在Zig中，你可以通过使用目标对象的`addLibraryPath()`方法向此集合添加更多路径。首先，你定义一个包含要添加的路径的`LazyPath`对象，然后，你将此对象作为输入提供给`addLibraryPath()`方法，如下面的例子所示：

```zig
const lib_path: std.Build.LazyPath = .{
    .cwd_relative = "/usr/local/lib/"
};
lib.addLibraryPath(lib_path);
```

### 添加包含路径

预处理器搜索路径是C社区中的一个流行概念，但许多C程序员也将其称为"包含路径"，因为这个"搜索路径"中的路径与C文件中找到的`#include`语句相关。

包含路径类似于库路径。它们是计算机中C编译器在编译过程中查找文件的一组预定义位置。但是，编译器不是查找库文件，而是在包含路径中查找C源代码中包含的头文件。这就是为什么许多C程序员更喜欢将这些路径称为"预处理器搜索路径"。因为头文件是在编译过程的预处理器阶段处理的。

所以，你通过`#include`语句在C源代码中包含的每个头文件都需要在某个地方找到，C编译器将在这个"包含路径"集合中列出的路径中搜索这个头文件。包含路径通过`-I`标志添加到编译过程中。

在Zig中，你可以通过使用目标对象的`addIncludePath()`方法向这个预定义路径集合添加新路径。此方法也接受`LazyPath`对象作为输入。

```zig
const inc_path: std.Build.LazyPath = .{
    .path = "./include"
};
lib.addIncludePath(inc_path);
```

## 脚注

1.   [https://ziglang.org/learn/build-system/#user-provided-options](https://ziglang.org/learn/build-system/#user-provided-options)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref1)

2.   [https://zig.news/xq/zig-build-explained-part-1-59lf](https://zig.news/xq/zig-build-explained-part-1-59lf)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref2)

3.   [https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref3)

4.   [https://ziglang.org/learn/build-system/#handy-examples](https://ziglang.org/learn/build-system/#handy-examples)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref4)

5.   [https://semver.org/](https://semver.org/)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref5)

6.   [https://github.com/pedropark99/zig-book/blob/main/ZigExamples/build_system/build_and_run.zig](https://github.com/pedropark99/zig-book/blob/main/ZigExamples/build_system/build_and_run.zig)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref6)

7.   [https://github.com/pedropark99/zig-book/blob/main/ZigExamples/build_system/build_tests.zig](https://github.com/pedropark99/zig-book/blob/main/ZigExamples/build_system/build_tests.zig)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref7)

8.   [https://github.com/mitchellh/libxev/tree/main](https://github.com/mitchellh/libxev/tree/main)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref8)

9.   [https://freetype.org/](https://freetype.org/)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref9)

10.   [https://github.com/pedropark99/freetype-zig/tree/main](https://github.com/pedropark99/freetype-zig/tree/main)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref10)

11.   [https://freetype.org/](https://freetype.org/)[↩︎](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html#fnref11)
