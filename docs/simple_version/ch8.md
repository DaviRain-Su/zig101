# Zig 单元测试

## test 块基础

使用 `test` 关键字创建单元测试，可选字符串标签标识测试：

```zig
const std = @import("std");
const expect = std.testing.expect;

test "testing simple sum" {
    const a: u8 = 2;
    const b: u8 = 2;
    try expect((a + b) == 4);  // 逻辑测试：true 通过，false 失败
}
```

**特点**：
- 可在同一模块中编写多个 test 块
- 可与源代码混合（编译时自动忽略）
- 标准做法：测试与被测代码放在一起
- 也可单独创建 tests 文件夹

## 运行测试

```bash
zig test simple_sum.zig
```

`zig test` 命令会找到并执行所有 test 块。普通编译命令（`build-exe`、`build-lib` 等）会忽略 test 块。

## 内存分配测试

使用 `std.testing.allocator` 自动检测内存泄漏：

```zig
const std = @import("std");
const Allocator = std.mem.Allocator;

fn some_memory_leak(allocator: Allocator) !void {
    const buffer = try allocator.alloc(u32, 10);
    _ = buffer;
    // 错误：未释放内存
}

test "memory leak" {
    const allocator = std.testing.allocator;
    try some_memory_leak(allocator);  // 会检测并报告内存泄漏
}
```

## 错误测试

使用 `expectError()` 测试函数是否返回特定错误：

```zig
const std = @import("std");
const expectError = std.testing.expectError;

fn alloc_error(allocator: Allocator) !void {
    var buffer = try allocator.alloc(u8, 100);  // 尝试分配 100 字节
    defer allocator.free(buffer);
}

test "testing error" {
    var buffer: [10]u8 = undefined;  // 只有 10 字节
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    // 期望 OutOfMemory 错误
    try expectError(error.OutOfMemory, alloc_error(allocator));
}
```

## 相等性测试

### 基本相等性
```zig
// 使用 expect 和 ==
try expect(value == 42);

// 使用 expectEqual（更详细的错误信息）
try std.testing.expectEqual(expected, actual);
```

### 数组比较
```zig
test "arrays are equal?" {
    const array1 = [3]u32{1, 2, 3};
    const array2 = [3]u32{1, 2, 3};

    try std.testing.expectEqualSlices(
        u32,      // 元素类型
        &array1,  // 第一个数组
        &array2   // 第二个数组
    );
}
```

### 字符串比较
```zig
test "strings are equal?" {
    const str1 = "hello, world!";
    const str2 = "Hello, world!";

    try std.testing.expectEqualStrings(str1, str2);
    // 失败时会显示详细的差异信息
}
```

## 测试函数汇总

| 函数 | 用途 | 示例 |
|------|------|------|
| `expect()` | 通用布尔测试 | `try expect(a > b)` |
| `expectEqual()` | 值相等 | `try expectEqual(15, result)` |
| `expectEqualSlices()` | 数组/切片相等 | `try expectEqualSlices(u8, &arr1, &arr2)` |
| `expectEqualStrings()` | 字符串相等 | `try expectEqualStrings("hello", str)` |
| `expectError()` | 期望特定错误 | `try expectError(error.OutOfMemory, func())` |

## 最佳实践

1. **测试组织**：
   - Zig 标准库风格：测试与代码放一起
   - 传统风格：单独的 tests 目录

2. **内存测试**：
   - 总是使用 `std.testing.allocator` 进行内存相关测试
   - 自动检测泄漏和双重释放

3. **错误处理**：
   - 明确测试预期的错误类型
   - 使用 `expectError` 而非手动检查

4. **运行测试**：
   - `zig test file.zig` 运行单个文件
   - `zig build test` 运行项目所有测试（需要配置 build.zig）
