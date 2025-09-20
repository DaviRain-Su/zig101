# 第11章 数据结构 - Zig入门介绍

在本章中，我想介绍Zig标准库中最常见的数据结构，特别是`ArrayList`和`HashMap`。这些是通用数据结构，你可以用它们来存储和控制应用程序产生的任何类型的数据。

## 动态数组

在高级语言中，数组通常是动态的。当需要时它们可以轻松地增大容量，你不需要为此担心。相比之下，低级语言中的数组通常默认是静态的。这是C、C++、Rust以及Zig的现实情况。静态数组已在[第1.6节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-arrays)中介绍过，但在本节中，我们将讨论Zig中的动态数组。

动态数组就是在程序运行期间可以增大容量的数组。大多数低级语言在其标准库中都有动态数组的某种实现。C++有`std::vector`，Rust有`Vec`，而Zig有`std.ArrayList`。

`std.ArrayList`结构为你提供了一个连续且可增长的数组。它的工作原理与任何其他动态数组一样，它分配一块连续的内存块，当这个块没有剩余空间时，`ArrayList`会分配另一个连续且更大的内存块，将元素复制到这个新位置，并擦除（或释放）之前的内存块。

### 容量与长度

当我们谈论动态数组时，通常有两个相似的概念对动态数组在幕后的工作原理至关重要。这些概念是_容量_和_长度_。在某些上下文中，特别是在C++中，_长度_也被称为_大小_。

尽管它们看起来相似，但这些概念在动态数组的上下文中代表不同的东西。_容量_是你的动态数组当前可以容纳的项目（或元素）数量，而不需要分配更多内存。

相比之下，_长度_指的是数组中当前正在使用的元素数量，或者换句话说，你已经为这个数组中的多少个元素赋了值。每个动态数组都围绕一块分配的内存工作，它代表一个总容量为\(n\)个元素的数组。然而，大多数时候只使用这\(n\)个元素的一部分。这部分\(n\)就是数组的_长度_。所以每次你向数组追加一个新值时，你就将其_长度_增加了一。

这意味着动态数组通常会有额外的边际，或者当前为空但准备好使用的额外空间。这个"额外空间"本质上是_容量_和_长度_之间的差异。_容量_代表数组在不需要重新分配或重新扩展数组的情况下可以容纳的元素总数，而_长度_代表当前用于保存/存储值的容量大小。

[图11.1](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fig-capacity-length)直观地展示了这个想法。注意，起初，数组的容量大于数组的长度。因此，动态数组有当前为空但准备接收要存储的值的额外空间。

