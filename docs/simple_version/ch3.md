# Zig 内存管理与分配器

## 内存空间类型

Zig 使用三种内存空间存储对象：

### 1. 全局数据段
- 存储所有字面量（`"string"`, `10`, `true`）
- 存储编译时已知值的常量对象
- 自动管理，无需关心

### 2. 栈内存
- **特点**：
  - 使用 LIFO（后进先出）数据结构
  - 存储编译时已知大小的对象
  - 函数调用时自动分配空间
  - 作用域结束时自动释放
  - 速度快但大小有限

- **存储内容**：
  - 函数参数
  - 局部变量（固定大小）
  - 编译时已知大小的对象

- **重要限制**：
```zig
// ❌ 错误：返回栈上局部变量的指针
fn bad() *const u8 {
    const result = 42;
    return &result;  // 函数返回后 result 被销毁！
}

// ✅ 正确：返回值本身
fn good() u8 {
    const result = 42;
    return result;
}
```

### 3. 堆内存
- **特点**：
  - 动态分配，可在运行时增长
  - 需要手动管理（分配和释放）
  - 通过分配器访问
  - 适合大对象和动态大小对象

## 编译时已知 vs 运行时已知

```zig
// 编译时已知
const name = "Pedro";              // 值和大小都已知
const array = [_]u8{1, 2, 3, 4};  // 固定大小

// 运行时已知
fn process(input: []const u8) void {  // input 大小未知
    const n = input.len;              // n 值运行时确定
}
```

**存储规则**：
1. 字面量 → 全局数据段
2. 编译时已知的 const → 全局数据段
3. 编译时已知大小 → 栈
4. 通过分配器创建 → 堆（通常）

## 栈溢出

栈大小有限，分配过大会导致崩溃：

```zig
// ❌ 栈溢出
var huge: [1000 * 1000 * 24]u64 = undefined;  // 分段错误

// ✅ 使用堆
const huge = try allocator.alloc(u64, 1000 * 1000 * 24);
defer allocator.free(huge);
```

## 分配器

### 核心概念

分配器是 Zig 管理动态内存的对象。**关键原则**：Zig 无隐藏内存分配。需要分配的函数必须接收分配器参数。

```zig
// 函数需要分配内存 = 需要分配器参数
const output = try std.fmt.allocPrint(
    allocator,  // 明确的分配器参数
    "Hello {s}!",
    .{name}
);
defer allocator.free(output);  // 必须手动释放！
```

### 分配器类型

| 分配器 | 特点 | 使用场景 |
|--------|------|----------|
| `GeneralPurposeAllocator` | 通用，带调试功能 | 一般用途 |
| `page_allocator` | 分配整页（~4KB），快但浪费 | 大块分配 |
| `FixedBufferAllocator` | 使用固定缓冲区 | 已知最大大小 |
| `ArenaAllocator` | 批量释放 | 临时分配组 |
| `c_allocator` | malloc 封装（需要 -lc） | C 互操作 |

### 基本用法

**数组分配（alloc/free）**：
```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// 分配数组
const array = try allocator.alloc(u8, 50);
defer allocator.free(array);  // 必须释放！
@memset(array, 0);  // 初始化
```

**单个对象（create/destroy）**：
```zig
const User = struct {
    id: usize,
    name: []const u8,
};

// 分配单个对象
const user = try allocator.create(User);
defer allocator.destroy(user);

user.* = User{ .id = 1, .name = "Alice" };
```

### FixedBufferAllocator

基于缓冲区的分配器，缓冲区位置决定内存位置：

```zig
// 栈上分配
var buffer: [100]u8 = undefined;
var fba = std.heap.FixedBufferAllocator.init(&buffer);
const allocator = fba.allocator();

// 堆上分配（大缓冲区）
const heap_buffer = try page_allocator.alloc(u8, 1024 * 1024);
defer page_allocator.free(heap_buffer);
var heap_fba = std.heap.FixedBufferAllocator.init(heap_buffer);
```

### ArenaAllocator

批量管理内存，一次释放所有：

```zig
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var arena = std.heap.ArenaAllocator.init(gpa.allocator());
defer arena.deinit();  // 一次释放所有分配

const allocator = arena.allocator();
const a1 = try allocator.alloc(u8, 10);
const a2 = try allocator.alloc(u8, 20);
const a3 = try allocator.alloc(u8, 30);
// 无需单独 free，deinit 释放所有
```

## 内存管理最佳实践

1. **优先使用栈**：更快，自动管理
2. **明确生命周期**：使用 `defer` 确保释放
3. **选择合适的分配器**：
   - 一般用途 → `GeneralPurposeAllocator`
   - 已知大小 → `FixedBufferAllocator`
   - 批量临时 → `ArenaAllocator`
4. **避免返回栈指针**：函数结束后栈内存被销毁
5. **总是配对分配/释放**：
   - `alloc` ↔ `free`
   - `create` ↔ `destroy`

## 关键规则

- **无隐藏分配**：需要分配的函数必须接收分配器
- **手动管理堆内存**：必须显式释放
- **栈自动管理**：作用域结束自动清理
- **编译时优先**：能在编译时确定的都会优化
