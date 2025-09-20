# 第7章 项目2 - 从零构建HTTP服务器 - Zig语言入门

在本章中，我想和你一起实现一个新的小项目。这次，我们将从零开始实现一个基本的HTTP服务器。

Zig标准库已经有一个实现好的HTTP服务器，可以通过`std.http.Server`访问。但同样，本章我们的目标是**从零开始**实现它。所以我们不能使用Zig标准库中提供的这个服务器对象。

## 什么是HTTP服务器？

首先，什么是HTTP服务器？HTTP服务器，就像任何其他类型的服务器一样，本质上是一个无限期运行的程序，在一个无限循环中，等待来自客户端的传入连接。一旦服务器接收到传入连接，它将接受这个连接，并通过这个连接与客户端来回发送消息。

但在这个连接内传输的消息是特定格式的。它们是HTTP消息（即使用HTTP协议规范的消息）。HTTP协议是现代网络的骨干。如果没有HTTP协议，我们今天所知的万维网将不复存在。

因此，Web服务器（这只是HTTP服务器的一个花哨名称）是与客户端交换HTTP消息的服务器。这些HTTP服务器和HTTP协议规范对今天万维网的运行至关重要。

这就是整个过程的全貌。同样，这里涉及两个主体，一个服务器（这是一个无限期运行的程序，等待接收传入连接），和一个客户端（这是想要连接到服务器并与之交换HTTP消息的人）。

你可能会发现[Mozilla MDN文档中关于HTTP协议的材料](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview)也是一个很好的参考资源。它为你提供了关于HTTP如何工作以及服务器在其中扮演什么角色的很好概述。

## HTTP服务器如何工作？

想象一下HTTP服务器就像一个大酒店的接待员。在酒店里，你有一个前台，前台里有一个接待员在等待客户到来。HTTP服务器本质上就是一个无限期等待新客户（或者在HTTP的上下文中，新客户端）到达酒店的接待员。

当客户到达酒店时，该客户开始与接待员交谈。他告诉接待员他想在酒店住多少天。然后，接待员搜索可用的房间。如果此刻有可用的房间，客户支付酒店费用，然后，他拿到房间的钥匙，然后去房间休息。

在处理客户的整个过程（搜索可用房间、收款、交付钥匙）之后，接待员回到他之前在做的事情，即等待。等待新客户到达。

简而言之，这就是HTTP服务器所做的。它等待客户端连接到服务器。当客户端尝试连接到服务器时，服务器接受这个连接，并开始通过这个连接与客户端交换消息。在这个连接内发生的第一条消息总是从客户端发送到服务器的消息。这条消息称为_HTTP请求_。

这个HTTP请求是一条包含客户端想从服务器得到什么的HTTP消息。它字面上就是一个请求。连接到服务器的客户端正在要求这个服务器为他做某事。

客户端可以向HTTP服务器发送不同"类型的请求"。但最基本的请求类型是，客户端要求HTTP服务器向他提供（即发送）某个特定的网页（这是一个HTML文件）。当你在网络浏览器中输入`google.com`时，你本质上是在向Google的HTTP服务器发送一个HTTP请求。这个请求要求这些服务器向你发送Google网页。

尽管如此，当服务器接收到这第一条消息，即_HTTP请求_时，它会分析这个请求，以了解：客户端是谁？他想让服务器做什么？这个客户端是否提供了执行他所要求的操作所需的所有必要信息？等等。

一旦服务器理解了客户端想要什么，他就简单地执行被请求的操作，并且，为了完成整个过程，服务器向客户端发送一条HTTP消息，通知操作是否成功，最后，服务器结束（或关闭）与客户端的连接。

从服务器发送到客户端的最后一条HTTP消息称为_HTTP响应_。因为服务器正在响应客户端请求的操作。这个响应消息的主要目标是让客户端知道请求的操作是否成功，然后服务器关闭连接。

## HTTP服务器通常如何实现？

让我们以C语言为例。有许多材料教如何用C代码编写简单的HTTP服务器，比如Yu（[2023](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-jeffrey_http)）、Weerasiri（[2023](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-nipun_http)）或Meehan（[2021](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-eric_http)）。考虑到这一点，我不会在这里展示C代码示例，因为你可以在互联网上找到它们。但我会描述在C中创建这样的HTTP服务器所需步骤背后的理论。

本质上，我们通常通过使用TCP套接字在C中实现HTTP服务器，这涉及以下步骤：