![图片1](https://pedropark99.github.io/zig-book/Figures/dynamic-array.png)

图11.1：动态数组中容量和长度的区别

我们还可以在[图11.1](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fig-capacity-length)中看到，当_长度_和_容量_相等时，意味着数组没有剩余空间了。我们已经达到了容量的上限，因此，如果我们想在这个数组中存储更多的值，我们需要扩展它。我们需要获得一个可以容纳比当前更多值的更大空间。

动态数组的工作原理是，每当数组的_长度_等于_容量_时，就扩展底层数组。它基本上分配一个比前一个更大的新连续内存块，然后，将当前存储的所有值复制到这个新位置（即这个新内存块），然后，释放之前的内存块。在这个过程结束时，新的底层数组有更大的_容量_，因此，_长度_再次变得小于数组的_容量_。

这就是动态数组的周期。注意，在整个周期中，_容量_总是等于或高于数组的_长度_。如果你有一个`ArrayList`对象（假设你将其命名为`buffer`），你可以通过访问`ArrayList`对象的`capacity`属性来检查数组的当前容量，而其当前_长度_可在`items.len`属性中获得。

```zig
// 检查容量
buffer.capacity;
// 检查长度
buffer.items.len;
```

### 创建`ArrayList`对象

为了使用`ArrayList`，你必须为它提供一个分配器对象。记住，Zig没有默认的内存分配器。正如我在[第3.3节](https://pedropark99.github.io/zig-book/Chapters/01-memory.html#sec-allocators)中所述，所有内存分配必须由你定义的、你有控制权的分配器对象来完成。在我们这里的例子中，我将使用通用目的分配器，但你可以使用任何你偏好的其他分配器。

当你初始化一个`ArrayList`对象时，你必须提供数组元素的数据类型。换句话说，这定义了这个数组（或容器）将存储的数据类型。因此，如果我为它提供`u8`类型，那么，我将创建一个`u8`值的动态数组。然而，如果我提供一个我定义的结构，比如[第2.3节](https://pedropark99.github.io/zig-book/Chapters/03-structs.html#sec-structs-and-oop)中的结构`User`，那么，将创建一个`User`值的动态数组。在下面的例子中，通过表达式`ArrayList(u8)`我们创建了一个`u8`值的动态数组。

在你提供数组元素的数据类型后，你可以通过使用`init()`或`initCapacity()`方法初始化`ArrayList`对象。前者方法只接收分配器对象作为输入，而后者方法接收分配器对象和容量数字作为输入。使用后者方法，你不仅初始化了结构，还设置了分配数组的起始容量。

使用`initCapacity()`方法是初始化动态数组的首选方式。因为重新分配，或者换句话说，扩展数组容量的过程，总是一个高成本的操作。你应该抓住任何可能的机会来避免数组中的重新分配。如果你知道你的数组在开始时需要占用多少空间，你应该始终使用`initCapacity()`来创建你的动态数组。

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var buffer = try std.ArrayList(u8)
    .initCapacity(allocator, 100);
defer buffer.deinit(allocator);
```

在上面的例子中，`buffer`对象开始时是一个100个元素的数组。如果这个`buffer`对象在程序运行期间需要创建更多空间来容纳更多元素，`ArrayList`内部将自动为你执行必要的操作。还要注意`deinit()`方法被用于在当前作用域结束时销毁`buffer`对象，通过释放为存储在这个`buffer`对象中的动态数组分配的所有内存。

### 向数组添加新元素

现在我们已经创建了动态数组，我们可以开始使用它。你可以通过使用`append()`方法向这个数组追加（也称为"添加"）新值。这个方法的工作方式与Python列表的`append()`方法或C++的`std::vector`的`emplace_back()`方法相同。你向这个方法提供一个值，方法将这个值追加到数组。

你还可以使用`appendSlice()`方法一次追加多个值。你向这个方法提供一个切片（切片在[第1.6节](https://pedropark99.github.io/zig-book/Chapters/01-zig-weird.html#sec-arrays)中描述过），方法将这个切片中的所有值添加到你的动态数组。

```zig
try buffer.append(allocator, 'H');
try buffer.append(allocator, 'e');
try buffer.append(allocator, 'l');
try buffer.append(allocator, 'l');
try buffer.append(allocator, 'o');
try buffer.appendSlice(allocator, " World!");
```

### 从数组中删除元素

你可以使用`pop()`方法来"弹出"或删除数组中的最后一个元素。值得注意的是，这个方法不会改变数组的容量。它只是删除或擦除存储在数组中的最后一个值。

此外，这个方法返回被删除的值作为结果。也就是说，你可以使用这个方法既获取数组中的最后一个值，又从数组中删除它。这是一个"获取并删除值"类型的方法。

```zig
const exclamation_mark = buffer.pop();
```

现在，如果你想从数组的特定位置删除特定元素，你可以使用`ArrayList`对象的`orderedRemove()`方法。使用这个方法，你可以提供一个索引作为输入，然后，方法将删除数组中该索引处的值。每次执行`orderedRemove()`操作时，你实际上是在减少数组的_长度_。

在下面的例子中，我们首先创建一个`ArrayList`对象，并用数字填充它。然后，我们使用`orderedRemove()`连续两次删除数组中索引3处的值。

还要注意，我们将`orderedRemove()`的结果赋值给下划线字符。所以我们丢弃了这个方法的结果值。`orderedRemove()`方法返回被删除的值，风格类似于`pop()`方法。

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var buffer = try std.ArrayList(u8)
    .initCapacity(allocator, 100);
defer buffer.deinit(allocator);

for (0..10) |i| {
    const index: u8 = @intCast(i);
    try buffer.append(allocator, index);
}

std.debug.print(
    "{any}\n", .{buffer.items}
);
_ = buffer.orderedRemove(3);
_ = buffer.orderedRemove(3);

std.debug.print("{any}\n", .{buffer.items});
std.debug.print("{any}\n", .{buffer.items.len});
```

```
{ 0, 1, 2, 3, 4, 5, 6, 7, 8, 9 }
{ 0, 1, 2, 5, 6, 7, 8, 9 }
8
```

`orderedRemove()`的一个关键特性是它保留数组中值的顺序。所以，它删除你要求它删除的值，但它也确保数组中剩余值的顺序与之前保持一致。

现在，如果你不关心值的顺序，例如，也许你想将动态数组视为一组值，就像C++的`std::unordered_set`结构，你可以改用`swapRemove()`方法。这个方法的工作方式类似于`orderedRemove()`方法。你给这个方法一个索引，然后，它删除数组中该索引处的值。但这个方法不保留数组中剩余值的原始顺序。因此，`swapRemove()`通常比`orderedRemove()`更快。

### 在特定索引处插入元素

当你需要在数组中间插入值，而不是只是将它们追加到数组末尾时，你需要使用`insert()`和`insertSlice()`方法，而不是`append()`和`appendSlice()`方法。

这两个方法的工作方式与C++ `std::vector`类的`insert()`和`insert_range()`非常相似。你向这些方法提供一个索引，它们在数组中的该索引处插入你提供的值。

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();
var buffer = try std.ArrayList(u8)
    .initCapacity(allocator, 10);
defer buffer.deinit(allocator);

try buffer.appendSlice(allocator, "My Pedro");
try buffer.insert(allocator, 4, '3');
try buffer.insertSlice(allocator, 2, " name");
for (buffer.items) |char| {
    try stdout.print("{c}", .{char});
}
try stdout.flush();
```

```
My name P3edro
```

### 结论

如果你感觉缺少其他一些方法，我建议你阅读[`ArrayListAligned`的官方文档](https://ziglang.org/documentation/master/std/#std.array_list.ArrayListAligned)，它描述了通过`ArrayList`对象可用的大多数方法。

你会注意到这个页面上有很多其他方法我没有在这里描述，我建议你探索这些方法，并了解它们是如何工作的。

## 映射表或哈希表

一些专业人士用不同的术语来了解这种类型的数据结构，如"映射"、"哈希映射"或"关联数组"。但最常用的术语是_哈希表_。每种编程语言通常在其标准库中都有哈希表的某种实现。Python有`dict()`，C++有`std::map`和`std::unordered_map`，Rust有`HashMap`，Javascript有`Object()`和`Map()`等。

### 什么是哈希表？

哈希表是基于键值对的数据结构。你向这个结构提供一个键和一个值，然后，哈希表将输入值存储在可以通过你提供的输入键识别的位置。它通过使用底层数组和哈希函数来做到这一点。这两个组件对于哈希表的工作原理至关重要。

在底层，哈希表包含一个数组。这个数组是存储值的地方，这个数组的元素通常被称为_桶_。所以你提供给哈希表的值存储在桶内，你通过使用索引访问每个桶。

当你向哈希表提供一个键时，它将这个键传递给哈希函数。这个哈希函数使用某种哈希算法将这个键转换为索引。这个索引实际上是一个数组索引。它是哈希表底层数组中的一个位置。这就是键如何识别哈希表结构内的特定位置（或位置）。

因此，你向哈希表提供一个键，这个键识别哈希表内的特定位置，然后，哈希表获取你提供的输入值，并将这个值存储在由这个输入键识别的位置。你可以说键映射到存储在哈希表中的值。你通过使用标识存储值位置的键来找到值。[图11.2](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fig-hashtable)直观地展示了这个过程。

![图片2](https://pedropark99.github.io/zig-book/Figures/hashtable.svg)

图11.2：哈希表图解。来源：维基百科，自由的百科全书。

前一段中描述的操作通常称为_插入_操作。因为你正在向哈希表中插入新值。但哈希表中还有其他类型的操作，如_删除_和_查找_。删除是自我描述的，它是当你从哈希表中删除（或移除）一个值时。而查找对应于当你通过使用标识存储该值位置的键来查看存储在哈希表中的值时。

有时，哈希表的底层数组不是直接存储值，而可能是一个指针数组，即数组的桶存储指向值的指针，或者也可能是链表数组。这些情况在允许重复键的哈希表中很常见，或者换句话说，在有效处理哈希函数可能产生的"冲突"的哈希表中很常见。

重复键，或者我所说的这个"冲突"问题，是当你有两个不同的键指向哈希表底层数组中的同一位置（即同一索引）时。这可能会根据哈希表中使用的哈希函数的特性而发生。哈希表的某些实现会主动处理冲突，这意味着它们会以某种方式处理这种情况。例如，哈希表可能将所有桶转换为链表。因为使用链表，你可以将多个值存储到单个桶中。

在哈希表中处理冲突有不同的技术，我不会在本书中描述，因为这不是我们这里的主要范围。但你可以在哈希表的维基百科页面上找到一些最常见技术的良好描述（[Wikipedia 2024](https://pedropark99.github.io/zig-book/Chapters/references.html#ref-wikipedia_hashtables)）。

### Zig中的哈希表

Zig标准库提供了哈希表的不同实现。每种实现都有其自身的优缺点，我们稍后会讨论，所有这些都可通过`std.hash_map`模块获得。

`HashMap`结构是一个通用目的的哈希表，它具有非常快的操作（查找、插入、删除），以及相当高的负载因子以实现低内存使用。你可以创建并向`HashMap`构造函数提供一个上下文对象。这个上下文对象允许你定制哈希表本身的行为，因为你可以通过这个上下文对象提供要由哈希表使用的哈希函数实现。

但现在让我们不要担心这个上下文对象，因为它是为"哈希表领域的专家"准备的。既然我们很可能不是这个领域的专家，我们将采取简单的方式来创建哈希表。这是通过使用`AutoHashMap()`函数。

这个`AutoHashMap()`函数本质上是一个"创建使用默认设置的哈希表对象"类型的函数。它会自动为你选择一个上下文对象，因此也选择一个哈希函数实现。这个函数接收两种数据类型作为输入，第一个输入是将在此哈希表中使用的键的数据类型，而第二个输入是将存储在哈希表内的数据的数据类型，即要存储的值的数据类型。

在下面的例子中，我们在这个函数的第一个参数中提供数据类型`u32`，在第二个参数中提供`u16`。这意味着我们将使用`u32`值作为此哈希表中的键，而`u16`值是将要存储到此哈希表中的实际值。在这个过程结束时，`hash_table`对象包含一个使用默认设置和上下文的`HashMap`对象。

```zig
const std = @import("std");
const AutoHashMap = std.hash_map.AutoHashMap;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var hash_table = AutoHashMap(u32, u16).init(allocator);
    defer hash_table.deinit();

    try hash_table.put(54321, 89);
    try hash_table.put(50050, 55);
    try hash_table.put(57709, 41);
    std.debug.print(
        "N of values stored: {d}\n",
        .{hash_table.count()}
    );
    std.debug.print(
        "Value at key 50050: {d}\n",
        .{hash_table.get(50050).?}
    );

    if (hash_table.remove(57709)) {
        std.debug.print(
            "Value at key 57709 successfully removed!\n",
            .{}
        );
    }
    std.debug.print(
        "N of values stored: {d}\n",
        .{hash_table.count()}
    );
}
```

```
N of values stored: 3
Value at key 50050: 55
Value at key 57709 successfully removed!
N of values stored: 2
```

你可以使用`put()`方法向哈希表中添加/放入新值。第一个参数是要使用的键，第二个参数是你想要存储在哈希表中的实际值。在下面的例子中，我们首先使用键54321添加值89，接下来，我们使用键50050添加值55，等等。

注意我们使用了`count()`方法来查看当前存储在哈希表中的值数量。之后，我们还使用`get()`方法访问（或查看）存储在键500050标识的位置的值。这个`get()`方法的输出是一个可选值。这就是为什么我们在末尾使用`?`方法来获取实际值。

还要注意，我们可以使用`remove()`方法从哈希表中删除值。你提供标识要删除的值的键，然后，方法将删除这个值并返回一个`true`值作为输出。这个`true`值本质上告诉我们该方法成功删除了该值。

但这个删除操作可能并不总是成功的。例如，你可能向这个方法提供了错误的键。我的意思是，也许你提供了（有意或无意）一个指向空桶的键，即一个还没有值的桶。在这种情况下，`remove()`方法将返回一个`false`值。

### 遍历哈希表

遍历当前存储在哈希表中的键和值是一个非常常见的需求。你可以在Zig中通过使用一个可以遍历哈希表对象元素的迭代器对象来做到这一点。

这个迭代器对象的工作方式与你在C++和Rust等语言中找到的任何其他迭代器对象一样。它基本上是一个指向容器中某个值的指针对象，并有一个`next()`方法，你可以使用它来导航（或迭代）容器中的值。

你可以通过使用哈希表对象的`iterator()`方法创建这样的迭代器对象。这个方法返回一个迭代器对象，你可以将其`next()`方法与while循环结合使用来遍历哈希表的元素。`next()`方法返回一个可选的`Entry`值，因此，你必须解包这个可选值以获取实际的`Entry`值，从中你可以访问键以及由该键标识的值。

有了这个`Entry`值，你可以通过使用`key_ptr`属性并解引用其中的指针来访问当前条目的键，而由该键标识的值则通过`value_ptr`属性访问，它也是要解引用的指针。下面的代码示例演示了这些元素的使用：

```zig
const std = @import("std");
const AutoHashMap = std.hash_map.AutoHashMap;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var hash_table = AutoHashMap(u32, u16).init(allocator);
    defer hash_table.deinit();

    try hash_table.put(54321, 89);
    try hash_table.put(50050, 55);
    try hash_table.put(57709, 41);

    var it = hash_table.iterator();
    while (it.next()) |kv| {
        // 访问当前键
        std.debug.print("Key: {d} | ", .{kv.key_ptr.*});
        // 访问当前值
        std.debug.print("Value: {d}\n", .{kv.value_ptr.*});
    }
}
```

```
Key: 54321 | Value: 89
Key: 50050 | Value: 55
Key: 57709 | Value: 41
```

如果你想专门遍历哈希表的值或键，你可以创建一个键迭代器或值迭代器对象。这些也是迭代器对象，具有相同的`next()`方法，你可以使用它来遍历哈希表。

键迭代器是从哈希表对象的`keyIterator()`方法创建的，而值迭代器是从`valueIterator()`方法创建的。你所要做的就是从`next()`方法解包值并直接解引用它以访问你正在迭代的键或值。下面的代码示例演示了键迭代器的使用，但你可以将相同的逻辑复制到值迭代器。

```zig
var kit = hash_table.keyIterator();
while (kit.next()) |key| {
    std.debug.print("Key: {d}\n", .{key.*});
}
```

```
Key: 54321
Key: 50050
Key: 57709
```

### `ArrayHashMap`哈希表

如果你需要不断地遍历哈希表的元素，你可能想要为你的特定情况使用`ArrayHashMap`结构，而不是使用通常的通用目的`HashMap`结构。

`ArrayHashMap`结构创建了一个遍历速度更快的哈希表。这就是为什么这种特定类型的哈希表可能对你有价值。`ArrayHashMap`哈希表的一些其他属性是：

* 插入顺序被保留，即，你在遍历此哈希表时找到的值的顺序实际上是这些值插入哈希表的顺序。
* 键值对是顺序存储的，一个接一个。

你可以再次使用一个帮助函数来创建`ArrayHashMap`对象，该函数会自动为你选择哈希函数实现。这是`AutoArrayHashMap()`函数，它的工作方式与我们在[第11.2.2节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-hashmap)中介绍的`AutoHashMap()`函数非常相似。

你向这个函数提供两种数据类型。将在此哈希表中使用的键的数据类型，以及将存储在此哈希表中的值的数据类型。

`ArrayHashMap`对象基本上具有与`HashMap`结构完全相同的方法。所以你可以使用`put()`方法向哈希表中插入新值，你可以使用`get()`方法从哈希表中查找（或获取）值。但`remove()`方法在这种特定类型的哈希表中不可用。

为了从哈希表中删除值，你将使用在`ArrayList`对象（即动态数组）中找到的相同方法。我在[第11.1.4节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-dynamic-array-remove)中介绍了这些方法，它们是`swapRemove()`和`orderedRemove()`方法。这些方法在这里具有相同的含义，或者在`ArrayList`对象中具有相同的效果。

这意味着，使用`swapRemove()`你从哈希表中删除值，但不保留值插入结构的顺序。而`orderedRemove()`能够保留这些值插入的顺序。

但与我在[第11.1.4节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-dynamic-array-remove)中描述的那样，不是向`swapRemove()`或`orderedRemove()`提供索引作为输入，这里在`ArrayHashMap`中的这些方法接受键作为输入，就像`HashMap`对象的`remove()`方法一样。如果你想提供索引作为输入，而不是键，你应该使用`swapRemoveAt()`和`orderedRemoveAt()`方法。

```zig
var hash_table = AutoArrayHashMap(u32, u16)
    .init(allocator);
defer hash_table.deinit();
```

### `StringHashMap`哈希表

你会在我在过去几节中介绍的其他两种哈希表类型中注意到的一件事是，它们都不接受切片数据类型作为键。这意味着你不能在这些类型的哈希表中使用切片值来表示键。

这最明显的结果是你不能在这些哈希表中使用字符串作为键。但在哈希表中使用字符串作为键是极其常见的。

以这个非常简单的Javascript代码片段为例。我们正在创建一个名为`people`的简单哈希表对象。然后，我们向这个哈希表添加一个新条目，由字符串`'Pedro'`标识。这个字符串在这种情况下是键，而包含不同个人信息（如年龄、身高和城市）的对象是要存储在哈希表中的值。

```javascript
var people = new Object();
people['Pedro'] = {
    'age': 25,
    'height': 1.67,
    'city': 'Belo Horizonte'
};
```

这种使用字符串作为键的模式在各种情况下都很常见。这就是为什么Zig标准库为此目的提供了特定类型的哈希表，它是通过`StringHashMap()`函数创建的。这个函数创建一个使用字符串作为键的哈希表。这个函数的唯一输入是将存储到此哈希表中的值的数据类型。

在下面的例子中，我创建了一个哈希表来存储不同人的年龄。此哈希表中的每个键由每个人的名字表示，而存储在哈希表中的值是由键标识的这个人的年龄。

这就是为什么我向这个`StringHashMap()`函数提供`u8`数据类型（这是年龄值使用的数据类型）作为输入。结果，它创建了一个使用字符串值作为键并存储`u8`值的哈希表。注意，在`StringHashMap()`函数的结果对象的`init()`方法中提供了分配器对象。

```zig
const std = @import("std");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var ages = std.StringHashMap(u8).init(allocator);
    defer ages.deinit();

    try ages.put("Pedro", 25);
    try ages.put("Matheus", 21);
    try ages.put("Abgail", 42);

    var it = ages.iterator();
    while (it.next()) |kv| {
        std.debug.print("Key: {s} | ", .{kv.key_ptr.*});
        std.debug.print("Age: {d}\n", .{kv.value_ptr.*});
    }
}
```

```
Key: Pedro | Age: 25
Key: Abgail | Age: 42
Key: Matheus | Age: 21
```

### `StringArrayHashMap`哈希表

Zig标准库还提供了一种哈希表类型，它将`StringHashMap`和`ArrayHashMap`的优缺点混合在一起。也就是说，一个使用字符串作为键的哈希表，但也具有`ArrayHashMap`的优点。换句话说，你可以拥有一个遍历速度快、保留插入顺序并且使用字符串作为键的哈希表。

你可以使用`StringArrayHashMap()`函数创建这种类型的哈希表。这个函数接受一个数据类型作为输入，这是将要存储在此哈希表中的值的数据类型，风格与[第11.2.5节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-string-hash-map)中介绍的函数相同。

你可以使用我们在[第11.2.5节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-string-hash-map)中讨论的相同`put()`方法向此哈希表插入新值。你也可以使用相同的`get()`方法从哈希表中获取值。像它的`ArrayHashMap`兄弟一样，要从这种特定类型的哈希表中删除值，我们也使用`orderedRemove()`和`swapRemove()`方法，效果与我在[第11.2.4节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-array-map)中描述的相同。

如果我们采用[第11.2.5节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-string-hash-map)中公开的代码示例，我们可以用`StringArrayHashMap()`实现完全相同的结果：

```zig
var ages = std.StringArrayHashMap(u8).init(allocator);
```

## 链表

Zig标准库为单链表和双链表提供了实现。更具体地说，通过结构`SinglyLinkedList`和`DoublyLinkedList`。

如果你不熟悉这些数据结构，链表是一种看起来像链条或绳索的线性数据结构。这种数据结构的主要优点是你通常有非常快的插入和删除操作。但是，作为缺点，遍历这种数据结构通常不如遍历数组快。

链表背后的想法是构建一个由通过指针相互连接的节点序列组成的结构。这意味着链表通常在内存中不是连续的，因为每个节点可能在内存的任何地方。它们不需要彼此靠近。

在[图11.3](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fig-linked-list)中，我们可以看到单链表的图表。我们从第一个节点开始（通常称为"链表的头部"）。然后，从这第一个节点，我们通过跟随每个节点中找到的指针指向的位置来发现结构中的剩余节点。

每个节点有两样东西。它有存储在当前节点中的值，还有一个指针。这个指针指向列表中的下一个节点。如果这个指针是空的，那么，这意味着我们已经到达了链表的末尾。

![图片3](https://pedropark99.github.io/zig-book/Figures/linked-list.png)

图11.3：单链表图解。

在[图11.4](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fig-linked-list2)中，我们可以看到双链表的图表。现在真正改变的唯一一件事是链表中的每个节点都有一个指向前一个节点的指针和一个指向下一个节点的指针。所以双链表中的每个节点都有两个指针。这些通常被称为节点的`prev`（代表"前一个"）和`next`（代表"下一个"）指针。

在单链表示例中，每个节点只有一个指针，这个单一指针总是指向序列中的下一个节点。这意味着单链表通常只有`next`指针。

![图片4](https://pedropark99.github.io/zig-book/Figures/doubly-linked-list.png)

图11.4：双链表图解。

### API的最新变化

在Zig的早期版本中，`SinglyLinkedList`和`DoublyLinkedList`结构最初被实现为"通用数据结构"。这意味着，你将使用一个通用函数来创建一个可以存储你想要使用的特定数据类型的单（或双）链表。我们将在[第12.2节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-generics)中了解更多关于泛型的内容，以及如何在[第12.2.2节](https://pedropark99.github.io/zig-book/Chapters/10-stack-project.html#sec-generic-struct)中创建"通用数据结构"。

然而，在Zig的最新版本中，结构`SinglyLinkedList`和`DoublyLinkedList`被修改为使用"不那么通用的API"。这个特定的更改是在2025年4月3日引入的。因此，检查你的Zig版本是否是在这个日期之后发布的。请记住，如果你没有非常新的Zig编译器版本，在尝试编译这里公开的下一个示例时可能会遇到问题。

### 如何使用单链表

例如，考虑你正在创建一个将存储`u32`值的单链表。鉴于这种情况，我们需要做的第一件事是创建一个能够存储`u32`值的"节点类型"。下面公开的`NodeU32`类型演示了这样的"节点类型"。

注意，与名为`data`的成员关联的数据类型是这个自定义"节点类型"的最重要部分。它决定了将存储在每个节点中的数据类型。

```zig
const std = @import("std");
const NodeU32 = struct {
    data: u32,
    node: std.SinglyLinkedList.Node = .{},
};
```

在我们创建了可以存储我们想要的特定数据类型的自定义"节点类型"之后，我们可以创建一个新的空单链表，它将存储我们的节点。要做到这一点，我们只需创建一个类型为`SinglyLinkedList`的新对象，如下所示：

```zig
var list: std.SinglyLinkedList = .{};
```

现在，我们有了链表……但是我们如何在其中插入节点呢？嗯，首先，我们需要创建我们的节点。所以让我们先关注这个。下面公开的片段演示了我们如何使用`NodeU32`结构来创建这样的节点。

注意在这个片段中，我们现在只是设置结构的`data`成员。我们不需要在第一个实例中将这些节点连接在一起。这就是为什么我们最初忽略`node`成员。但我们将在代码的未来某个点连接这些节点，这就是为什么这些对象被标记为"变量对象"，以便我们可以在未来更改它们。

```zig
var one: NodeU32 = .{ .data = 1 };
var two: NodeU32 = .{ .data = 2 };
var three: NodeU32 = .{ .data = 3 };
var five: NodeU32 = .{ .data = 5 };
```

现在我们有了链表和创建的节点，我们可以开始将它们连接在一起。你可以使用链表对象的`prepend()`方法在列表中插入第一个节点，这是链表的"头部"。正如名称所示，这个特定方法将输入节点前置到链表，或者换句话说，它将输入节点转换为列表的第一个节点。

在我们添加了列表的"头节点"之后，我们可以通过使用`SinglyLinkedList.Node`类型的`insertAfter()`方法开始在列表中添加"下一个节点"，在我们这里的情况下，它可以通过我们的`NodeU32`类型的`node`成员访问。因此，我们可以通过从列表中存在的节点对象调用这个方法来开始创建节点之间的连接。就像下面这个例子：

```zig
list.prepend(&two.node); // {2}
two.node.insertAfter(&five.node); // {2, 5}
two.node.insertAfter(&three.node); // {2, 3, 5}
```

你也可以再次调用`prepend()`方法向链表的开头添加新节点，这意味着，有效地改变列表的"头节点"，如下所示：

```zig
list.prepend(&one.node); // {1, 2, 3, 5}
```

单链表对象中还有其他你可能感兴趣的可用方法。你可以在下面的要点中找到它们的摘要：

* `remove()`从链表中删除特定节点。
* `len()`计算链表中有多少个节点。
* `popFirst()`从链表中删除第一个节点（即"头部"）。

所以，这就是Zig中单链表的工作原理概述。总结一下，这是本节中公开的所有源代码在单个单元格内：

```zig
const NodeU32 = struct {
    data: u32,
    node: std.SinglyLinkedList.Node = .{},
};

