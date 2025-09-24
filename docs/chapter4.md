# 第4章 项目1 - 构建base64编码器/解码器 - Zig语言入门

作为我们的第一个小项目，我想和你一起实现一个base64编码器/解码器。Base64是一种将二进制数据转换为文本的编码系统。网络的很大一部分使用base64向只能读取文本数据的系统传递二进制数据。

base64的现代用例最常见的例子基本上是任何电子邮件系统，如GMail、Outlook等。因为电子邮件系统通常使用简单邮件传输协议（SMTP），这是一个仅支持文本数据的网络协议。因此，如果你出于任何原因需要在电子邮件中作为附件发送二进制文件（例如PDF或Excel文件），这些二进制文件通常在包含到SMTP消息之前会被转换为base64。因此，base64编码在这些电子邮件系统中被广泛用于将二进制数据包含到SMTP消息中。

## base64算法是如何工作的？

但base64编码背后的算法究竟是如何工作的？让我们讨论一下。首先，我将解释base64刻度，这是作为base64编码系统基础的64字符刻度。

之后，我解释base64编码器背后的算法，这是负责将消息编码成base64编码系统的算法部分。然后，我解释base64解码器背后的算法，这是负责将base64消息转换回其原始含义的算法部分。

如果你不确定"编码器"和"解码器"之间的区别，请查看[第4.2节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-encode-vs-decode)。

### base64刻度

base64编码系统基于一个从0到63的刻度（因此得名）。这个刻度中的每个索引都由一个字符表示（这是一个64个字符的刻度）。因此，为了将一些二进制数据转换为base64编码，我们需要将每个二进制数字转换为这个"64字符刻度"中的相应字符。

base64刻度从所有ASCII大写字母（A到Z）开始，它们代表这个刻度中的前25个索引（0到25）。之后，我们有所有ASCII小写字母（a到z），它们代表刻度中的范围26到51。之后，我们有一位数数字（0到9），它们代表刻度中从52到61的索引。最后，刻度中的最后两个索引（62和63）分别由字符`+`和`/`表示。

这些是组成base64刻度的64个字符。等号字符（`=`）不是刻度本身的一部分，但它是base64编码系统中的特殊字符。这个字符仅用作后缀，用于标记字符序列的结束，或标记序列中有意义字符的结束。

下面的要点总结了base64刻度：

* 范围0到25由以下表示：ASCII大写字母 `-> [A-Z]`；
* 范围26到51由以下表示：ASCII小写字母 `-> [a-z]`；
* 范围52到61由以下表示：一位数数字 `-> [0-9]`；
* 索引62和63分别由字符`+`和`/`表示；
* 字符`=`表示序列中有意义字符的结束；

### 创建刻度作为查找表

在代码中表示这个刻度的最佳方法是将其表示为**查找表**。查找表是计算机科学中加速计算的经典策略。基本思想是用基本的数组索引操作替换运行时计算（可能需要很长时间才能完成）。

与其每次需要时计算结果，不如一次计算所有可能的结果，然后将它们存储在一个数组中（它的行为类似于"表"）。然后，每次你需要使用base64刻度中的一个字符时，你只需从存储了base64刻度中所有可能字符的数组中检索这个字符，而不是使用许多资源来计算要使用的确切字符。我们直接从内存中检索我们需要的字符。

我们可以开始构建一个Zig结构体来存储我们的base64解码器/编码器逻辑。我们从下面的`Base64`结构体开始。目前，我们在这个结构体中只有一个数据成员，即成员`_table`，它代表我们的查找表。我们还有一个`init()`方法，用于创建`Base64`对象的新实例，以及一个`_char_at()`方法，它是一个"获取索引处的字符"类型的函数。

```zig
const Base64 = struct {
    _table: *const [64]u8,

    pub fn init() Base64 {
        const upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        const lower = "abcdefghijklmnopqrstuvwxyz";
        const numbers_symb = "0123456789+/";
        return Base64{
            ._table = upper ++ lower ++ numbers_symb,
        };
    }

    pub fn _char_at(self: Base64, index: usize) u8 {
        return self._table[index];
    }
};
```