1. 创建一个TCP套接字对象。
2. 将名称（或更具体地说，地址）绑定到这个套接字对象。
3. 使这个套接字对象开始监听并等待传入连接。
4. 当连接到达时，我们接受这个连接，并交换HTTP消息（HTTP请求和HTTP响应）。
5. 然后，我们简单地关闭这个连接。

套接字对象本质上是一个通信通道。你正在创建一个人们可以通过它发送消息的通道。当你创建一个套接字对象时，这个对象没有绑定到任何特定地址。这意味着有了这个对象，你手中有一个通信通道的表示。但这个通道目前不可用，或者说，它目前不可访问，因为它没有一个可以找到它的已知地址。

这就是"绑定"操作的作用。它将名称（或更具体地说，地址）绑定到这个套接字对象，或者说，这个通信通道，以便它通过这个地址变得可用或可访问。而"监听"操作使套接字对象监听此地址上的传入连接。换句话说，"监听"操作使套接字等待传入连接。

现在，当客户端实际尝试通过我们指定的套接字地址连接到服务器时，为了与客户端建立这个连接，套接字对象需要接受这个传入连接。因此，当我们接受传入连接时，客户端和服务器彼此连接，他们可以开始在这个建立的连接中读取或写入消息。

在我们从客户端接收HTTP请求、分析它并向客户端发送HTTP响应后，我们可以关闭连接并结束这个通信。

## 实现服务器 - 第1部分

### 创建套接字对象

让我们从为我们的服务器创建套接字对象开始。为了让事情更简短，我将在一个单独的Zig模块中创建这个套接字对象。我将其命名为`config.zig`。

在Zig中，我们可以使用Zig标准库中的`std.posix.socket()`函数创建TCP套接字。正如我之前在[第7.3节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-http-how-impl)中提到的，我们创建的每个套接字对象都代表一个通信通道，我们需要将这个通道绑定到特定地址。"地址"被定义为IP地址，或者更具体地说，IPv4地址。每个IPv4地址由两个组件组成。第一个组件是主机，这是由点字符（`.`）分隔的4个数字序列，用于识别所使用的机器。而第二个组件是端口号，它识别主机机器中使用的特定门或特定端口。

4个数字的序列（即主机）识别这个套接字将驻留的机器（即计算机本身）。每台计算机通常内部有多个可用的"门"，因为这允许计算机同时接收和处理多个连接。他只是为每个连接使用一扇门。所以端口号本质上是一个识别计算机中负责接收连接的特定门的数字。也就是说，它识别套接字将用于接收传入连接的计算机中的"门"。

为了让事情更简单，我将在这个例子中使用识别我们当前机器的IP地址。这意味着，我们的套接字对象将驻留在我们当前用于编写这个Zig源代码的同一台计算机上（这也称为"localhost"）。

按照惯例，识别"localhost"的IP地址（即我们正在使用的当前机器）是IP `127.0.0.1`。所以，这就是我们将在服务器中使用的IP地址。我可以在Zig中使用4个整数的数组来声明它，像这样：

```zig
const localhost = [4]u8{ 127, 0, 0, 1 };
_ = localhost;
```

现在，我们需要决定使用哪个端口号。按照惯例，有一些端口号是保留的，这意味着我们不能将它们用于我们自己的目的，比如端口22（通常用于SSH连接）。对于TCP连接（这是我们这里的情况），端口号是16位无符号整数（Zig中的类型`u16`），因此范围从0到65535（[Wikipedia 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-wikipedia_port)）。所以，我们可以为端口号选择从0到65535的数字。在本书的例子中，我将使用端口号3490（只是一个随机数字）。

现在我们手头有了这两个信息，我终于可以使用`std.posix.socket()`函数创建我们的套接字对象了。首先，我们使用主机和端口号创建一个`Address`对象，使用`std.net.Address.initIp4()`函数，如下面的例子所示。之后，我在`socket()`函数中使用这个地址对象来创建我们的套接字对象。

下面定义的`Socket`结构体总结了这个过程背后的所有逻辑。在这个结构体中，我们有两个数据成员：1）地址对象；2）流对象，这是我们将用来在我们建立的任何连接中读取和写入消息的对象。

注意，在这个结构体的构造方法内部，当我们创建套接字对象时，我们使用`IPROTO.TCP`属性作为输入，告诉函数创建用于TCP连接的套接字。