var list: std.SinglyLinkedList = .{};
var one: NodeU32 = .{ .data = 1 };
var two: NodeU32 = .{ .data = 2 };
var three: NodeU32 = .{ .data = 3 };
var five: NodeU32 = .{ .data = 5 };

list.prepend(&two.node); // {2}
two.node.insertAfter(&five.node); // {2, 5}
two.node.insertAfter(&three.node); // {2, 3, 5}
list.prepend(&one.node); // {1, 2, 3, 5}

try stdout.print("Number of nodes: {}", .{list.len()});
try stdout.flush();
```

```
Number of nodes: 4
```

### 如何使用双链表

如果你想使用双链表，你将面临与单链表相似的工作流程：

1. 你首先创建一个可以存储你想要的特定数据类型的"自定义节点类型"。
2. 创建一个空的双链表对象。
3. 创建链表的节点。
4. 开始将节点插入列表。

在你的"自定义节点类型"中，你应该使用`DoublyLinkedList.Node`类型来表示结构的`node`成员。下面的片段演示了这一点。这里我们再次创建一个可以存储`u32`值的节点类型。但这次，这个结构是为在`DoublyLinkedList`结构内使用而定制的。

在这一步之后，你创建新的空链表和你想要插入的节点的方式与单链表的情况几乎相同。但是，这次，我们通常使用链表对象的`append()`方法向列表添加新节点。

链表对象的这个`append()`方法将始终将输入节点追加到链表的末尾。然而，如果你想将新节点添加到列表的不同位置，那么，你应该查看链表对象的`insertAfter()`和`insertBefore()`方法。这些方法允许你在列表中的现有节点之后或之前插入新节点。

```zig
const NodeU32 = struct {
    data: u32,
    node: std.DoublyLinkedList.Node = .{},
};

