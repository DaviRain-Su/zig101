# Zig 调试指南

## 打印调试

### 输出到 stdout
```zig
const std = @import("std");
var stdout_buffer: [1024]u8 = undefined;
var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
const stdout = &stdout_writer.interface;

pub fn main() !void {
    const result = 42;
    try stdout.print("Result: {d}\n", .{result});
    try stdout.flush();  // 重要：刷新缓冲区
}
```

### 输出到stdout 简化版

```zig
const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try stdout.print("Result: {d}\n", .{42});
}
```

### 输出到 stderr
```zig
// 方式1：使用 std.debug.print（最简单，无需错误处理）
std.debug.print("Result: {d}\n", .{result});

// 方式2：获取 stderr writer
const stderr = std.io.getStdErr().writer();
try stderr.print("Result: {d}\n", .{result});

```

### 格式说明符

| 说明符 | 用途 | 示例 |
|--------|------|------|
| `{d}` | 整数/浮点数 | `print("{d}", .{42})` |
| `{s}` | 字符串 | `print("{s}", .{"hello"})` |
| `{c}` | 字符 | `print("{c}", .{'A'})` |
| `{x}` | 十六进制 | `print("{x}", .{255})` |
| `{p}` | 内存地址 | `print("{p}", .{&value})` |
| `{any}` | 自动选择 | `print("{any}", .{value})` |

注意事项：

- 使用缓冲区版本时，记得调用 flush() 确保内容输出
- std.debug.print() 不需要错误处理（无 try）
- stderr 通常用于错误信息和调试输出

对比示例

```zig
const std = @import("std");

pub fn main() !void {
    // stdout with buffer（需要 flush）
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("To stdout: {d}\n", .{42});
    try stdout.flush();

    // stderr（直接输出，无缓冲）
    const stderr = std.io.getStdErr().writer();
    try stderr.print("To stderr: {d}\n", .{42});

    // debug print（最简单）
    std.debug.print("Debug: {d}\n", .{42});
}
```

## 调试器调试

### 编译模式
```bash
# Debug模式（默认，包含调试信息）
zig build-exe program.zig

# 或显式指定
zig build-exe -O Debug program.zig

# Release模式（优化，无调试信息）
zig build-exe -O ReleaseFast program.zig
```

### 使用 LLDB

**启动调试**：
```bash
# 编译程序
zig build-exe program.zig

# 启动 LLDB
lldb program
```

**基本命令**：
| 命令 | 功能 | 示例 |
|------|------|------|
| `b` | 设置断点 | `b main` |
| `run` | 运行程序 | `run` |
| `n` | 下一行（不进入函数） | `n` |
| `s` | 下一行（进入函数） | `s` |
| `p` | 打印变量 | `p variable_name` |
| `frame variable` | 显示所有局部变量 | `frame variable` |
| `c` | 继续执行 | `c` |

**调试示例**：
```zig
fn add_and_increment(a: u8, b: u8) u8 {
    const sum = a + b;
    const incremented = sum + 1;
    return incremented;
}

pub fn main() !void {
    var n = add_and_increment(2, 3);
    n = add_and_increment(n, n);
    std.debug.print("Result: {d}\n", .{n});
}
```

**LLDB 会话**：
```
(lldb) b main                 # 在 main 设置断点
(lldb) run                    # 运行程序
(lldb) n                      # 执行下一行
(lldb) p n                    # 查看 n 的值
(unsigned char) $1 = '\x06'
(lldb) s                      # 进入函数
(lldb) frame variable         # 查看所有变量
(unsigned char) a = '\x06'
(unsigned char) b = '\x06'
(unsigned char) sum = '\f'
```

### 使用 GDB

GDB 命令与 LLDB 类似：
- `break main` - 设置断点
- `run` - 运行
- `next` - 下一行
- `step` - 进入函数
- `print variable` - 打印变量
- `info locals` - 显示局部变量

## 类型调查

使用 `@TypeOf()` 内置函数检查对象类型：

```zig
const std = @import("std");

pub fn main() !void {
    const number: i32 = 5;
    const array = [_]u8{1, 2, 3};
    const string = "hello";

    // 打印类型
    std.debug.print("number type: {any}\n", .{@TypeOf(number)});  // i32
    std.debug.print("array type: {any}\n", .{@TypeOf(array)});    // [3]u8
    std.debug.print("string type: {any}\n", .{@TypeOf(string)});  // *const [5:0]u8

    // 类型比较
    const expect = std.testing.expect;
    try expect(@TypeOf(number) == i32);
}
```

## 调试最佳实践

1. **默认使用 Debug 模式**：开发时保留调试信息
2. **优先使用 `std.debug.print`**：自动输出到 stderr，无需错误处理
3. **善用格式说明符**：
   - 不确定类型时用 `{any}`
   - 调试指针用 `{p}`
   - 查看十六进制用 `{x}`
4. **调试器技巧**：
   - 在关键函数设置断点
   - 使用 `frame variable` 查看作用域内所有变量
   - 用 `s` 进入可疑函数内部
5. **类型调试**：用 `@TypeOf()` 确认对象类型

## 快速参考

```zig
// 打印调试
std.debug.print("Value: {d}, Type: {any}\n", .{value, @TypeOf(value)});

// 编译调试版本
zig build-exe -O Debug program.zig

// LLDB 调试流程
lldb program
b main
run
n / s / p variable / c
```
