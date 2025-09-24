# 第10章 错误处理和联合类型 - Zig入门介绍

在本章中，我想讨论Zig中如何进行错误处理。我们已经在[第1.2.3节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-main-file)中简要了解了Zig中处理错误的一种可用策略，即`try`关键字。但我们还没有了解其他方法，比如`catch`关键字。我还想在本章中讨论如何在Zig中创建联合类型。

## 深入了解Zig中的错误

在我们深入了解错误处理方式之前，我们需要更多地了解Zig中的错误是什么。在Zig中，错误实际上是一个值（[Zig Software Foundation 2024a](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-zigoverview)）。换句话说，当你的Zig程序内部发生错误时，意味着在你的Zig代码库的某个地方正在生成一个错误值。错误值类似于你在Zig代码中创建的任何整数值。你可以获取一个错误值并将其作为输入传递给函数，你也可以将其转换（或强制转换）为不同类型的错误值。

这与C++和Python中的异常有一些相似之处。因为在C++和Python中，当`try`块内发生异常时，你可以使用`catch`块（在C++中）或`except`块（在Python中）来捕获`try`块中产生的异常，并将其作为输入传递给函数。

然而，Zig中的错误值的处理方式与异常非常不同。首先，你不能在Zig代码中忽略错误值。这意味着，如果错误值出现在源代码的某个地方，这个错误值必须以某种方式显式处理。这也意味着你不能通过将错误值赋值给下划线来丢弃它们，就像你可以对普通值和对象所做的那样。

以下面的源代码为例。这里我们试图打开一个在我的计算机上不存在的文件，结果，`openFile()`函数返回了一个明显的`FileNotFound`错误值。但因为我将这个函数的结果赋值给下划线，我最终试图丢弃一个错误值。

`zig`编译器检测到这个错误，并引发编译错误，告诉我我正在尝试丢弃错误值。它还添加了一条注释消息，建议使用`try`、`catch`或if语句来显式处理这个错误值。这个注释强调了在Zig中每个可能的错误值都必须被显式处理。

```zig
const dir = std.fs.cwd();
_ = dir.openFile("doesnt_exist.txt", .{});
```

```
t.zig:8:17: error: error set is discarded
t.zig:8:17: note: consider using 'try', 'catch', or 'if'
```

### 从函数返回错误

正如我们在[第1.2.3节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-main-file)中所述，当我们有一个可能返回错误值的函数时，这个函数通常在其返回类型注解中包含一个感叹号（`!`）。这个感叹号的存在表明这个函数可能会返回一个错误值作为结果，并且`zig`编译器强制你始终显式处理这个函数返回错误值的情况。

看看下面的`print_name()`函数。这个函数可能在`stdout.print()`函数调用中返回错误，因此，它的返回类型（`!void`）中包含了一个感叹号。

```zig
fn print_name() !void {
    const stdout = std.getStdOut().writer();
    try stdout.print("My name is Pedro!", .{});
    try stdout.flush();
}
```

在上面的例子中，我们使用感叹号告诉`zig`编译器这个函数可能返回某个错误。但究竟从这个函数返回哪个错误呢？目前，我们没有指定具体的错误值。目前，我们只知道可能会返回某个错误值（无论它是什么）。

但实际上，如果你愿意，你可以明确指定可能从这个函数返回的确切错误值。Zig标准库中有很多这样的例子。以`http.Client`模块中的这个`fill()`函数为例。这个函数要么返回一个`ReadError`类型的错误值，要么返回`void`。

```zig
pub fn fill(conn: *Connection) ReadError!void {
    // 这个函数的主体...
}
```

指定你期望从函数返回的确切错误值这个想法很有趣。因为它们自动成为你函数的某种文档，而且，这允许`zig`编译器对你的代码执行一些额外的检查。因为编译器可以检查是否有任何其他类型的错误值在你的函数内部生成，并且没有在这个返回类型注解中被考虑到。

无论如何，你可以通过在感叹号的左侧列出它们来列出可以从函数返回的错误类型。而有效值则保留在感叹号的右侧。所以语法格式变为：

`<错误值>!<有效值>`

