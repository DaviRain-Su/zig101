# Zig 语言快速入门

## 什么是 Zig？

Zig 是一门现代、低级、通用编程语言，可视为 C 的改进版。其核心理念是"少即是多" - 通过移除 C/C++ 中的问题特性来实现改进，而非添加更多功能。

**核心特点：**
- 无隐藏控制流
- 无隐藏内存分配
- 无预处理器和宏
- 内置构建系统

## 快速开始

### 创建项目
```bash
mkdir hello_world && cd hello_world
zig init
```

生成的文件结构：
- `src/main.zig` - 可执行程序入口
- `src/root.zig` - 库的根文件
- `build.zig` - 构建脚本
- `build.zig.zon` - 依赖管理文件

### Hello World
```zig
const std = @import("std");

pub fn main() !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("Hello, {s}!\n", .{"world"});
    try stdout.flush(); // Don't forget to flush!
}
```

### 编译运行
```bash
# 编译
zig build-exe src/main.zig

# 编译并运行
zig run src/main.zig

# 使用构建系统
zig build
./zig-out/bin/hello_world
```

## 基础语法

### 变量和常量
```zig
const age = 24;           // 常量（不可变）
var count: u8 = 0;       // 变量（可变，需要类型注解）
var undefined_var: u8 = undefined;  // 未初始化（避免使用）

// 丢弃未使用的值
const unused = 42;
_ = unused;
```

**规则：**
- 所有对象必须被使用或显式丢弃
- 变量必须被修改，否则应使用 const

### 数据类型
- 整数：`u8`, `u16`, `u32`, `u64`, `i8`, `i16`, `i32`, `i64`
- 浮点：`f16`, `f32`, `f64`
- 布尔：`bool`
- 指针大小：`usize`, `isize`

## 数组、指针和切片

### 基本数组操作
```zig
const arr = [4]u8{1, 2, 3, 4};       // 固定大小数组
const auto = [_]u8{1, 2, 3};         // 自动推断大小
const elem = arr[2];                  // 索引访问

// 数组操作符
const concat = arr1 ++ arr2;          // 连接
const repeat = arr ** 3;              // 重复
```

### 数组、指针、切片的关系

```zig
// 数组及其指针
var arr = [_]i32{ 1, 2, 3, 4, 5 };
const arr_ptr = &arr;                 // *[5]i32 - 指向数组的指针

// 多项指针（类似 C 指针）
var p: [*]i32 = &arr;                 // [*]i32 - 多项指针
const second = p[1];                   // 索引访问
const next_ptr = p + 1;               // 指针算术
```

### 切片的内部结构

切片是指针和长度的组合：
```zig
const slice = arr[1..4];              // []i32 类型
// slice.ptr - 指向第一个元素的多项指针
// slice.len - 元素个数

std.debug.print("ptr: {*}, len: {d}\n", .{ slice.ptr, slice.len });
```

### 指针类型转换和对齐

```zig
// 类型转换
const byte_ptr: [*]u8 = @ptrCast(&arr);

// 手动遍历数组（通过字节指针）
const step = @sizeOf(i32);
for (0..arr.len) |i| {
    // @alignCast 确保正确对齐
    const elem_ptr: [*]i32 = @ptrCast(@alignCast(byte_ptr + i * step));
    std.debug.print("arr[{d}] = {d}\n", .{ i, elem_ptr[0] });
}

// 编译时对齐检查
comptime {
    if (@alignOf(i32) != 4) @compileError("unexpected alignment");
}
```

### 指针类型总结

| 类型 | 说明 | 示例 |
|------|------|------|
| `*T` | 单项指针 | `*i32` |
| `[*]T` | 多项指针（未知长度） | `[*]u8` |
| `*[N]T` | 数组指针 | `*[5]i32` |
| `[]T` | 切片（ptr + len） | `[]u8` |
| `[:0]T` | 哨兵终止切片 | `[:0]u8` |
| `[*:0]T` | 哨兵终止多项指针 | `[*:0]u8` |

### 切片的编译时与运行时

```zig
// 编译时已知范围 - 可使用指针操作
const compile_slice = arr[1..4];
const deref = compile_slice.*;        // 解引用

// 运行时已知范围 - 不支持指针操作
var end: usize = 4;
const runtime_slice = arr[0..end];
// const deref = runtime_slice.*;     // 错误！
```

### 函数
```zig
fn add(a: i32, b: i32) i32 {
    return a + b;
}

pub fn publicFunc() void {}           // 公共函数
export fn libraryFunc() void {}       // 导出给 C ABI
```

### 块和作用域
```zig
const x = blk: {
    var y: i32 = 123;
    y += 1;
    break :blk y;                      // 从标记块返回值
};
```

## 字符串

Zig 字符串是 UTF-8 编码的 `u8` 数组。

```zig
// 字符串字面量类型：*const [n:0]u8（null 终止）
const literal = "Hello";

// 字符串切片类型：[]const u8
const slice: []const u8 = "World";

// 获取长度
const len = literal.len;

// 遍历字节
for (literal) |byte| {
    std.debug.print("{X} ", .{byte});
}

// 遍历 Unicode 字符
var utf8 = try std.unicode.Utf8View.init("你好");
var iter = utf8.iterator();
while (iter.nextCodepointSlice()) |codepoint| {
    // 处理每个字符
}
```

### 常用字符串函数
```zig
std.mem.eql(u8, str1, str2)          // 比较
std.mem.splitScalar(u8, str, ',')    // 按字符分割
std.mem.startsWith(u8, str, "pre")   // 前缀检查
std.mem.endsWith(u8, str, "suf")     // 后缀检查
std.mem.trim(u8, str, " ")           // 去除首尾
std.mem.replace(...)                  // 替换
```

## 错误处理

```zig
fn mayFail() !void {
    return error.Failed;
}

pub fn main() !void {
    try mayFail();                    // 错误向上传播
    mayFail() catch |err| {           // 捕获错误
        // 处理错误
    };
}
```

## 内存安全特性

1. **defer/errdefer** - 确保资源释放
2. **非空默认** - 指针和对象默认不可为 null
3. **数组边界检查** - 防止缓冲区溢出
4. **强制错误处理** - 必须处理所有可能的错误
5. **穷尽的 switch** - 必须处理所有情况

## Windows 注意事项

全局变量在编译时初始化。访问 stdout 等运行时资源应放在函数内：

```zig
// ❌ 错误
const stdout = std.io.getStdOut().writer();

// ✅ 正确
pub fn main() void {
    const stdout = std.io.getStdOut().writer();
}
```

## 学习资源

- [Zig 官方文档](https://ziglang.org/documentation/master/)
- [Zig 标准库](https://github.com/ziglang/zig/tree/master/lib/std)
- [Ziglings 练习](https://ziglings.org/)
- 社区：[Reddit](https://www.reddit.com/r/Zig/), [Ziggit](https://ziggit.dev/)

## 最佳实践

1. 优先使用 `const` 而非 `var`
2. 避免使用 `undefined`
3. 处理所有错误
4. 利用 `defer` 管理资源
5. 阅读标准库源码学习惯用法