```zig
const std = @import("std");
const builtin = @import("builtin");
const net = @import("std").net;

pub const Socket = struct {
    _address: std.net.Address,
    _stream: std.net.Stream,

    pub fn init() !Socket {
        const host = [4]u8{ 127, 0, 0, 1 };
        const port = 3490;
        const addr = net.Address.initIp4(host, port);
        const socket = try std.posix.socket(
            addr.any.family,
            std.posix.SOCK.STREAM,
            std.posix.IPPROTO.TCP
        );
        const stream = net.Stream{ .handle = socket };
        return Socket{ ._address = addr, ._stream = stream };
    }
};
```

### 监听和接收连接

记住我们在[第7.4.1节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-create-socket)中构建的`Socket`结构体声明存储在名为`config.zig`的Zig模块中。这就是为什么我在下面的例子中将这个模块导入到我们的主模块（`main.zig`）中，作为`SocketConf`对象，以访问`Socket`结构体。

一旦我们创建了套接字对象，我们现在可以专注于使这个套接字对象监听和接收新的传入连接。我们通过调用包含在套接字对象内的`Address`对象的`listen()`方法来做到这一点，然后，我们对结果调用`accept()`方法。

`Address`对象的`listen()`方法产生一个服务器对象，这是一个将无限期保持打开和运行的对象，等待接收传入连接。因此，如果你尝试通过调用`zig`编译器的`run`命令运行下面的代码示例，你会注意到程序无限期地继续运行，没有明确的结束。

这是因为程序正在等待某事发生。它正在等待有人尝试连接到服务器正在运行并监听传入连接的地址（`http://127.0.0.1:3490`）。这就是`listen()`方法所做的，它使套接字主动等待有人连接。

另一方面，`accept()`方法是当有人尝试连接到套接字时建立连接的函数。这意味着，`accept()`方法返回一个新的连接对象作为结果。你可以使用这个连接对象从客户端读取消息或向客户端写入消息。目前，我们没有对这个连接对象做任何事情。但我们将在下一节中使用它。

```zig
const std = @import("std");
const SocketConf = @import("config.zig");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    try stdout.print("Server Addr: {any}\n", .{socket._address});
    try stdout.flush();
    var server = try socket._address.listen(.{});
    const connection = try server.accept();
    _ = connection;
}
```

这个代码示例只允许一个连接。换句话说，服务器将等待一个传入连接，一旦服务器完成它建立的第一个连接，程序结束，服务器停止。

这在现实世界中不是常态。大多数编写这样的HTTP服务器的人通常将`accept()`方法放在`while`（无限）循环中，如果用`accept()`创建了连接，就会创建一个新的执行线程来处理这个新连接和客户端。也就是说，现实世界的HTTP服务器示例通常依赖并行计算来工作。

使用这种设计，服务器只是接受连接，处理客户端、接收HTTP请求和发送HTTP响应的整个过程，所有这些都在后台完成，在单独的执行线程上。

因此，一旦服务器接受连接并创建单独的线程，服务器就会回到他之前在做的事情，即无限期地等待新连接接受。考虑到这一点，上面展示的代码示例是一个只服务单个客户端的服务器。因为一旦连接被接受，程序就会终止。

### 从客户端读取消息

现在我们已经建立了连接，即我们通过`accept()`函数创建的连接对象，我们现在可以使用这个连接对象来读取客户端发送到我们服务器的任何消息。但我们也可以使用它向客户端发送消息。

基本思想是，如果我们向这个连接对象**写入**任何数据，那么，我们就是在向客户端发送数据，如果我们**读取**这个连接对象中存在的数据，那么，我们就是在读取客户端通过这个连接对象发送给我们的任何数据。所以，只要记住这个逻辑。"读取"是从客户端读取消息，"写入"是向客户端发送消息。