换句话说，`_char_at()`方法负责获取查找表中（即`_table`结构体数据成员）对应于"base64刻度"中特定索引的字符。因此，在下面的例子中，我们知道对应于"base64刻度"中索引28的字符是字符"c"。

```zig
const base64 = Base64.init();
try stdout.print(
    "Character at index 28: {c}\n",
    .{base64._char_at(28)}
);
try stdout.flush();
```

`Character at index 28: c`

### base64编码器

base64编码器背后的算法通常在3字节的窗口上工作。因为每个字节有8位，所以3字节形成24位的集合。这对base64算法来说是理想的，因为24位可被6整除，形成4组，每组6位。

因此，base64算法通过一次将3个字节转换为base64刻度中的4个字符来工作。它不断遍历输入字符串，一次3个字节，并将它们转换为base64刻度，每次迭代产生4个字符。它不断迭代，并产生这些"新字符"，直到到达输入字符串的末尾。

现在你可能会想，如果你有一个特定的字符串，其字节数不能被3整除会发生什么？例如，如果你有一个只包含两个字符/字节的字符串，如"Hi"。算法在这种情况下会如何表现？你可以在[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)中找到答案。你可以在[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)中看到，字符串"Hi"转换为base64后变成字符串"SGk="：

![图片1](https://pedropark99.github.io/zig-book/Figures/base64-encoder-flow.png)

图4.1：base64编码器背后的逻辑

以字符串"Hi"为例，我们有2个字节，或者说总共16位。因此，我们缺少一个完整的字节（8位）来完成base64算法喜欢工作的24位窗口。算法做的第一件事是检查如何将输入字节划分为6位组。

如果算法注意到有一个6位组不完整，意味着这个组包含n位，其中n < 6，

算法只是在这个组中添加额外的零来填充它需要的空间。这就是为什么在[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)中，在6位转换后的第三组中，添加了2个额外的零来填补空白。

当我们有一个不完全满的6位组，如第三组，会添加额外的零来填补空白。但是当整个6位组为空，或者它根本不存在时呢？这是[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)中展示的第四个6位组的情况。

这第四组是必要的，因为算法在4组6位上工作。但输入字符串没有足够的字节来创建第四个6位组。每当发生这种情况，即整个6位组为空时，这个组就变成了"填充组"。每个"填充组"都映射到字符`=`（等号），它代表"空"，或序列中有意义字符的结束。因此，每当算法产生一个"填充组"时，这个组会自动映射到`=`。

作为另一个例子，如果你将字符串"0"作为输入给base64编码器，这个字符串被转换成base64序列"MA=="。字符"0"在二进制中是序列`00110000`。因此，通过[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)中展示的6位转换，这个单个字符将产生这两个6位组：`001100`、`000000`。剩余的两个6位组变成"填充组"。这就是为什么输出序列（MA==）中的最后两个字符是`==`。

### base64解码器

base64解码器背后的算法本质上是base64编码器的逆过程。base64解码器需要将base64消息转换回其原始含义，即转换回原始的二进制数据序列。

base64解码器通常在4字节的窗口上工作。因为它想将这4个字节转换回由base64编码器转换为4组6位的原始3字节序列。记住，在base64解码器中，我们本质上是在恢复base64编码器所做的过程。

输入字符串（base64编码的字符串）中的每个字节通常有助于在输出（原始二进制数据）中重新创建两个不同的字节。换句话说，从base64解码器出来的每个字节都是通过将输入中的两个不同字节合并转换而创建的。你可以在[图4.2](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo2)中可视化这种关系：

![图片2](https://pedropark99.github.io/zig-book/Figures/base64-decoder-flow.png)

图4.2：base64解码器背后的逻辑

对输入中的每个字节应用的确切转换，或确切步骤，以将它们转换为输出的字节，在像这样的图中有点难以可视化。因此，我在图中将这些转换总结为"一些位移和加法..."。这些转换将在后面详细描述。

除此之外，如果你再次查看[图4.2](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo2)，你会注意到字符`=`被算法完全忽略了。记住，这只是一个特殊字符，标记base64序列中有意义字符的结束。因此，base64编码序列中的每个`=`字符都应该被base64解码器忽略。

## 编码和解码之间的区别

如果你之前没有使用base64的经验，你可能不理解"编码"和"解码"之间的区别。本质上，这里的术语"编码"和"解码"具有与加密领域中完全相同的含义（即，它们与哈希算法（如MD5算法）中的"编码"和"解码"意思相同）。

因此，"编码"意味着我们想要编码，或者换句话说，我们想要将某些消息转换成base64编码系统。我们想要产生在base64编码系统中表示这个原始消息的base64字符序列。

相反，"解码"代表逆过程。我们想要解码，或者换句话说，将base64消息转换回其原始内容。因此，在这个过程中，我们获得一个base64字符序列作为输入，并产生作为输出，由这个base64字符序列表示的二进制数据。

任何base64库通常由这两部分组成：1）编码器，这是一个将任何二进制数据序列编码（即转换）为base64字符序列的函数；2）解码器，这是一个将base64字符序列转换回原始二进制数据序列的函数。

## 计算输出的大小

我们需要做的一项任务是计算需要为输出（编码器和解码器的输出）保留多少空间。这是简单的数学，并且可以在Zig中轻松完成，因为每个数组都可以通过查询数组的`.len`属性轻松访问其长度（元素数量）。

对于编码器，逻辑如下：对于我们在输入中找到的每3个字节，在输出中创建4个新字节。因此，我们取输入中的字节数，除以3，使用向上取整函数，然后将结果乘以4。这样，我们就得到了编码器在其输出中将产生的字节总数。

下面的`_calc_encode_length()`函数封装了这个逻辑。在这个函数内部，我们取输入数组的长度，除以3，并使用Zig标准库中的`divCeil()`函数对结果应用向上取整操作。最后，我们将最终结果乘以4得到我们需要的答案。

另外，你可能已经注意到，如果输入长度小于3字节，那么编码器的输出长度总是4字节。这对于少于3字节的每个输入都是如此，因为正如我在[第4.1.3节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-base64-encoder-algo)中描述的，算法总是在最终结果中产生足够的"填充组"来完成4字节窗口。

```zig
const std = @import("std");
fn _calc_encode_length(input: []const u8) !usize {
    if (input.len < 3) {
        return 4;
    }
    const n_groups: usize = try std.math.divCeil(
        usize, input.len, 3
    );
    return n_groups * 4;
}
```

现在，计算解码器输出长度的逻辑稍微复杂一些。但基本上只是我们用于编码器的逻辑的逆：输入中的每4个字节，解码器的输出中将产生3个字节。然而，这次我们需要考虑`=`字符，正如我们在[第4.1.4节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-base64-decoder-algo)和[图4.2](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo2)中描述的，它总是被解码器忽略。

本质上，我们取输入的长度并除以4，然后对结果应用向下取整函数，然后将结果乘以3，然后从结果中减去字符`=`在输入中出现的次数。

下面展示的函数`_calc_decode_length()`总结了我们描述的这个逻辑。它类似于函数`_calc_encode_length()`。注意除法部分是扭曲的。还要注意，这次我们使用`divFloor()`函数对除法的输出应用向下取整操作（而不是使用`divCeil()`的向上取整操作）。

```zig
const std = @import("std");
fn _calc_decode_length(input: []const u8) !usize {
    if (input.len < 4) {
        return 3;
    }

    const n_groups: usize = try std.math.divFloor(
        usize, input.len, 4
    );
    var multiple_groups: usize = n_groups * 3;
    var i: usize = input.len - 1;
    while (i > 0) : (i -= 1) {
        if (input[i] == '=') {
            multiple_groups -= 1;
        } else {
            break;
        }
    }

    return multiple_groups;
}
```

## 构建编码器逻辑

在本节中，我们可以开始构建`encode()`函数背后的逻辑，它将负责将消息编码成base64编码系统。如果你是一个急性子的人，想现在就看到这个base64编码器/解码器实现的完整源代码，你可以在本书官方仓库的`ZigExamples`文件夹中找到它。

### 6位转换

[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)中展示的6位转换是base64编码器算法的核心部分。通过理解这种转换是如何在代码中进行的，算法的其余部分变得更容易理解。

本质上，这种6位转换是在位运算符的帮助下进行的。位运算符对于在位级别完成的任何类型的低级操作都是必不可少的。对于base64算法的特定情况，使用了_向左位移_（`<<`）、_向右位移_（`>>`）和_按位与_（`&`）运算符。它们是6位转换的核心解决方案。

在这个转换中，我们需要考虑3种不同的场景。首先，是完美的场景，我们有完美的3字节窗口可以工作。第二，我们有只有两个字节的窗口可以工作的场景。最后，我们有只有一个字节的窗口的场景。

在这3种场景中的每一种，6位转换的工作方式略有不同。为了使解释更容易，我将使用变量`output`来指代base64编码器输出中的字节，使用变量`input`来指代编码器输入中的字节。

因此，如果你有完美的3字节窗口，这些是6位转换的步骤：

1. `output[0]`是通过将`input[0]`的位向右移动两个位置产生的。
2. `output[1]`是通过求和两个组件产生的。首先，取`input[0]`的最后两位，然后将它们向左移动四个位置。第二，将`input[1]`的位向右移动四个位置。将这两个组件相加。
3. `output[2]`是通过求和两个组件产生的。首先，取`input[1]`的最后四位，然后将它们向左移动两个位置。第二，将`input[2]`的位向右移动六个位置。将这两个组件相加。
4. `output[3]`是通过取`input[2]`的最后六位产生的。

这是完美的场景，我们有完整的3字节窗口可以工作。为了使事情尽可能清楚，[图4.3](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-encoder-bitshift)直观地演示了上面提到的步骤2是如何工作的。因此，编码器`output`中的第2个字节是通过取输入中的第1个字节（深紫色）和第2个字节（橙色）制成的。你可以看到，在过程结束时，我们得到一个新字节，其中包含`input`中第1个字节的最后2位，以及`input`中第2个字节的前4位。

![图片3](https://pedropark99.github.io/zig-book/Figures/base64-encoder-bit-shift.png)

图4.3：编码器输出中的第2个字节是如何从输入的第1个字节（深紫色）和第2个字节（橙色）产生的。

另一方面，我们必须为没有完美的3字节窗口的情况做好准备。如果你有2字节的窗口，那么，产生字节`output[2]`和`output[3]`的步骤3和4会稍微改变，它们变成：

* `output[2]`是通过取`input[1]`的最后4位，然后将它们向左移动两个位置产生的。
* `output[3]`是字符`'='`。

最后，如果你有单个字节的窗口，那么，产生字节`output[1]`、`output[2]`和`output[3]`的步骤2到4会改变，变成：

* `output[1]`是通过取`input[0]`的最后两位，然后将它们向左移动四个位置产生的。
* `output[2]`和`output[3]`是字符`=`。

如果这些要点对你来说有点混乱，你可能会发现[表4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#tbl-transf-6bit)更直观。这个表将所有这些逻辑统一到一个简单的表中。注意，这个表还提供了在Zig中创建输出中相应字节的确切表达式。

表4.1：6位转换如何在不同窗口设置中转换为代码。

| 窗口中的字节数 | 输出中的字节索引 | 代码中 |
| --- | --- | --- |
| 3 | 0 | input[0] >> 2 |
| 3 | 1 | ((input[0] & 0x03) << 4) + (input[1] >> 4) |
| 3 | 2 | ((input[1] & 0x0f) << 2) + (input[2] >> 6) |
| 3 | 3 | input[2] & 0x3f |
| 2 | 0 | input[0] >> 2 |
| 2 | 1 | ((input[0] & 0x03) << 4) + (input[1] >> 4) |
| 2 | 2 | ((input[1] & 0x0f) << 2) |
| 2 | 3 | '=' |
| 1 | 0 | input[0] >> 2 |
| 1 | 1 | ((input[0] & 0x03) << 4) |
| 1 | 2 | '=' |
| 1 | 3 | '=' |

### Zig中的位移

Zig中的位移工作方式类似于C中的位移。C中存在的所有位运算符在Zig中都可用。在这里，在base64编码器算法中，它们对于产生我们想要的结果至关重要。

对于那些不熟悉这些运算符的人，它们是在你的值的位级别操作的运算符。这意味着这些运算符获取形成你拥有的值的位，并以某种方式改变它们。这最终也会改变值本身，因为这个值的二进制表示发生了变化。

我们已经在[图4.3](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-encoder-bitshift)中看到了位移产生的效果。但让我们使用base64编码器输出中的第一个字节作为位移含义的另一个例子。这是输出中4个字节中最容易构建的字节。因为我们只需要使用_向右位移_（`>>`）运算符将输入中第一个字节的位向右移动两个位置。

如果我们以[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)中使用的字符串"Hi"为例，这个字符串中的第一个字节是"H"，在二进制中是序列`01001000`。如果我们将这个字节的位向右移动两个位置，我们得到序列`00010010`作为结果。这个二进制序列是十进制的值`18`，也是十六进制的值`0x12`。注意"H"的前6位被移动到了字节的末尾。通过这个操作，我们得到了输出的第一个字节。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;
pub fn main() !void {
    const input = "Hi";
    try stdout.print("{d}\n", .{input[0] >> 2});
    try stdout.flush();
}
```

`18`

如果你回想[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)，输出中的第一个字节应该等同于6位组`010010`。虽然在视觉上不同，但序列`010010`和`00010010`在语义上是相等的。它们意味着同样的事情。它们都代表十进制的数字18，以及十六进制的值`0x12`。

因此，不要太认真地对待"6位组"因素。我们不一定需要得到6位序列作为结果。只要我们得到的8位序列的含义与6位序列相同，我们就没有问题。

### 使用`&`运算符选择特定位

如果你回到[第4.4.1节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-6bit-transf)，你会看到，为了产生输出中的第二个和第三个字节，我们需要从输入字符串中的第一个和第二个字节中选择特定的位。但我们怎么做呢？答案依赖于_按位与_（`&`）运算符。

[图4.3](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-encoder-bitshift)已经向你展示了这个`&`运算符在其操作数的位上产生的效果。但让我们对它做一个清晰的描述。

总之，`&`运算符在其操作数的位之间执行逻辑合取操作。更详细地说，运算符`&`将第一个操作数的每一位与第二个操作数的相应位进行比较。如果两个位都是1，则相应的结果位设置为1。否则，相应的结果位设置为0（[Microsoft 2021](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-microsoftbitwiseand)）。

因此，如果我们将这个运算符应用于二进制序列`1000100`和`00001101`，这个操作的结果是二进制序列`00000100`。因为只有在两个二进制序列的第六个位置我们都有1值。因此，在两个二进制序列都没有设置为1的任何位置，我们在结果二进制序列中得到0位。

在这种情况下，我们丢失了两个序列中原始位值的信息。因为我们不再知道结果二进制序列中的这个0位是通过组合0与0、或1与0、或0与1产生的。

作为一个例子，假设你有二进制序列`10010111`，它是十进制的数字151。我们如何获得一个只包含这个序列的第三和第四位的新二进制序列？

我们只需要使用`&`运算符将这个序列与`00110000`（十六进制是`0x30`）组合。注意只有这个二进制序列中的第三和第四个位置设置为1。因此，只有两个二进制序列的第三和第四个值可能在输出中保留。输出序列中的所有其余位置都设置为零，即`00010000`（十进制是数字16）。

```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const bits = 0b10010111;
    try stdout.print("{d}\n", .{bits & 0b00110000});
    try stdout.flush();
}
```

`16`

### 为输出分配空间

正如我在[第3.1.4节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-stack)中描述的，要在栈上存储对象，这个对象需要在编译时有已知和固定的长度。这是我们base64编码器/解码器案例的一个重要限制。因为输出的大小（编码器和解码器的输出）直接取决于输入的大小。

考虑到这一点，我们无法在编译时知道编码器和解码器的输出大小。因此，如果我们无法在编译时知道输出的大小，这意味着我们无法在栈上存储编码器和解码器的输出。

因此，我们需要将这个输出存储在堆上，正如我在[第3.1.5节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-heap)中评论的，我们只能通过使用分配器对象在堆上存储对象。因此，`encode()`和`decode()`函数的参数之一需要是一个分配器对象，因为我们肯定知道，在这些函数体内的某个点，我们需要在堆上分配空间来存储这些函数的输出。

这就是为什么我在本书中介绍的`encode()`和`decode()`函数都有一个名为`allocator`的参数，它接收一个分配器对象作为输入，由Zig标准库中的类型`std.mem.Allocator`标识。

### 编写`encode()`函数

现在我们对位运算符的工作原理有了基本的了解，以及它们如何帮助我们实现我们想要实现的结果。我们现在可以将我们在[图4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo1)和[表4.1](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#tbl-transf-6bit)中描述的所有逻辑封装到一个漂亮的函数中，我们可以将其添加到我们在[第4.1.2节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-base64-table)中开始的`Base64`结构体定义中。

你可以在下面找到`encode()`函数。注意这个函数的第一个参数是`Base64`结构体本身。因此，这个参数清楚地表明这个函数是`Base64`结构体的一个方法。

因为`encode()`函数本身相当长，为了简洁起见，我在这个源代码中故意省略了`Base64`结构体定义。所以，只需记住这个函数是`Base64`结构体的公共函数（或公共方法）。

此外，这个`encode()`函数还有两个其他参数：

1. `input`是你想要编码成base64的输入字符序列；
2. `allocator`是用于必要内存分配的分配器对象。

我在[第3.3节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-allocators)中描述了你需要了解的关于分配器对象的一切。因此，如果你不熟悉它们，我强烈建议你回到那一节并阅读它。通过查看`encode()`函数，你会看到我们使用这个分配器对象来分配足够的内存来存储编码过程的输出。

函数中的主for循环负责遍历整个输入字符串。在每次迭代中，我们使用`count`变量来计算当前有多少次迭代。当`count`达到3时，我们尝试编码我们在临时缓冲区对象（`buf`）中累积的3个字符（或字节）。

在编码这3个字符并将结果存储在`output`变量中后，我们将`count`变量重置为零，并在循环的下一次迭代中再次开始计数。如果循环到达字符串的末尾，并且`count`变量小于3，那么，这意味着临时缓冲区包含输入的最后1或2个字节。这就是为什么我们在for循环之后有两个`if`语句。处理每种可能的情况。

```zig
pub fn encode(self: Base64,
              allocator: std.mem.Allocator,
              input: []const u8) ![]u8 {

    if (input.len == 0) {
        return "";
    }

    const n_out = try _calc_encode_length(input);
    var out = try allocator.alloc(u8, n_out);
    var buf = [3]u8{ 0, 0, 0 };
    var count: u8 = 0;
    var iout: u64 = 0;

    for (input, 0..) |_, i| {
        buf[count] = input[i];
        count += 1;
        if (count == 3) {
            out[iout] = self._char_at(buf[0] >> 2);
            out[iout + 1] = self._char_at(
                ((buf[0] & 0x03) << 4) + (buf[1] >> 4)
            );
            out[iout + 2] = self._char_at(
                ((buf[1] & 0x0f) << 2) + (buf[2] >> 6)
            );
            out[iout + 3] = self._char_at(buf[2] & 0x3f);
            iout += 4;
            count = 0;
        }
    }

    if (count == 1) {
        out[iout] = self._char_at(buf[0] >> 2);
        out[iout + 1] = self._char_at(
            (buf[0] & 0x03) << 4
        );
        out[iout + 2] = '=';
        out[iout + 3] = '=';
    }

    if (count == 2) {
        out[iout] = self._char_at(buf[0] >> 2);
        out[iout + 1] = self._char_at(
            ((buf[0] & 0x03) << 4) + (buf[1] >> 4)
        );
        out[iout + 2] = self._char_at(
            (buf[1] & 0x0f) << 2
        );
        out[iout + 3] = '=';
        iout += 4;
    }

    return out;
}
```

## 构建解码器逻辑

现在，我们可以专注于编写base64解码器逻辑。记住[图4.2](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-base64-algo2)，base64解码器执行编码器的逆过程。因此，我们需要做的就是编写一个`decode()`函数，执行我在[第4.4节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-encoder-logic)中展示的逆过程。

### 将base64字符映射到它们的索引

为了解码base64编码的消息，我们需要做的一件事是计算我们在解码器输入中遇到的每个base64字符在base64刻度中的索引。

换句话说，解码器接收作为输入的base64字符序列。我们需要将这个字符序列转换为索引序列。这些索引是每个字符在base64刻度中的索引。这样，我们就得到了在编码器过程的6位转换步骤中计算的值/字节。

可能有更好/更快的方法来计算这个，特别是使用"分而治之"类型的策略。但现在，我对简单的"暴力"类型的策略感到满意。下面的`_char_index()`函数包含这个策略。

我们本质上是循环遍历带有base64刻度的_查找表_，并将我们得到的字符与base64刻度中的每个字符进行比较。如果这些字符匹配，那么，我们返回这个字符在base64刻度中的索引作为结果。

注意，如果输入字符是`'='`，函数返回索引64，这在刻度中是"超出范围"的。但是，正如我在[第4.1.1节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-base64-scale)中描述的，字符`'='`不属于base64刻度本身。它是base64中的特殊且无意义的字符。

还要注意，这个`_char_index()`函数是我们`Base64`结构体的一个方法，因为有`self`参数。再次，出于简洁的原因，我在这个例子中省略了`Base64`结构体定义。

```zig
fn _char_index(self: Base64, char: u8) u8 {
    if (char == '=')
        return 64;
    var index: u8 = 0;
    for (0..63) |i| {
        if (self._char_at(i) == char)
            break;
        index += 1;
    }

    return index;
}
```

### 6位转换

再一次，算法的核心部分是6位转换。如果我们理解执行这种转换的必要步骤，算法的其余部分就变得容易得多。

首先，在我们实际进行6位转换之前，我们需要确保使用`_char_index()`将base64字符序列转换为索引序列。因此，下面的代码片段对于将要完成的工作很重要。`_char_index()`的结果存储在临时缓冲区中，这个临时缓冲区是我们将在6位转换中使用的，而不是实际的`input`对象。

```zig
for (0..input.len) |i| {
    buf[i] = self._char_index(input[i]);
}
```

现在，base64解码器不是每个输入中的3个字符窗口产生4个字节（或4个字符）作为输出，而是每个输入中的4个字符窗口产生3个字节（或3个字符）作为输出。再一次，是逆过程。

因此，产生输出中3个字节的步骤是：

1. `output[0]`是通过求和两个组件产生的。首先，将`buf[0]`的位向左移动两个位置。第二，将`buf[1]`的位向右移动4个位置。然后，将这两个组件相加。
2. `output[1]`是通过求和两个组件产生的。首先，将`buf[1]`的位向左移动四个位置。第二，将`buf[2]`的位向右移动2个位置。然后，将这两个组件相加。
3. `output[2]`是通过求和两个组件产生的。首先，将`buf[2]`的位向左移动六个位置。然后，你将结果与`buf[3]`相加。

在我们继续之前，让我们尝试可视化这些转换如何产生我们在编码过程之前拥有的原始字节。首先，回想一下[第4.4节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-encoder-logic)中展示的编码器执行的6位转换。编码器输出中的第一个字节是通过将输入中第一个字节的位向右移动两个位置产生的。

例如，如果编码器输入中的第一个字节是序列`ABCDEFGH`，那么，编码器输出中的第一个字节将是`00ABCDEF`（这个序列将是解码器输入中的第一个字节）。现在，如果编码器输入中的第二个字节是序列`IJKLMNOP`，那么，编码器输出中的第二个字节将是`00GHIJKL`（正如我们在[图4.3](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-encoder-bitshift)中演示的）。

因此，如果序列`00ABCDEF`和`00GHIJKL`分别是解码器输入中的第一个和第二个字节，[图4.4](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#fig-decoder-bitshift)直观地演示了这两个字节如何转换为解码器输出的第一个字节。注意输出字节是序列`ABCDEFGH`，这是编码器输入的原始字节。

![图片4](https://pedropark99.github.io/zig-book/Figures/base64-decoder-bit-shift.png)

图4.4：解码器输出中的第1个字节是如何从输入的第1个字节（深紫色）和第2个字节（橙色）产生的

[表4.2](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#tbl-6bit-decode)展示了前面描述的三个步骤如何转换为Zig代码：

表4.2：解码过程中6位转换的必要步骤。

| 输出中的字节索引 | 代码中 |
| --- | --- |
| 0 | (buf[0] << 2) + (buf[1] >> 4) |
| 1 | (buf[1] << 4) + (buf[2] >> 2) |
| 2 | (buf[2] << 6) + buf[3] |

### 编写`decode()`函数

下面的`decode()`函数包含整个解码过程。我们首先使用`_calc_decode_length()`计算输出的大小，然后，我们使用分配器对象为这个输出分配足够的内存。

创建了三个临时变量：1）`count`，用于保存for循环每次迭代中的窗口计数；2）`iout`，用于保存输出中的当前索引；3）`buf`，这是保存要通过6位转换转换的base64索引的临时缓冲区。

然后，在for循环的每次迭代中，我们用当前字节窗口填充临时缓冲区。当`count`达到数字4时，我们在`buf`中有一个完整的索引窗口要转换，然后，我们对临时缓冲区应用6位转换。

注意，我们检查临时缓冲区中的索引2和3是否是数字64，如果你从[第4.5.1节](https://pedropark99.github.io/zig-book/Chapters/01-base64.html#sec-map-base64-index)回忆，这是当`_calc_index()`函数接收`'='`字符作为输入时。因此，如果这些索引等于数字64，`decode()`函数知道它可以简单地忽略这些索引。它们不被转换，因为正如我之前描述的，字符`'='`没有意义，尽管是序列中有意义字符的结束。所以当它们出现在序列中时，我们可以安全地忽略它们。

```zig
fn decode(self: Base64,
          allocator: std.mem.Allocator,
          input: []const u8) ![]u8 {

    if (input.len == 0) {
        return "";
    }
    const n_output = try _calc_decode_length(input);
    var output = try allocator.alloc(u8, n_output);
    var count: u8 = 0;
    var iout: u64 = 0;
    var buf = [4]u8{ 0, 0, 0, 0 };

    for (0..input.len) |i| {
        buf[count] = self._char_index(input[i]);
        count += 1;
        if (count == 4) {
            output[iout] = (buf[0] << 2) + (buf[1] >> 4);
            if (buf[2] != 64) {
                output[iout + 1] = (buf[1] << 4) + (buf[2] >> 2);
            }
            if (buf[3] != 64) {
                output[iout + 2] = (buf[2] << 6) + buf[3];
            }
            iout += 3;
            count = 0;
        }
    }

    return output;
}
```

## 最终结果

现在我们已经实现了`decode()`和`encode()`。我们在Zig中实现了一个完全功能的base64编码器/解码器。这是我们实现的带有`encode()`和`decode()`方法的`Base64`结构体的使用示例。

```zig
var memory_buffer: [1000]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(
    &memory_buffer
);
const allocator = fba.allocator();

const text = "Testing some more stuff";
const etext = "VGVzdGluZyBzb21lIG1vcmUgc3R1ZmY=";
const base64 = Base64.init();
const encoded_text = try base64.encode(
    allocator, text
);
const decoded_text = try base64.decode(
    allocator, etext
);
try stdout.print(
    "Encoded text: {s}\n", .{encoded_text}
);
try stdout.print(
    "Decoded text: {s}\n", .{decoded_text}
);
try stdout.flush();
```

```
Encoded text: VGVzdGluZyBzb21lIG1vcmUgc3R1ZmY=
Decoded text: Testing some more stuff
```

你也可以通过访问本书的官方仓库一次看到完整的源代码。更准确地说，在`ZigExamples`文件夹内。

---

脚注翻译：

1. 注意，字符"0"与实际数字0不同，后者在二进制中只是零。
2. [https://github.com/pedropark99/zig-book/blob/main/ZigExamples/base64/base64_basic.zig](https://github.com/pedropark99/zig-book/blob/main/ZigExamples/base64/base64_basic.zig)
3. [https://github.com/pedropark99/zig-book](https://github.com/pedropark99/zig-book)
4. [https://github.com/pedropark99/zig-book/blob/main/ZigExamples/base64/base64_basic.zig](https://github.com/pedropark99/zig-book/blob/main/ZigExamples/base64/base64_basic.zig)