### 错误集

但是当我们有一个可能返回不同类型错误的函数时怎么办？当你有这样的函数时，你可以通过我们在Zig中称为**错误集**的结构来列出所有可以从这个函数返回的不同类型的错误。

错误集是联合类型的特殊情况。它是一个包含错误值的联合。并非所有编程语言都有"联合对象"的概念。但总的来说，联合只是一组数据类型。联合用于允许对象具有多种数据类型。例如，`x`、`y`和`z`的联合意味着对象可以是类型`x`，或类型`y`，或类型`z`。

我们将在[第10.3节](https://pedropark99.github.io/zig-book/Chapters/09-error-handling.html#sec-unions)中更深入地讨论联合。但你可以通过在一对花括号前写关键字`error`来编写错误集，然后在这对花括号内列出可以从函数返回的错误值。

以下面的`resolvePath()`函数为例，它来自Zig标准库的`introspect.zig`模块。我们可以在其返回类型注解中看到，这个函数返回：1）有效的`u8`值切片（`[]u8`）；或者，2）错误集内列出的三种不同类型的错误值之一（`OutOfMemory`、`Unexpected`等）。这是错误集的使用示例。

```zig
pub fn resolvePath(
    ally: mem.Allocator,
    p: []const u8,
) error{
    OutOfMemory,
    CurrentWorkingDirectoryUnlinked,
    Unexpected,
}![]u8 {
    // 函数的主体...
}
```

这是注解Zig函数返回值的有效方式。但是，如果你浏览组成Zig标准库的模块，你会注意到，在大多数情况下，程序员更喜欢给这个错误集一个描述性名称，然后在返回类型注解中使用这个名称（或这个错误集的"标签"），而不是直接使用错误集。

我们可以在我们之前在`fill()`函数中展示的`ReadError`错误集中看到这一点，它在`http.Client`模块中定义。所以是的，我之前展示`ReadError`时好像它只是一个标准的单一错误值，但实际上，它是在`http.Client`模块中定义的错误集，因此，它实际上代表了可能在`fill()`函数内部发生的一组不同的错误值。

看看下面重现的`ReadError`定义。注意我们将所有这些不同的错误值分组到一个单一对象中，然后我们在函数的返回类型注解中使用这个对象。就像我们之前展示的`fill()`函数，或者来自同一模块的`readvDirect()`函数，在下面重现。

```zig
pub const ReadError = error{
    TlsFailure,
    TlsAlert,
    ConnectionTimedOut,
    ConnectionResetByPeer,
    UnexpectedReadFailure,
    EndOfStream,
};
// 一些代码行
pub fn readvDirect(
        conn: *Connection,
        buffers: []std.posix.iovec
    ) ReadError!usize {
    // 函数的主体...
}
```

所以，错误集只是将一组可能的错误值分组到单个对象或单个错误值类型的便捷方式。

### 转换错误值

假设你有两个不同的错误集，名为`A`和`B`。如果错误集`A`是错误集`B`的超集，那么你可以将错误值从`B`转换（或强制转换）为`A`的错误值。

错误集只是一组错误值。因此，如果错误集`A`包含错误集`B`的所有错误值，那么`A`就成为`B`的超集。你也可以说错误集`B`是错误集`A`的子集。

下面的例子演示了这个想法。因为`A`包含`B`的所有值，`A`是`B`的超集。用数学符号，我们会说 \(A \supset B\)。因此，我们可以将`B`的错误值作为输入提供给`cast()`函数，并隐式地将这个输入转换为相同的错误值，但来自`A`集。

```zig
const std = @import("std");
const A = error{
    ConnectionTimeoutError,
    DatabaseNotFound,
    OutOfMemory,
    InvalidToken,
};
const B = error {
    OutOfMemory,
};

fn cast(err: B) A {
    return err;
}

test "coerce error value" {
    const error_value = cast(B.OutOfMemory);
    try std.testing.expect(
        error_value == A.OutOfMemory
    );
}
```

```
1/1 file5b736396fa95.test.coerce error value...OKA
  All 1 tests passed.
```

## 如何处理错误

现在我们更多地了解了Zig中的错误是什么，让我们讨论处理这些错误的可用策略，它们是：

* `try`关键字；
* `catch`关键字；
* if语句；
* `errdefer`关键字；

### `try`意味着什么？

正如我在前面章节中所述，当我们说一个表达式可能返回错误时，我们基本上是指一个具有`!T`格式返回类型的表达式。`!`表示这个表达式要么返回错误值，要么返回类型`T`的值。

在[第1.2.3节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-main-file)中，我介绍了`try`关键字以及在哪里使用它。但我没有谈到这个关键字对你的代码究竟做了什么，或者换句话说，我还没有解释`try`在你的代码中意味着什么。

本质上，当你在表达式中使用`try`关键字时，你是在告诉`zig`编译器以下内容："嘿！为我执行这个表达式，如果这个表达式返回错误，请为我返回这个错误并停止我程序的执行。但如果这个表达式返回有效值，那么返回这个值，并继续。"

换句话说，`try`关键字本质上是一种进入恐慌模式的策略，如果发生错误就停止程序的执行。使用`try`关键字，你告诉`zig`编译器，如果在那个特定表达式中发生错误，停止程序执行是最合理的策略。

### `catch`关键字

好的，现在我们正确理解了`try`的含义，让我们现在讨论`catch`。这里的一个重要细节是，你可以使用`try`或`catch`来处理错误，但你**不能同时使用`try`和`catch`**。换句话说，`try`和`catch`是Zig语言中不同且完全独立的策略。

这是不常见的，与其他语言中发生的情况不同。大多数采用_try catch_模式的编程语言（如C++、R、Python、Javascript等），通常一起使用这两个关键字来形成正确处理错误的完整逻辑。无论如何，Zig在_try catch_模式中尝试了不同的方法。

所以，我们已经了解了`try`的含义，我们也知道`try`和`catch`都应该单独使用，彼此分开。但`catch`在Zig中究竟做什么？使用`catch`，我们可以构建一个逻辑块来处理错误值，以防它在当前表达式中发生。

看看下面的代码示例。我们再次回到之前的例子，我们试图打开一个在我的计算机上不存在的文件，但这次，我使用`catch`来实际实现处理错误的逻辑，而不是立即停止执行。

更具体地说，在这个例子中，我使用logger对象在返回错误并停止程序执行之前，在系统中记录一些日志。例如，这可能是我没有完全控制的复杂系统代码库的某个部分，我想在程序崩溃之前记录这些日志，以便我以后可以调试它（例如，也许我无法编译完整的程序，并使用调试器正确调试它。所以，这些日志可能是克服这个障碍的有效策略）。

```zig
const dir = std.fs.cwd();
const file = dir.openFile(
    "doesnt_exist.txt", .{}
) catch |err| {
    logger.record_context();
    logger.log_error(err);
    return err;
};
```

因此，我们使用`catch`创建一个将处理错误的表达式块。我可以从这个表达式块返回错误值，就像我在上面的例子中所做的那样，这将使程序进入恐慌模式并停止执行。但我也可以从这个代码块返回一个有效值，该值将存储在`file`对象中。

注意，我们不是像使用`try`那样在可能返回错误的表达式之前写关键字，而是在表达式之后写`catch`。我们可以打开管道对（`|`），它捕获表达式返回的错误值，并使这个错误值在`catch`块的作用域中作为名为`err`的对象可用。换句话说，因为我在代码中写了`|err|`，我可以通过使用`err`对象访问表达式返回的错误值。

虽然这是`catch`最常见的用法，但你也可以使用这个关键字以"默认值"风格处理错误。也就是说，如果表达式返回错误，我们使用默认值。否则，我们使用表达式返回的有效值。

Zig官方语言参考提供了一个使用`catch`的"默认值"策略的很好例子。这个例子在下面重现。注意我们正在尝试从名为`str`的字符串对象解析一些无符号整数。换句话说，这个函数试图将类型`[]const u8`的对象（即字符数组、字符串等）转换为类型`u64`的对象。

但是`parseU64()`函数完成的这个解析过程可能会失败，导致运行时错误。此例中使用的`catch`关键字提供了一个替代值（13），以防这个`parseU64()`函数引发错误。所以，下面的表达式本质上意味着："嘿！请为我将这个字符串解析为`u64`，并将结果存储到`number`对象中。但是，如果发生错误，则使用值`13`。"

```zig
const number = parseU64(str, 10) catch 13;
```

所以，在这个过程结束时，`number`对象将包含从输入字符串`str`成功解析的`u64`整数，或者，如果解析过程中发生错误，它将包含`catch`关键字作为"默认"或"替代"值提供的`u64`值`13`。

### 使用if语句

现在，你也可以在Zig代码中使用if语句来处理错误。在下面的例子中，我重现了前面的例子，我们尝试使用名为`parseU64()`的函数从输入字符串解析整数值。

我们执行"if"内的表达式。如果这个表达式返回错误值，if语句的"if分支"（或"真分支"）不会执行。但如果这个表达式返回有效值，那么这个值将被解包到`number`对象中。

这意味着，如果`parseU64()`表达式返回有效值，这个值将通过我们在管道字符对（`|`）内列出的对象在这个"if分支"（即"真分支"）的作用域内可用，该对象是`number`对象。

如果发生错误，我们可以使用if语句的"else分支"（或"假分支"）来处理错误。在下面的例子中，我们在if语句中使用`else`将错误值（由`parseU64()`返回）解包到`err`对象中，并处理错误。

```zig
if (parseU64(str, 10)) |number| {
    // 在这里对`number`做些什么
} else |err| {
    // 处理错误值。
}
```

现在，如果你正在执行的表达式返回不同类型的错误值，并且你希望对每种类型的错误值采取不同的操作，`try`和`catch`关键字以及if语句策略就变得有限了。

对于这种情况，语言的官方文档建议将switch语句与if语句一起使用（[Zig Software Foundation 2024b](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-zigdocs)）。基本思想是，使用if语句执行表达式，并使用"else分支"将错误值传递给switch语句，在其中你为if语句中执行的表达式可能返回的每种类型的错误值定义不同的操作。

下面的例子演示了这个想法。我们首先尝试向队列添加（或注册）一组任务。如果这个"注册过程"进行顺利，我们然后尝试在我们系统的工作者之间分配这些任务。但如果这个"注册过程"返回错误值，我们然后在"else分支"中使用switch语句来处理每个可能的错误值。

```zig
if (add_tasks_to_queue(&queue, tasks)) |_| {
    distribute_tasks(&queue);
} else |err| switch (err) {
    error.InvalidTaskName => {
        // 做些什么
    },
    error.TimeoutTooBig => {
        // 做些什么
    },
    error.QueueNotFound => {
        // 做些什么
    },
    // 以及所有其他错误选项...
}
```

### `errdefer`关键字

C程序中的一个常见模式是在程序执行期间发生错误时清理资源。换句话说，处理错误的一种常见方式是在退出程序之前执行"清理操作"。这保证了运行时错误不会使我们的程序泄露系统资源。

`errdefer`关键字是在恶劣情况下执行此类"清理操作"的工具。这个关键字通常用于在由于生成错误值而停止程序执行之前清理（或释放）分配的资源。

基本思想是向`errdefer`关键字提供一个表达式。然后，`errdefer`仅在当前作用域执行期间发生错误时执行此表达式。在下面的例子中，我们使用分配器对象（我们在[第3.3节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-allocators)中介绍过）来创建一个新的`User`对象。如果我们成功创建并注册了这个新用户，这个`create_user()`函数将返回这个新的`User`对象作为其返回值。

然而，如果由于某种原因，在`errdefer`行之后的某个表达式生成了错误值，例如在`db.add(user)`表达式中，`errdefer`注册的表达式会在错误值从函数返回之前，以及在程序进入恐慌模式并停止当前执行之前执行。

```zig
fn create_user(db: Database, allocator: Allocator) !User {
    const user = try allocator.create(User);
    errdefer allocator.destroy(user);

    // 在数据库中注册新用户。
    _ = try db.register_user(user);
    return user;
}
```

通过使用`errdefer`销毁我们刚刚创建的`user`对象，我们保证在程序执行停止之前释放为这个`user`对象分配的内存。因为如果表达式`try db.add(user)`返回错误值，我们程序的执行就会停止，我们会失去对为`user`对象分配的内存的所有引用和控制。因此，如果我们在程序停止之前不释放与`user`对象相关的内存，我们就无法再释放这个内存了。我们只是失去了做正确事情的机会。这就是为什么`errdefer`在这种情况下是必不可少的。

为了清楚地说明`defer`和`errdefer`之间的区别（我在[第2.1.3节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-defer)和[第2.1.4节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-errdefer1)中描述过），可能值得进一步讨论这个主题。你可能仍然在脑海中有这个问题："如果我们可以使用`defer`，为什么要使用`errdefer`？"

虽然相似，但`errdefer`和`defer`关键字之间的关键区别在于提供的表达式何时执行。`defer`关键字总是在当前作用域结束时执行提供的表达式，无论你的代码如何退出这个作用域。相反，`errdefer`仅在当前作用域中发生错误时执行提供的表达式。

如果你在当前作用域中分配的资源稍后在代码中的不同作用域中被释放，这一点就变得很重要。`create_user()`函数就是这个例子。如果你仔细思考这个函数，你会注意到这个函数将`user`对象作为结果返回。

换句话说，如果`user`对象成功返回，`user`对象的分配内存不会在`create_user()`函数内部被释放。所以，如果这个函数内部没有发生错误，`user`对象会从函数返回，并且可能，在这个`create_user()`函数之后运行的代码将负责释放`user`对象的内存。

但是如果`create_user()`函数内部发生错误会怎样？那会发生什么？这意味着你的代码执行将在这个`create_user()`函数中停止，因此，在这个`create_user()`函数之后运行的代码将根本不运行，结果，`user`对象的内存在你的程序停止之前不会被释放。

这是`errdefer`的完美场景。我们使用这个关键字来保证即使`create_user()`函数内部发生错误，我们的程序也会释放为`user`对象分配的内存。

如果你在同一作用域内分配和释放对象的一些内存，那么，只需使用`defer`就可以了，即`errdefer`在这种情况下对你没有用。但是如果你在作用域A中分配一些内存，但你只在稍后的作用域B中释放这个内存，那么`errdefer`就变得有用了，可以避免在棘手的情况下泄露内存。

## Zig中的联合类型

联合类型定义了对象可以是的一组类型。它就像一个选项列表。每个选项都是对象可以假定的类型。因此，Zig中的联合具有与C中的联合相同的含义或相同的作用。它们用于相同的目的。你也可以说Zig中的联合产生类似于[在Python中使用`typing.Union`](https://docs.python.org/3/library/typing.html#typing.Union)的效果。

例如，你可能正在创建一个将数据发送到托管在某个私有云基础设施中的数据湖的API。假设你在代码库中创建了不同的结构，以存储连接到每个主流数据湖服务（Amazon S3、Azure Blob等）的服务所需的必要信息。

现在，假设你还有一个名为`send_event()`的函数，它接收一个事件作为输入，以及一个目标数据湖，并将输入事件发送到目标数据湖参数中指定的数据湖。但这个目标数据湖可能是三个主流数据湖服务（Amazon S3、Azure Blob等）中的任何一个。这就是联合可以帮助你的地方。

下面定义的联合`LakeTarget`允许`send_event()`的`lake_target`参数是类型`AzureBlob`、类型`AmazonS3`或类型`GoogleGCP`的对象。这个联合允许`send_event()`函数在`lake_target`参数中接收这三种类型中任何一种的对象作为输入。

记住这三种类型（`AmazonS3`、`GoogleGCP`和`AzureBlob`）中的每一种都是我们在源代码中定义的独立结构。所以，乍一看，它们是我们源代码中的独立数据类型。但是`union`关键字将它们统一为一个称为`LakeTarget`的单一数据类型。

```zig
const LakeTarget = union {
    azure: AzureBlob,
    amazon: AmazonS3,
    google: GoogleGCP,
};

fn send_event(
    event: Event,
    lake_target: LakeTarget
) bool {
    // 函数的主体...
}
```

联合定义由数据成员列表组成。每个数据成员都是特定的数据类型。在上面的例子中，`LakeTarget`联合有三个数据成员（`azure`、`amazon`、`google`）。当你实例化使用联合类型的对象时，你只能在这个实例化中使用它的一个数据成员。

你也可以将此解释为：一次只能激活联合类型的一个数据成员，其他数据成员保持非激活和不可访问。例如，如果你创建一个使用`azure`数据成员的`LakeTarget`对象，你就不能再使用或访问数据成员`google`或`amazon`。就好像这些其他数据成员根本不存在于`LakeTarget`类型中一样。

你可以在下面的例子中看到这个逻辑。注意，我们首先使用`azure`数据成员实例化联合对象。结果，这个`target`对象内部只包含`azure`数据成员。只有这个数据成员在这个对象中是活动的。这就是为什么这个代码示例中的最后一行是无效的。因为我们试图实例化数据成员`google`，它当前对这个`target`对象是非活动的，结果，程序进入恐慌模式，通过响亮的错误消息警告我们这个错误。

```zig
var target = LakeTarget {
    .azure = AzureBlob.init()
};
// 只有`azure`数据成员存在于
// `target`对象内部，因此，下面这行
// 是无效的：
target.google = GoogleGCP.init();
```

```
thread 2177312 panic: access of union field 'google' while
    field 'azure' is active:
    target.google = GoogleGCP.init();
          ^
```

所以，当你实例化联合对象时，你必须选择联合类型中列出的数据类型之一（或数据成员之一）。在上面的例子中，我选择使用`azure`数据成员，结果，所有其他数据成员都自动停用，你在实例化对象后就不能再使用它们了。

你可以通过完全重新定义整个枚举对象来激活另一个数据成员。在下面的例子中，我最初使用`azure`数据成员。但然后，我重新定义`target`对象以使用一个新的`LakeTarget`对象，该对象使用`google`数据成员。

```zig
var target = LakeTarget {
    .azure = AzureBlob.init()
};
target = LakeTarget {
    .google = GoogleGCP.init()
};
```

关于联合类型的一个有趣事实是，起初，你不能在switch语句中使用它们（这在[第2.1.2节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-switch)中介绍过）。换句话说，如果你有一个类型为`LakeTarget`的对象，你不能将这个对象作为输入提供给switch语句。

但是如果你真的需要这样做呢？如果你实际上需要向switch语句提供一个"联合对象"怎么办？这个问题的答案依赖于Zig中的另一种特殊类型，即_标记联合_。要创建标记联合，你需要做的就是在联合声明中添加枚举类型。

作为Zig中标记联合的例子，看看下面公开的`Registry`类型。这个类型来自Zig存储库的[`grammar.zig`模块](https://github.com/ziglang/zig/blob/30b4a87db711c368853b3eff8e214ab681810ef9/tools/spirv/grammar.zig)。这个联合类型列出了不同类型的注册表。但注意这次，在`union`关键字后使用`(enum)`。这就是使这个联合类型成为标记联合的原因。通过成为标记联合，这个`Registry`类型的对象可以用作switch语句的输入。这就是你需要做的全部。只需将`(enum)`添加到你的联合声明中，你就可以在switch语句中使用它。

```zig
pub const Registry = union(enum) {
    core: CoreRegistry,
    extension: ExtensionRegistry,
};
```

---

## 脚注

1.   [https://docs.python.org/3/library/typing.html#typing.Union](https://docs.python.org/3/library/typing.html#typing.Union)[↩︎](https://pedropark99.github.io/zig-book/Chapters/09-error-handling.html#fnref1)

2.   [https://github.com/ziglang/zig/blob/30b4a87db711c368853b3eff8e214ab681810ef9/tools/spirv/grammar.zig](https://github.com/ziglang/zig/blob/30b4a87db711c368853b3eff8e214ab681810ef9/tools/spirv/grammar.zig).[↩︎](https://pedropark99.github.io/zig-book/Chapters/09-error-handling.html#fnref2)