var list: std.DoublyLinkedList = .{};
var one: NodeU32 = .{ .data = 1 };
var two: NodeU32 = .{ .data = 2 };
var three: NodeU32 = .{ .data = 3 };
var five: NodeU32 = .{ .data = 5 };

list.append(&one.node); // {1}
list.append(&three.node); // {1, 3}
list.insertAfter(
    &one.node,
    &five.node
); // {1, 5, 3}
list.append(&two.node); // {1, 5, 3, 2}

try stdout.print("Number of nodes: {}", .{list.len()});
try stdout.flush();
```

```
Number of nodes: 4
```

这些是`DoublyLinkedList`对象的其他可能让你感兴趣的方法：

* `remove()`：从列表中删除特定节点。
* `len()`：计算列表中的节点数。
* `prepend()`：向列表开头添加节点（即设置列表的头节点）。
* `pop()`：删除列表的最后一个节点。
* `popFirst()`：删除列表的第一个节点。
* `concatByMoving()`：将两个双链表连接在一起。

### 遍历链表

如果你想遍历链表的元素，你需要做的就是跟随"指向下一个节点的指针"创建的轨迹。我们通常在while循环内这样做，它只是一遍又一遍地转到下一个节点，直到找到空指针，这意味着我们到达了列表的末尾。

下一个示例演示了这样的while循环如何工作。注意我们使用`@fieldParentPtr()`内置函数来访问指向`node`对象的父实例的指针。换句话说，我们获得了指向包含当前节点的`NodeU32`实例的指针的访问权。这样，我们可以使用这个指针访问当前存储在这个节点中的数据。

还要注意，在while循环的每次迭代中，我们将`it`变量的值更改为列表中的下一个节点。当这个`it`变量变为空时，while循环被中断，这将在列表中没有"下一个节点"时发生，这意味着我们已经到达了列表的末尾。

```zig
const NodeU32 = struct {
    data: u32,
    node: std.SinglyLinkedList.Node = .{},
};