记住从[第7.2节](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#sec-how-http-works)，我们需要做的第一件事是读取客户端发送到我们服务器的HTTP请求。因为它是在建立的连接内发生的第一条消息，因此，它是我们需要处理的第一件事。

这就是为什么我将在这个小项目中创建一个新的Zig模块，名为`request.zig`，以将所有与HTTP请求相关的函数放在一起。然后，我将创建一个名为`read_request()`的新函数，它将使用我们的连接对象来读取客户端发送的消息，即HTTP请求。

```zig
const std = @import("std");
const Connection = std.net.Server.Connection;
pub fn read_request(conn: Connection,
                    buffer: []u8) !void {
    const reader = conn.stream.reader();
    _ = try reader.read(buffer);
}
```

这个函数接受一个切片对象作为缓冲区。`read_request()`函数读取发送到连接对象的消息，并将这个消息保存到我们作为输入提供的缓冲区对象中。

注意我正在使用我们创建的连接对象来读取来自客户端的消息。我首先访问连接对象内的`reader`对象。然后，我调用这个`reader`对象的`read()`方法来有效地读取并保存客户端发送的数据到我们之前创建的缓冲区对象中。我通过将`read()`方法的返回值分配给下划线字符（`_`）来丢弃它，因为这个返回值现在对我们没有用。

## 查看程序的当前状态

我认为现在是查看我们的程序当前如何工作的好时机。我们来看看吧？所以，我要做的第一件事是更新我们小Zig项目中的`main.zig`模块，以便`main()`函数调用我们刚刚创建的这个新`read_request()`函数。我还将在`main()`函数的末尾添加一个打印语句，这样你就可以看到我们刚刚加载到缓冲区对象中的HTTP请求是什么样子的。

另外，我在`main()`函数中创建缓冲区对象，它将负责存储客户端发送的消息，我还使用`for`循环将这个缓冲区对象的所有字段初始化为数字零。这很重要，以确保我们在这个对象中没有未初始化的内存。因为未初始化的内存可能会导致我们程序中的未定义行为。

由于`read_request()`函数应该接收缓冲区对象作为切片对象（`[]u8`）作为输入，我使用语法`array[0..array.len]`来访问这个`buffer`对象的切片。

```zig
const std = @import("std");
const SocketConf = @import("config.zig");
const Request = @import("request.zig");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    try stdout.print("Server Addr: {any}\n", .{socket._address});
    var server = try socket._address.listen(.{});
    const connection = try server.accept();
    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    _ = try Request.read_request(
        connection, buffer[0..buffer.len]
    );
    try stdout.print("{s}\n", .{buffer});
    try stdout.flush();
}
```

现在，我将使用`zig`编译器的`run`命令执行这个程序。但请记住，正如我们之前说的，一旦我执行这个程序，它将无限期地挂起，因为程序正在等待客户端尝试连接到服务器。

更具体地说，程序将在带有`accept()`调用的行暂停。一旦客户端尝试连接到服务器，那么，执行将"取消暂停"，`accept()`函数将最终被执行以创建我们需要的连接对象，程序的其余部分将运行。

你可以在[图7.1](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#fig-print-zigrun1)中看到这一点。消息`Server Addr: 127.0.0.1:3490`被打印到控制台，程序现在正在等待传入连接。

![图片1](https://pedropark99.github.io/zig-book/Figures/print-zigrun1.png)

图7.1：运行程序的截图

我们终于可以尝试连接到这个服务器了，有几种方法可以做到这一点。例如，我们可以使用以下Python脚本：

```python
import requests
requests.get("http://127.0.0.1:3490")
```

或者，我们也可以打开我们喜欢的任何网络浏览器，并输入URL `localhost:3490`。注意：`localhost`与IP `127.0.0.1`是同一回事。当你按Enter键，你的网络浏览器转到这个地址时，首先，浏览器可能会打印一条消息说"此页面无法工作"，然后，它可能会更改为新消息说"无法访问该站点"。

你在网络浏览器中得到这些"错误消息"，因为它没有从服务器得到任何响应。换句话说，当网络浏览器连接到我们的服务器时，它确实通过建立的连接发送了HTTP请求。然后，网络浏览器期待接收HTTP响应，但它没有从服务器得到响应（我们还没有实现HTTP响应逻辑）。

但没关系。我们现在已经达到了我们想要的结果，即连接到服务器，并查看网络浏览器（或Python脚本）发送到服务器的HTTP请求。

如果你回到执行程序时留下打开的控制台，你会看到程序完成了执行，并且控制台中打印了一条新消息，这是网络浏览器发送到服务器的实际HTTP请求消息。你可以在[图7.2](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#fig-print-zigrun2)中看到这条消息。

![图片2](https://pedropark99.github.io/zig-book/Figures/print-zigrun2.png)

图7.2：网络浏览器发送的HTTP请求的截图

## 在Zig中学习枚举

枚举结构在Zig中通过`enum`关键字可用。枚举（"enumeration"的缩写）是一种表示一组常量值的特殊结构。所以，如果你有一个变量可以假定一组短且已知的值，你可能想要将这个变量与枚举结构关联，以确保这个变量只假定这个集合中的值。

枚举的经典例子是原色。如果由于某种原因，你的程序需要表示原色之一，你可以创建一个表示这些颜色之一的枚举。在下面的例子中，我们创建了枚举`PrimaryColorRGB`，它表示RGB颜色系统的原色。通过使用这个枚举，我保证例如`acolor`对象将包含这三个值之一：`RED`、`GREEN`或`BLUE`。

```zig
const PrimaryColorRGB = enum {
    RED, GREEN, BLUE
};
const acolor = PrimaryColorRGB.RED;
_ = acolor;
```

如果由于某种原因，我的代码尝试在`acolor`中保存一个不在这个集合中的值，我将收到一条错误消息，警告我诸如"MAGENTA"之类的值不存在于`PrimaryColorRGB`枚举中。然后我可以轻松修复我的错误。

`const acolor = PrimaryColorRGB.MAGENTA;`

```
e1.zig:5:36: error: enum 'PrimaryColorRGB' has
        no member named 'MAGENTA':
    const acolor = PrimaryColorRGB.MAGENTA;
                                   ^~~~~~~
```

在底层，Zig中的枚举与C中的枚举的工作方式相同。每个枚举值本质上表示为整数。集合中的第一个值表示为零，然后，第二个值是一，……等等。

我们将在下一节中学习的一件事是，枚举可以在其中包含方法。等等……什么？这太棒了！是的，Zig中的枚举类似于结构体，它们可以在其中包含私有和公共方法。

## 实现服务器 - 第2部分

现在，在本节中，我想专注于解析我们从客户端接收的HTTP请求。但是，要有效地解析HTTP请求消息，我们首先需要了解其结构。总之，HTTP请求是一条分为3个不同部分的文本消息：

* 顶级标头，指示HTTP请求的方法、URI和消息中使用的HTTP版本。
* HTTP标头列表。
* HTTP请求的主体。

### 主体

主体在HTTP标头列表之后，它是HTTP请求的可选部分，这意味着，并非所有HTTP请求都会带有主体。例如，每个使用GET方法的HTTP请求通常不带主体。

因为GET请求用于请求数据，而不是将其发送到服务器。因此，主体部分更多地与POST方法相关，这是一种涉及向服务器发送数据以进行处理和存储的方法。

由于我们在这个项目中只支持GET方法，这意味着我们也不需要关心请求的主体。

### 创建HTTP方法枚举

每个HTTP请求都带有明确的方法。HTTP请求中使用的方法由以下单词之一标识：

* GET；
* POST；
* OPTIONS；
* PATCH；
* DELETE；
* 和其他一些方法。

每个HTTP方法用于特定类型的任务。例如，POST方法通常用于将一些数据发布到目标位置。换句话说，它用于向HTTP服务器发送一些数据，以便服务器可以处理和存储它。

作为另一个例子，GET方法通常用于从服务器获取内容。换句话说，每当我们希望服务器向我们发送一些内容时，我们就使用这个方法。它可以是任何类型的内容。它可以是网页、文档文件或JSON格式的某些数据。

当客户端发送POST HTTP请求时，服务器发送的HTTP响应通常唯一的目的是让客户端知道服务器是否成功处理和存储了数据。相反，当服务器接收到GET HTTP请求时，服务器会在HTTP响应本身中发送客户端请求的内容。这表明与HTTP请求关联的方法在很大程度上改变了整个过程中每一方扮演的动态和角色。

由于HTTP请求的HTTP方法由这组非常小且特定的单词标识，创建一个枚举结构来表示HTTP方法会很有趣。这样，我们可以轻松检查我们从客户端接收的HTTP请求是否是我们的小HTTP服务器项目当前支持的HTTP方法。

下面的`Method`结构表示这个枚举。注意，目前，这个枚举中只包含GET HTTP方法。因为，出于本章的目的，我只想实现GET HTTP方法。这就是为什么我不在这个枚举中包含其他HTTP方法。

```zig
pub const Method = enum {
    GET
};
```

现在，我认为我们应该向这个枚举结构添加两个方法。一个方法是`is_supported()`，这将是一个返回布尔值的函数，指示输入的HTTP方法是否被我们的HTTP服务器支持。另一个是`init()`，这是一个构造函数，它接受字符串作为输入，并尝试将其转换为`Method`值。

但为了构建这些函数，我将使用Zig标准库的一个功能，称为`StaticStringMap()`。这个函数允许我们创建从字符串到枚举值的简单映射。换句话说，我们可以使用这个映射结构将字符串映射到相应的枚举值。在某种程度上，标准库中的这个特定结构几乎像"哈希表"结构一样工作，它针对小词集或小键集进行了优化，这正是我们这里的情况。我们将在[第11.2节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-maps-hashtables)中更多地讨论Zig中的哈希表。

要使用这个"静态字符串映射"结构，你必须从Zig标准库的`std.static_string_map`模块导入它。只是为了让事情更短更容易输入，我将通过不同的更短的名称（`Map`）导入这个函数。

导入`Map()`后，我们可以将这个函数应用于我们将在结果映射中使用的枚举结构。在我们这里的情况下，它是我们在最后一个代码示例中声明的`Method`枚举结构。然后，我使用映射调用`initComptime()`方法，即我们将使用的键值对列表。

你可以在下面的例子中看到，我使用多个匿名结构体字面量编写了这个映射。在第一个（或"顶级"）结构体字面量内，我们有一个结构体字面量的列表（或序列）。这个列表中的每个结构体字面量代表一个单独的键值对。每个键值对中的第一个元素（或键）应该总是字符串值。而第二个元素应该是你在`Map()`函数中使用的枚举结构的值。

```zig
const Map = std.static_string_map.StaticStringMap;
const MethodMap = Map(Method).initComptime(.{
    .{ "GET", Method.GET },
});
```

因此，`MethodMap`对象基本上是C++中的`std::map`对象，或者Python中的`dict`对象。你可以通过使用映射对象的`get()`方法来检索（或获取）对应于特定键的枚举值。这个方法返回一个可选值，所以，`get()`方法可能导致null值。

我们可以利用这一点来检测特定的HTTP方法是否在我们的HTTP服务器中受支持。因为，如果`get()`方法返回null，这意味着它没有在`MethodMap`对象中找到我们提供的方法，因此，这个方法不被我们的HTTP服务器支持。

下面的`init()`方法接受字符串值作为输入，然后，它只是将这个字符串值传递给我们的`MethodMap`对象的`get()`方法。因此，我们应该得到对应于这个输入字符串的枚举值。

注意在下面的例子中，`init()`方法返回错误（如果`?`方法返回`unreacheable`可能会发生，查看[第6.4.3节](https://pedropark99.github.io/zig-book/Chapters/05-pointers.html#sec-null-handling)了解更多详细信息）或`Method`对象作为结果。由于`GET`目前是我们`Method`枚举结构中的唯一值，这意味着`init()`方法很可能返回值`Method.GET`作为结果。

还要注意，在`is_supported()`方法中，我们使用从我们的`MethodMap`对象的`get()`方法返回的可选值。if语句解包这个方法返回的可选值，如果这个可选值是非null值，则返回`true`。否则，它只返回`false`。

```zig
pub const Method = enum {
    GET,
    pub fn init(text: []const u8) !Method {
        return MethodMap.get(text).?;
    }
    pub fn is_supported(m: []const u8) bool {
        const method = MethodMap.get(m);
        if (method) |_| {
            return true;
        }
        return false;
    }
};
```

### 编写解析请求函数

现在我们创建了表示我们的HTTP方法的枚举，我们应该开始编写负责实际解析HTTP请求的函数。

我们可以做的第一件事是编写一个结构体来表示HTTP请求。以下面的`Request`结构体为例。它包含HTTP请求中"顶级"标头（即第一行）的三个基本信息。

```zig
const Request = struct {
    method: Method,
    version: []const u8,
    uri: []const u8,
    pub fn init(method: Method,
                uri: []const u8,
                version: []const u8) Request {
        return Request{
            .method = method,
            .uri = uri,
            .version = version,
        };
    }
};
```

`parse_request()`函数应该接收字符串作为输入。这个输入字符串包含整个HTTP请求消息，解析函数应该读取和理解这个消息的各个部分。

现在，请记住，出于本章的目的，我们只关心这条消息中的第一行，它包含"顶级标头"，或者关于HTTP请求的三个基本属性，即使用的HTTP方法、URI和HTTP版本。

注意我在`parse_request()`中使用函数`indexOfScalar()`。这个来自Zig标准库的函数返回我们提供的标量值在字符串中发生的第一个索引。在这种情况下，我正在寻找换行符（`\n`）的第一次出现。因为再一次，我们只关心HTTP请求消息中的第一行。这是我们有要解析的三个信息（HTTP版本、HTTP方法和URI）的行。

因此，我们使用这个`indexOfScalar()`函数将我们的解析过程限制在消息的第一行。还值得一提的是，`indexOfScalar()`函数返回一个可选值。这就是为什么我使用`orelse`关键字提供替代值，以防函数返回的值是null值。

由于这三个属性中的每一个都由一个简单的空格分隔，我们可以使用Zig标准库中的函数`splitScalar()`通过查找出现简单空格的每个位置来将输入字符串分成几部分。换句话说，这个`splitScalar()`函数等同于Python中的`split()`方法，或者C++中的`std::getline()`函数，或C中的`strtok()`函数。

当你使用这个`splitScalar()`函数时，你得到一个迭代器作为结果。这个迭代器有一个`next()`方法，你可以使用它来将迭代器推进到下一个位置，或者分割字符串的下一部分。请注意，当你使用`next()`时，该方法不仅推进迭代器，而且还返回分割字符串当前部分的切片作为结果。

现在，如果你想获得分割字符串当前部分的切片，但不将迭代器推进到下一个位置，你可以使用`peek()`方法。`next()`和`peek()`方法都返回可选值，这就是为什么我使用`?`方法来解包这些可选值。

```zig
pub fn parse_request(text: []u8) Request {
    const line_index = std.mem.indexOfScalar(
        u8, text, '\n'
    ) orelse text.len;
    var iterator = std.mem.splitScalar(
        u8, text[0..line_index], ' '
    );
    const method = try Method.init(iterator.next().?);
    const uri = iterator.next().?;
    const version = iterator.next().?;
    const request = Request.init(method, uri, version);
    return request;
}
```

正如我在[第1.8节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-zig-strings)中描述的，Zig中的字符串只是语言中的字节数组。因此，你会在Zig标准库的这个`mem`模块中找到许多优秀的实用函数来直接处理字符串。我们已经在[第1.8.5节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-strings-useful-funs)中描述了其中一些有用的实用函数。

### 使用解析请求函数

现在我们编写了负责解析HTTP请求的函数，我们可以在程序的`main()`函数中添加对`parse_request()`的函数调用。

之后，再次测试我们程序的状态是个好主意。我再次使用`zig`编译器的`run`命令执行这个程序，然后，我使用我的网络浏览器通过URL `localhost:3490`再次连接到服务器，最后，我们的`Request`对象的最终结果被打印到控制台。

快速观察，由于我在打印语句中使用了`any`格式说明符，`Request`结构体的数据成员`version`和`uri`被打印为原始整数值。字符串数据被打印为整数值在Zig中很常见，请记住，这些整数值只是形成所讨论字符串的字节的十进制表示。

在下面的结果中，十进制值72、84、84、80、47、49、46、49和13的序列是形成文本"HTTP/1.1"的字节。整数47是字符`/`的十进制值，它代表这个请求中的URI。

```zig
const std = @import("std");
const SocketConf = @import("config.zig");
const Request = @import("request.zig");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    var server = try socket._address.listen(.{});
    const connection = try server.accept();

    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    try Request.read_request(
        connection, buffer[0..buffer.len]
    );
    const request = Request.parse_request(
        buffer[0..buffer.len]
    );
    try stdout.print("{any}\n", .{request});
    try stdout.flush();
}
```

```
request.Request{
    .method = request.Method.GET,
    .version = {72, 84, 84, 80, 47, 49, 46, 49, 13},
    .uri = {47}
}
```

### 向客户端发送HTTP响应

在最后一部分，我们将编写负责从服务器向客户端发送HTTP响应的逻辑。为了让事情简单，这个项目中的服务器将只发送一个包含文本"Hello world"的简单网页。

首先，我在项目中创建一个新的Zig模块，名为`response.zig`。在这个模块中，我将只声明两个函数。每个函数对应HTTP响应中的特定状态代码。`send_200()`函数将向客户端发送状态代码为200（意思是"成功"）的HTTP响应。而`send_404()`函数发送状态代码为404（意思是"未找到"）的响应。

这绝对不是处理HTTP响应的最符合人体工程学和最适当的方式，但它适用于我们这里的情况。毕竟，我们在这本书中只是构建玩具项目，因此，我们编写的源代码不需要完美。它只需要工作！

```zig
const std = @import("std");
const Connection = std.net.Server.Connection;
pub fn send_200(conn: Connection) !void {
    const message = (
        "HTTP/1.1 200 OK\nContent-Length: 48"
        ++ "\nContent-Type: text/html\n"
        ++ "Connection: Closed\n\n<html><body>"
        ++ "<h1>Hello, World!</h1></body></html>"
    );
    _ = try conn.stream.write(message);
}

pub fn send_404(conn: Connection) !void {
    const message = (
        "HTTP/1.1 404 Not Found\nContent-Length: 50"
        ++ "\nContent-Type: text/html\n"
        ++ "Connection: Closed\n\n<html><body>"
        ++ "<h1>File not found!</h1></body></html>"
    );
    _ = try conn.stream.write(message);
}
```

注意两个函数都接收连接对象作为输入，并使用`write()`方法将HTTP响应消息直接写入这个通信通道。结果，连接另一端的一方（即客户端）将接收这样的消息。

大多数现实世界的HTTP服务器将有一个函数（或一个结构体）来有效处理响应。它接收已经解析的HTTP请求作为输入，然后，它尝试逐位构建HTTP响应，然后函数通过连接发送它。

我们还会有一个专门的结构体来表示HTTP响应，以及许多用于构建响应对象的每个部分或组件的方法。以Javascript运行时Bun创建的`Response`结构体为例。你可以在他们的GitHub项目的[`response.zig`模块](https://github.com/oven-sh/bun/blob/main/src/bun.js/webcore/response.zig)中找到这个结构体。

## 最终结果

我们现在可以再次更新我们的`main()`函数，以合并来自`response.zig`模块的新函数。首先，我需要将这个模块导入到我们的`main.zig`模块中，然后，我添加对`send_200()`和`send_404()`的函数调用。

注意我使用if语句来决定调用哪个"响应函数"，特别是基于HTTP请求中存在的URI。如果用户请求的内容（或文档）不在我们的服务器中，我们应该响应404状态代码。但由于我们只有一个简单的HTTP服务器，没有真正的文档要发送，我们可以只检查URI是否是根路径（`/`）来决定调用哪个函数。

另外，注意我使用Zig标准库中的函数`std.mem.eql()`来检查`uri`中的字符串是否等于字符串`"/"`。我们已经在[第1.8.5节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-strings-useful-funs)中描述了这个函数，所以，如果你还不熟悉这个函数，请回到那一节。

```zig
const std = @import("std");
const SocketConf = @import("config.zig");
const Request = @import("request.zig");
const Response = @import("response.zig");
const Method = Request.Method;
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const socket = try SocketConf.Socket.init();
    try stdout.print("Server Addr: {any}\n", .{socket._address});
    try stdout.flush();
    var server = try socket._address.listen(.{});
    const connection = try server.accept();

    var buffer: [1000]u8 = undefined;
    for (0..buffer.len) |i| {
        buffer[i] = 0;
    }
    try Request.read_request(connection, buffer[0..buffer.len]);
    const request = Request.parse_request(
        buffer[0..buffer.len]
    );
    if (request.method == Method.GET) {
        if (std.mem.eql(u8, request.uri, "/")) {
            try Response.send_200(connection);
        } else {
            try Response.send_404(connection);
        }
    }
}
```

现在我们调整了`main()`函数，我现在可以执行我们的程序，并查看这些最后更改的效果。首先，我再次使用`zig`编译器的`run`命令执行程序。程序将挂起，等待客户端连接。

然后，我打开我的网络浏览器，并尝试使用URL `localhost:3490`再次连接到服务器。这次，你不会从浏览器得到某种错误消息，而是会在你的网络浏览器中打印"Hello World"消息。因为这次，服务器成功地向网络浏览器发送了HTTP响应，如[图7.3](https://pedropark99.github.io/zig-book/Chapters/04-http-server.html#fig-print-zigrun3)所示。

![图片3](https://pedropark99.github.io/zig-book/Figures/print-zigrun3.png)

图7.3：在HTTP响应中发送的Hello World消息

---

脚注翻译：

1. [https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview](https://developer.mozilla.org/en-US/docs/Web/HTTP/Overview)
2. 它也可以是IPv6地址。但通常，我们为此使用IPv4地址。
3. [https://en.wikipedia.org/wiki/Media_type](https://en.wikipedia.org/wiki/Media_type)
4. [https://github.com/oven-sh/bun/blob/main/src/bun.js/webcore/response.zig](https://github.com/oven-sh/bun/blob/main/src/bun.js/webcore/response.zig)
