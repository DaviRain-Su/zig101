# 第15章 项目4 - 开发图像滤镜 - Zig入门介绍

在本章中，我们将构建一个新项目。这个项目的目标是编写一个对图像应用滤镜的程序。更具体地说，是一个"灰度滤镜"，它将任何彩色图像转换为灰度图像。

我们将在这个项目中使用[图15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal)中显示的图像。换句话说，我们想通过使用我们用Zig编写的"图像滤镜程序"将这个彩色图像转换为灰度图像。

![图片1](https://pedropark99.github.io/zig-book/ZigExamples/image_filter/pedro_pascal.png)

图15.1：智利裔美国演员佩德罗·帕斯卡的照片。来源：谷歌图片。

我们不需要编写大量代码来构建这样的"图像滤镜程序"。然而，我们首先需要了解数字图像是如何工作的。这就是为什么我们在本章开始时解释数字图像背后的理论以及颜色在现代计算机中是如何表示的。我们还简要解释了PNG（便携式网络图形）文件格式，这是示例图像中使用的格式。

在本章结束时，我们应该有一个完整的程序示例，它将[图15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal)中显示的PNG图像作为输入，并将该输入图像的灰度版本写入当前工作目录。[图15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal)的灰度版本显示在[图15.2](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal-gray)中。你可以在[本书官方仓库的`ZigExamples/image_filter`文件夹](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/image_filter)中找到这个小项目的完整源代码。

![图片2](https://pedropark99.github.io/zig-book/ZigExamples/image_filter/pedro_pascal_filter.png)

图15.2：照片的灰度版本。

## 我们如何看到事物？

在本节中，我想简要描述一下我们（人类）实际上是如何用自己的眼睛看到事物的。我的意思是，我们的眼睛是如何工作的？如果你对我们眼睛的工作原理有非常基本的了解，你将更容易理解数字图像是如何制作的。因为数字图像背后的技术在很大程度上受到了我们人眼工作方式的启发。

你可以将人眼解释为光传感器或光接收器。眼睛接收一定量的光作为输入，并解释这"一定量的光"中存在的颜色。如果没有光线照射到眼睛，那么眼睛就无法从中提取颜色，结果，我们最终什么也看不到，或者更准确地说，我们看到的是完全的黑暗。

因此，一切都取决于光。我们实际看到的是从照射到我们眼睛的光中反射出来的颜色（蓝色、红色、橙色、绿色、紫色、黄色等）。**光是所有颜色的来源！**这就是艾萨克·牛顿在1660年代他著名的棱镜实验中发现的。

在我们的眼睛内部，我们有一种特定类型的细胞，称为"视锥细胞"。我们的眼睛有三种不同类型，或者说三种不同版本的这些"视锥细胞"。每种类型的视锥细胞对光的特定光谱非常敏感。更具体地说，对定义红色、绿色和蓝色的光谱。所以，总的来说，我们的眼睛有对这三种颜色（红色、绿色和蓝色）高度敏感的特定类型的细胞。

这些细胞负责感知照射到我们眼睛的光中存在的颜色。因此，我们的眼睛将颜色感知为这三种颜色（红色、绿色和蓝色）的混合。通过拥有这三种颜色中每一种的一定量，并将它们混合在一起，我们可以得到我们想要的任何其他可见颜色。所以我们看到的每种颜色都被感知为蓝色、绿色和红色的特定混合，比如30%的红色，加上20%的绿色，加上50%的蓝色。

当这些视锥细胞感知（或检测）到照射到我们眼睛的光中发现的颜色时，这些细胞产生电信号，这些信号被发送到大脑。我们的大脑解释这些电信号，并使用它们在我们的头脑中形成我们所看到的图像。

基于我们在这里讨论的内容，下面的要点描述了构成我们人眼如何工作的这个非常简化版本的事件序列：

1. 光线照射到我们的眼睛。
2. 视锥细胞感知这束光中存在的颜色。
3. 视锥细胞产生描述在光中感知到的颜色的电信号。
4. 电信号被发送到大脑。
5. 大脑解释这些信号，并根据这些电信号识别的颜色形成图像。

## 数字图像如何工作？

数字图像是我们用眼睛看到的图像的"数字表示"。换句话说，数字图像是我们通过光看到和感知的颜色的"数字表示"。在数字世界中，我们有两种类型的图像，它们是：矢量图像和光栅图像。矢量图像在这里不作描述。所以只要记住这里讨论的内容**仅与光栅图像相关**，而不是矢量图像。

光栅图像是一种数字图像，表示为像素的2D（二维）矩阵。换句话说，每个光栅图像基本上是一个像素矩形，每个像素都有特定的颜色。所以，光栅图像只是一个像素矩形，这些像素中的每一个都在你的计算机屏幕（或任何其他设备的屏幕，例如笔记本电脑、平板电脑、智能手机等）上显示为一种颜色。

[图15.3](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-raster)演示了这个想法。如果你拿任何光栅图像，并大力放大它，你会看到图像的实际像素。JPEG、TIFF和PNG是通常用于存储光栅图像的文件格式。

![图片3](https://pedropark99.github.io/zig-book/Figures/imagem-raster.png)

图15.3：放大光栅图像以查看像素。来源：谷歌图片。

图像拥有的像素越多，我们可以在图像中包含的信息和细节就越多。图像看起来会更准确、更清晰、更漂亮。这就是为什么摄影相机通常会产生大的光栅图像，具有几兆像素的分辨率，以便在最终图像中包含尽可能多的细节。例如，一个尺寸为1920像素宽和1080像素高的数字图像，总共包含2073600个像素。你也可以说图像的"总面积"是2073600像素，尽管"面积"的概念在计算机图形学中并不真正使用。

我们在现代世界中看到的大多数数字图像使用RGB颜色模型。RGB代表（红色、绿色和蓝色）。所以这些光栅图像中每个像素的颜色通常表示为红色、绿色和蓝色的混合，就像在我们的眼睛中一样。也就是说，每个像素的颜色由三个不同的整数值集合标识。每个整数值标识每种颜色（红色、绿色和蓝色）的"数量"。例如，集合`(199, 78, 70)`标识一种更接近红色的颜色。我们有199的红色，78的绿色和70的蓝色。相比之下，集合`(129, 77, 250)`描述了一种更接近紫色的颜色。等等。

### 图像从上到下显示

这不是一个成文的规则，但绝大多数数字图像都是从上到下、从左到右显示的。大多数计算机屏幕也遵循这种模式。因此，图像中的第一个像素是位于图像左上角的像素。你可以在[图15.4](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-img-display)中找到这个逻辑的可视化表示。

还要注意[图15.4](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-img-display)中，因为光栅图像本质上是像素的2D矩阵，图像被组织成像素的行和列。列由水平x轴定义，而行由垂直y轴定义。

[图15.4](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-img-display)中显示的每个像素（即灰色矩形）内部都包含一个数字。这些数字是像素的索引。你可以注意到第一个像素在左上角，而且这些像素的索引"向侧面增长"，或者换句话说，它们在水平x轴的方向上增长。大多数光栅图像都组织为像素行。因此，当这些数字图像显示时，屏幕显示第一行像素，然后是第二行，然后是第三行，等等。

![图片4](https://pedropark99.github.io/zig-book/Figures/image-display.png)

图15.4：光栅图像的像素如何显示。

### 在代码中表示像素矩阵

好的，我们已经知道光栅图像表示为像素的2D矩阵。但我们在Zig中没有2D矩阵的概念。实际上，大多数低级语言（Zig、C、Rust等）通常都没有这样的概念。那么我们如何在Zig或任何其他低级语言中表示这样的像素矩阵呢？大多数程序员在这种情况下选择的策略是使用普通的1D数组来存储这个2D矩阵的值。换句话说，你只需创建一个普通的1D数组，并将两个维度的所有值存储到这个1D数组中。

例如，假设我们有一个尺寸为4x3的非常小的图像。由于光栅图像表示为像素的2D矩阵，每个像素由3个"无符号8位"整数值表示，我们在这个图像中总共有12个像素，它们由36个整数值表示。因此，我们需要创建一个包含36个`u8`值的数组来存储这个小图像。

使用无符号8位整数（`u8`）值来表示每种颜色的数量，而不是任何其他整数类型的原因是，它们占用尽可能少的空间，或者尽可能少的位数。这有助于减少图像的二进制大小，即2D矩阵。此外，它们传达了关于颜色的良好数量的精度和细节，即使它们只能表示相对较小的"颜色数量"范围（从0到255）。

回到我们4x3图像的初始示例，下面暴露的`matrix`对象可能是存储表示这个4x3图像的数据的1D数组的示例。

```zig
const matrix = [_]u8{
    201, 10, 25, 185, 65, 70,
    65, 120, 110, 65, 120, 117,
    98, 95, 12, 213, 26, 88,
    143, 112, 65, 97, 99, 205,
    234, 105, 56, 43, 44, 216,
    45, 59, 243, 211, 209, 54,
};
```

这个数组中的前三个整数值是图像中第一个像素的颜色数量。接下来的三个整数是第二个像素的颜色数量。序列以这种模式继续。考虑到这一点，存储光栅图像的数组的大小通常是3的倍数。在这种情况下，数组的大小为36。

我的意思是，数组的大小**通常**是3的倍数，因为在特定情况下，它也可以是4的倍数。当光栅图像中还包含透明度数量时会发生这种情况。换句话说，有些类型的光栅图像使用不同的颜色模型，即RGBA（红色、绿色、蓝色和alpha）颜色模型。"alpha"对应于像素中的透明度数量。所以RGBA图像中的每个像素都由红色、绿色、蓝色和alpha值表示。

大多数光栅图像使用标准的RGB模型，所以，在大多数情况下，你会看到数组大小是3的倍数。但有些图像，特别是存储在PNG文件中的图像，可能使用RGBA模型，因此，由大小为4的倍数的数组表示。

在我们这里的情况下，我们项目的示例图像（[图15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal)）是存储在PNG文件中的光栅图像，这个特定的图像使用RGBA颜色模型。因此，图像中的每个像素由4个不同的整数值表示，因此，要在我们的Zig代码中存储这个图像，我们需要创建一个大小为4的倍数的数组。

## 我们将要使用的PNG库

让我们通过专注于编写从PNG文件读取数据所需的Zig代码来开始我们的项目。换句话说，我们想读取[图15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal)中显示的PNG文件，并解析其数据以提取表示图像的像素的2D矩阵。

正如我们在[第15.2.2节](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#sec-pixel-repr)中讨论的，我们在这里用作示例的图像是使用RGBA颜色模型的PNG文件，因此，图像的每个像素由4个整数值表示。你可以通过访问[本书官方仓库的`ZigExamples/image_filter`文件夹](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/image_filter)下载这个图像。你还可以在这个文件夹中找到我们在这里开发的这个小项目的完整源代码。

有一些可用的C库可以用来读取和解析PNG文件。最著名和最常用的是`libpng`，它是读取和写入PNG文件的"官方库"。尽管这个库在大多数操作系统上都可用，但它以复杂和难以使用而闻名。

这就是为什么我在这个项目中使用一个更现代的替代方案，即`libspng`库。我选择在这里使用这个C库，因为它比`libpng`简单得多，而且它还为所有操作提供了非常好的性能。你可以查看[库的官方网站](https://libspng.org/)以了解更多信息。你还会在那里找到一些文档，可能会帮助你理解和遵循这里暴露的代码示例。

首先，记得将这个`libspng`构建并安装到你的系统中。因为如果你不执行这一步，`zig`编译器将无法在你的计算机中找到这个库的文件和资源，并将它们与我们在这里一起编写的Zig源代码链接。在[库文档的构建部分](https://libspng.org/docs/build/)有关于如何构建和安装库的良好信息。

## 读取PNG文件

为了从PNG文件中提取像素数据，我们需要读取和解码文件。PNG文件只是以"PNG格式"编写的二进制文件。幸运的是，`libspng`库提供了一个名为`spng_decode_image()`的函数，为我们完成所有这些繁重的工作。

现在，由于`libspng`是一个C库，这个库中的大多数文件和I/O操作都是使用C `FILE`指针进行的。因此，使用`fopen()` C函数打开我们的PNG文件可能是一个更好的主意，而不是使用我在[第13章](https://pedropark99.github.io/zig-book/Chapters/12-file-op.html)中介绍的`openFile()`方法。这就是为什么我在这个项目中导入`stdio.h` C头文件，并使用`fopen()` C函数打开文件。

如果你查看下面的代码片段，你可以看到我们正在：

1. 使用`fopen()`打开PNG文件。
2. 使用`spng_ctx_new()`创建`libspng`上下文。
3. 使用`spng_set_png_file()`指定读取我们将要使用的PNG文件的`FILE`对象。

`libspng`中的每个操作都是通过"上下文对象"进行的。在我们下面的代码片段中，这个对象是`ctx`。此外，要对PNG文件执行操作，我们需要指定我们所指的确切PNG文件。这是`spng_set_png_file()`的工作。我们使用这个函数来指定读取我们想要使用的PNG文件的文件描述符对象。

```zig
const c = @cImport({
    @cDefine("_NO_CRT_STDIO_INLINE", "1");
    @cInclude("stdio.h");
    @cInclude("spng.h");
});

const path = "pedro_pascal.png";
const file_descriptor = c.fopen(path, "rb");
if (file_descriptor == null) {
    @panic("Could not open file!");
}
const ctx = c.spng_ctx_new(0) orelse unreachable;
_ = c.spng_set_png_file(
    ctx, @ptrCast(file_descriptor)
);
```

在我们继续之前，重要的是要强调以下内容：由于我们使用`fopen()`打开了文件，我们必须记住在程序结束时使用`fclose()`关闭文件。换句话说，在我们完成了对PNG文件`pedro_pascal.png`想要做的所有事情之后，我们需要通过对文件描述符对象应用`fclose()`来关闭这个文件。如果我们愿意，我们也可以使用`defer`关键字来帮助我们完成这个任务。下面的代码片段演示了这一步：

```zig
if (c.fclose(file_descriptor) != 0) {
    return error.CouldNotCloseFileDescriptor;
}
```

### 为像素数据分配空间

在我们从PNG文件读取像素数据之前，我们需要分配足够的空间来保存这些数据。但为了分配这样的空间，我们首先需要知道我们需要分配多少空间。图像的尺寸显然需要用来计算这个空间的大小。但还有其他元素也会影响这个数字，比如图像中使用的颜色模型、位深度等。

无论如何，所有这些都意味着计算我们需要的空间大小不是一项简单的任务。这就是为什么`libspng`库提供了一个名为`spng_decoded_image_size()`的实用函数来为我们计算这个大小。再一次，我将把围绕这个C函数的逻辑封装到一个名为`calc_output_size()`的漂亮小Zig函数中。你可以在下面看到，这个函数返回一个漂亮的整数值作为结果，告知我们需要分配的空间大小。

```zig
fn calc_output_size(ctx: *c.spng_ctx) !u64 {
    var output_size: u64 = 0;
    const status = c.spng_decoded_image_size(
        ctx, c.SPNG_FMT_RGBA8, &output_size
    );
    if (status != 0) {
        return error.CouldNotCalcOutputSize;
    }
    return output_size;
}
```

你可能会问自己`SPNG_FMT_RGBA8`值意味着什么。这个值实际上是在`spng.h` C头文件中定义的枚举值。这个枚举用于标识"PNG格式"。更准确地说，它标识使用RGBA颜色模型和8位深度的PNG文件。因此，通过将这个枚举值作为输入提供给`spng_decoded_image_size()`函数，我们告诉这个函数通过考虑遵循这种"具有8位深度的RGBA颜色模型"格式的PNG文件来计算解码像素数据的大小。

有了这个函数，我们可以将它与分配器对象结合使用，分配一个足够大的字节数组（`u8`值）来存储图像的解码像素数据。注意我使用`@memset()`将整个数组初始化为零。

```zig
const output_size = try calc_output_size(ctx);
var buffer = try allocator.alloc(u8, output_size);
@memset(buffer[0..], 0);
```

### 解码图像数据

现在我们有了存储图像解码像素数据所需的空间，我们可以开始使用`spng_decode_image()` C函数实际解码并从图像中提取这个像素数据。

下面暴露的`read_data_to_buffer()` Zig函数总结了读取这个解码像素数据并将其存储到输入缓冲区所需的步骤。注意这个函数封装了围绕`spng_decode_image()`函数的逻辑。此外，我们再次使用`SPNG_FMT_RGBA8`枚举值来通知相应的函数，正在解码的PNG图像使用RGBA颜色模型和8位深度。

```zig
fn read_data_to_buffer(ctx: *c.spng_ctx, buffer: []u8) !void {
    const status = c.spng_decode_image(
        ctx,
        buffer.ptr,
        buffer.len,
        c.SPNG_FMT_RGBA8,
        0
    );

    if (status != 0) {
        return error.CouldNotDecodeImage;
    }
}
```

有了这个函数，我们可以将其应用于我们的上下文对象，以及我们在前一节中分配的用于保存图像解码像素数据的缓冲区对象：

```zig
try read_data_to_buffer(ctx, buffer[0..]);
```

### 查看像素数据

现在我们已经将像素数据存储在我们的"缓冲区对象"中，我们可以快速查看一下字节。在下面的例子中，我们正在查看解码像素数据中的前12个字节。

如果你仔细查看这些值，你可能会注意到序列中每4个字节就是255。巧合的是，255是可以由`u8`值表示的最大可能整数值。所以，如果从0到255的范围（这是可以由`u8`值表示的整数值的范围）可以表示为从0%到100%的刻度，这些255值本质上是该刻度中的100%。

如果你回忆[第15.2.2节](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#sec-pixel-repr)，我在那一节中描述了我们的`pedro_pascal.png` PNG文件使用RGBA颜色模型，它为图像中的每个像素添加了一个alpha（或透明度）字节。因此，图像中的每个像素由4个字节表示。由于我们在这里查看的是图像中的前12个字节，这意味着我们正在查看图像中前3个像素的数据。

因此，基于这前12个字节（或这3个像素）的外观，每4个字节有这些255值，我们可以说图像中的每个像素很可能将alpha（或透明度）设置为100%。这可能不是真的，但这是最可能的可能性。此外，如果我们查看图像本身，如果你回忆的话，它显示在[图15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal)中，我们可以看到透明度在整个图像中没有变化，这加强了这个理论。

```zig
try stdout.print("{any}\n", .{buffer[0..12]});
try stdout.flush();
```

```
{
    200, 194, 216, 255, 203, 197,
    219, 255, 206, 200, 223, 255
}
```

我们可以在上面的结果中看到，这个图像中的第一个像素有200的红色，194的绿色和216的蓝色。我怎么知道颜色在序列中出现的顺序？如果你还没有猜到，是因为缩写RGB。首先是红色，然后是绿色，然后是蓝色。如果我们根据我们的0%到100%（0到255）的刻度来缩放这些整数值，我们得到78%的红色，76%的绿色和85%的蓝色。

## 应用图像滤镜

现在我们有了图像中每个像素的数据，我们可以专注于在这些像素上应用我们的图像滤镜。记住，我们这里的目标是在图像上应用灰度滤镜。灰度滤镜是将彩色图像转换为灰度图像的滤镜。

有不同的公式和策略可以将彩色图像转换为灰度图像。但所有这些不同的策略通常都涉及对每个像素的颜色应用一些数学运算。在这个项目中，我们将使用最通用的公式，如下所示。这个公式将R视为像素的红色，G视为绿色，B视为蓝色，Y视为像素的线性亮度。

Y = 0.2126 × R + 0.7152 × G + 0.0722 × B

这个[方程式15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#eq-grayscale)是计算像素线性亮度的公式。值得注意的是，这个公式仅适用于像素使用sRGB颜色空间的图像，这是网络的标准颜色空间。因此，理想情况下，网络上的所有图像都应该使用这个颜色空间。幸运的是，这是我们这里的情况，即`pedro_pascal.png`图像使用这个sRGB颜色空间，因此，我们可以使用[方程式15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#eq-grayscale)。你可以在维基百科的灰度页面上阅读更多关于这个公式的信息（[Wikipedia 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-wiki_grayscale)）。

下面暴露的`apply_image_filter()`函数总结了在图像中的像素上应用[方程式15.1](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#eq-grayscale)所需的步骤。我们只需将这个函数应用于包含我们像素数据的缓冲区对象，结果，存储在这个缓冲区对象中的像素数据现在应该代表我们图像的灰度版本。

```zig
fn apply_image_filter(buffer:[]u8) !void {
    const len = buffer.len;
    const red_factor: f16 = 0.2126;
    const green_factor: f16 = 0.7152;
    const blue_factor: f16 = 0.0722;
    var index: u64 = 0;
    while (index < len) : (index += 4) {
        const rf: f16 = @floatFromInt(buffer[index]);
        const gf: f16 = @floatFromInt(buffer[index + 1]);
        const bf: f16 = @floatFromInt(buffer[index + 2]);
        const y_linear: f16 = (
            (rf * red_factor) + (gf * green_factor)
            + (bf * blue_factor)
        );
        buffer[index] = @intFromFloat(y_linear);
        buffer[index + 1] = @intFromFloat(y_linear);
        buffer[index + 2] = @intFromFloat(y_linear);
    }
}

try apply_image_filter(buffer[0..]);
```

## 保存图像的灰度版本

由于我们现在已经将图像的灰度版本存储在我们的缓冲区对象中，我们需要将这个缓冲区对象编码回"PNG格式"，并将编码的数据保存到我们文件系统中的新PNG文件中，以便我们可以访问并查看我们的小程序产生的图像的灰度版本。

为此，`libspng`库再次通过提供"将数据编码为PNG"类型的函数来帮助我们，即`spng_encode_image()`函数。但为了使用`libspng`"将数据编码为PNG"，我们需要创建一个新的上下文对象。这个新的上下文对象必须使用"编码器上下文"，由枚举值`SPNG_CTX_ENCODER`标识。

下面暴露的`save_png()`函数总结了将图像的灰度版本保存到文件系统中新PNG文件所需的所有步骤。默认情况下，这个函数将灰度图像保存到CWD中名为`pedro_pascal_filter.png`的文件中。

注意在这个代码示例中，我们使用的是之前用`get_image_header()`函数收集的相同图像头对象（`image_header`）。记住，这个图像头对象是一个C结构（`spng_ihdr`），包含关于我们PNG文件的基本信息，比如图像的尺寸、使用的颜色模型等。

如果我们想在这个新的PNG文件中保存一个非常不同的图像，例如具有不同尺寸的图像，或使用不同颜色模型、不同位深度等的图像，我们将不得不创建一个新的图像头（`spng_ihdr`）对象来描述这个新图像的属性。

但我们在这里本质上保存的是与我们开始时相同的图像（图像的尺寸、颜色模型等都仍然相同）。两个图像之间的唯一区别是像素的颜色，现在是"灰色阴影"。因此，我们可以安全地在这个新的PNG文件中使用完全相同的图像头数据。

```zig
fn save_png(image_header: *c.spng_ihdr, buffer: []u8) !void {
    const path = "pedro_pascal_filter.png";
    const file_descriptor = c.fopen(path.ptr, "wb");
    if (file_descriptor == null) {
        return error.CouldNotOpenFile;
    }
    const ctx = (
        c.spng_ctx_new(c.SPNG_CTX_ENCODER)
        orelse unreachable
    );
    defer c.spng_ctx_free(ctx);
    _ = c.spng_set_png_file(ctx, @ptrCast(file_descriptor));
    _ = c.spng_set_ihdr(ctx, image_header);

    const encode_status = c.spng_encode_image(
        ctx,
        buffer.ptr,
        buffer.len,
        c.SPNG_FMT_PNG,
        c.SPNG_ENCODE_FINALIZE
    );
    if (encode_status != 0) {
        return error.CouldNotEncodeImage;
    }
    if (c.fclose(file_descriptor) != 0) {
        return error.CouldNotCloseFileDescriptor;
    }
}

try save_png(&image_header, buffer[0..]);
```

在我们执行这个`save_png()`函数之后，我们应该在我们的CWD中有一个新的PNG文件，名为`pedro_pascal_filter.png`。如果我们打开这个PNG文件，我们将看到[图15.2](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fig-pascal-gray)中暴露的相同图像。

## 构建我们的项目

现在我们已经编写了代码，让我们讨论如何构建/编译这个项目。为此，我将在项目的根目录中创建一个`build.zig`文件，并开始编写编译项目所需的代码，使用我们从[第9章](https://pedropark99.github.io/zig-book/Chapters/07-build-system.html)获得的知识。

我们首先为执行我们Zig代码的可执行文件创建构建目标。假设我们所有的Zig代码都写在一个名为`image_filter.zig`的Zig模块中。下面构建脚本中暴露的`exe`对象描述了我们可执行文件的构建目标。

由于我们在Zig代码中使用了`libspng`库中的一些C代码，我们需要将我们的Zig代码（在`exe`构建目标中）链接到C标准库和`libspng`库。我们通过从我们的`exe`构建目标调用`linkLibC()`和`linkSystemLibrary()`方法来做到这一点。

```zig
const std = @import("std");
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const exe = b.addExecutable(.{
        .name = "image_filter",
        .root_source_file = b.path("src/image_filter.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    // 链接到libspng库：
    exe.linkSystemLibrary("spng");
    b.installArtifact(exe);
}
```

由于我们使用`linkSystemLibrary()`方法，这意味着在你的系统中搜索`libspng`的库文件以与`exe`构建目标链接。如果你还没有将`libspng`库构建并安装到你的系统中，这个链接步骤很可能不会工作。因为它在你的系统中找不到库文件。

所以，如果你想构建这个项目，请记住将`libspng`安装到你的系统中。有了上面编写的这个构建脚本，我们最终可以通过在终端中运行`zig build`命令来构建我们的项目。

```bash
zig build
```

---

## 脚注

1.   [https://github.com/pedropark99/zig-book/tree/main/ZigExamples/image_filter](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/image_filter)[↩︎](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fnref1)

2.   [https://library.si.edu/exhibition/color-in-a-new-light/science](https://library.si.edu/exhibition/color-in-a-new-light/science)[↩︎](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fnref2)

3.   [https://github.com/pedropark99/zig-book/tree/main/ZigExamples/image_filter](https://github.com/pedropark99/zig-book/tree/main/ZigExamples/image_filter)[↩︎](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fnref3)

4.   [https://libspng.org/](https://libspng.org/)[↩︎](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fnref4)

5.   [https://libspng.org/docs/build/](https://libspng.org/docs/build/)[↩︎](https://pedropark99.github.io/zig-book/Chapters/13-image-filter.html#fnref5)