var list: std.SinglyLinkedList = .{};
var one: NodeU32 = .{ .data = 1 };
var two: NodeU32 = .{ .data = 2 };
var three: NodeU32 = .{ .data = 3 };
var five: NodeU32 = .{ .data = 5 };

list.prepend(&two.node); // {2}
list.prepend(&five.node); // {5, 2}
list.prepend(&three.node); // {3, 5, 2}
list.prepend(&one.node); // {1, 3, 5, 2}

var it = list.first;
while (it) |node| : (it = node.next) {
    const l: *NodeU32 = @fieldParentPtr(
        "node", node
    );
    try stdout.print(
        "Current value: {}", .{l.data}
    );
}
try stdout.flush();
```

```
Current value: 1
Current value: 3
Current value: 5
Current value: 2
```

## 多数组结构

Zig引入了一种称为`MultiArrayList()`的新数据结构。它是我们在[第11.1节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-dynamic-array)中介绍的动态数组的不同版本。这个结构和我们从[第11.1节](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#sec-dynamic-array)中了解的`ArrayList()`之间的区别是，`MultiArrayList()`为你作为输入提供的结构的每个字段创建一个单独的动态数组。

考虑以下代码示例。我们创建了一个名为`Person`的新自定义结构。这个结构包含三个不同的数据成员，或三个不同的字段。因此，当我们将这个`Person`数据类型作为输入提供给`MultiArrayList()`时，这将创建一个名为`PersonArray`的"三个不同数组的结构"。换句话说，这个`PersonArray`是一个包含三个内部动态数组的结构。`Person`结构定义中找到的每个字段一个数组。

```zig
const std = @import("std");
const Person = struct {
    name: []const u8,
    age: u8,
    height: f32,
};
const PersonArray = std.MultiArrayList(Person);

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var people = PersonArray{};
    defer people.deinit(allocator);

    try people.append(allocator, .{
        .name = "Auguste", .age = 15, .height = 1.54
    });
    try people.append(allocator, .{
        .name = "Elena", .age = 26, .height = 1.65
    });
    try people.append(allocator, .{
        .name = "Michael", .age = 64, .height = 1.87
    });
}
```

换句话说，`MultiArrayList()`函数不是创建"人员数组"，而是创建"数组结构"。这个结构的每个数据成员都是一个不同的数组，存储添加（或追加）到这个"数组结构"的`Person`值的特定字段的值。一个重要的细节是存储在`PersonArray`内部的每个单独的内部数组都是动态数组。这意味着这些数组可以根据需要自动增长容量，以容纳更多值。

下面公开的[图11.5](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fig-multi-array)展示了一个描述我们在前面代码示例中创建的`PersonArray`结构的图表。注意，我们追加到`PersonArray`对象中的三个`Person`值中每个数据成员的值，分散在`PersonArray`对象的三个不同内部数组中。

![图片5](https://pedropark99.github.io/zig-book/Figures/multi-array.png)

图11.5：`PersonArray`结构图解。

你可以轻松地分别访问这些数组，并遍历每个数组的值。为此，你需要从`PersonArray`对象调用`items()`方法，并向此方法提供你想要遍历的字段名称作为输入。例如，如果你想遍历`.age`数组，那么，你需要从`PersonArray`对象调用`items(.age)`，如下面的例子所示：

```zig
for (people.items(.age)) |*age| {
    try stdout.print("Age: {d}\n", .{age.*});
}
try stdout.flush();
```

```
Age: 15
Age: 26
Age: 64
```

在上面的例子中，我们遍历`.age`数组的值，或者，`PersonArray`对象的内部数组，它包含添加到多数组结构的`Person`值的`age`数据成员的值。

在这个例子中，我们直接从`PersonArray`对象调用`items()`方法。然而，在大多数情况下，建议从"切片对象"调用这个`items()`方法，你可以从`slice()`方法创建它。原因是如果你使用切片对象，多次调用`items()`会有更好的性能。

因此，如果你计划只访问"多数组结构"中的一个内部数组，直接从多数组对象调用`items()`是可以的。但如果你需要访问"多数组结构"中的许多内部数组，那么，你可能需要多次调用`items()`，在这种情况下，最好通过切片对象调用`items()`。下面的例子演示了这种对象的使用：

```zig
var slice = people.slice();
for (slice.items(.age)) |*age| {
    age.* += 10;
}
for (slice.items(.name), slice.items(.age)) |*n,*a| {
    try stdout.print(
        "Name: {s}, Age: {d}\n", .{n.*, a.*}
    );
}
try stdout.flush();
```

```
Name: Auguste, Age: 25
Name: Elena, Age: 36
Name: Michael, Age: 74
```

## 结论

还有许多其他数据结构我没有在这里介绍。但你可以在官方Zig标准库文档页面查看它们。实际上，当你进入[文档主页](https://ziglang.org/documentation/master/std/#)时，这个页面上首先出现的是Zig标准库中可用的类型和数据结构列表。这个列表中有一些非常特定的数据结构，比如[`BoundedArray`结构](https://ziglang.org/documentation/master/std/#std.bounded_array.BoundedArray)，但也有一些更通用的结构，比如[`PriorityQueue`结构](https://ziglang.org/documentation/master/std/#std.priority_queue.PriorityQueue)。

---

## 脚注

1.   [https://ziglang.org/documentation/master/std/#std.array_list.ArrayListAligned](https://ziglang.org/documentation/master/std/#std.array_list.ArrayListAligned)[↩︎](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fnref1)

2.   [https://ziglang.org/documentation/master/std/#](https://ziglang.org/documentation/master/std/#)[↩︎](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fnref2)

3.   [https://ziglang.org/documentation/master/std/#std.bounded_array.BoundedArray](https://ziglang.org/documentation/master/std/#std.bounded_array.BoundedArray)[↩︎](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fnref3)

4.   [https://ziglang.org/documentation/master/std/#std.priority_queue.PriorityQueue](https://ziglang.org/documentation/master/std/#std.priority_queue.PriorityQueue).[↩︎](https://pedropark99.github.io/zig-book/Chapters/09-data-structures.html#fnref4)
