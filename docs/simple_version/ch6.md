# Zig 指针与可选值

## 指针基础

### 创建与解引用
```zig
const number: u8 = 5;
const pointer = &number;        // 创建指针：& 运算符
const value = pointer.*;        // 解引用：.* 方法
const doubled = 2 * pointer.*;  // 链式使用
```

### 通过指针修改值
```zig
var number: u8 = 5;
const pointer = &number;
pointer.* = 6;  // number 现在是 6
```

### 方法调用
```zig
const user = User.init(1, "pedro", "email@gmail.com");
const ptr = &user;
try ptr.*.print_name();  // 通过指针调用方法
```

## 常量与变量规则

### 指针必须尊重对象特性
```zig
// ❌ 错误：不能修改常量
const number = 5;
const pointer = &number;
pointer.* = 6;  // 编译错误

// ✅ 正确：可以修改变量
var number: u8 = 5;
const pointer = &number;
pointer.* = 6;  // OK
```

### 指针类型标识
- `*const T` - 指向常量值的指针（不能通过它修改值）
- `*T` - 指向变量值的指针（可以通过它修改值）

### 指针本身的可变性
```zig
const c1: u8 = 5;
const c2: u8 = 6;

// 常量指针：不能改变指向
const ptr1 = &c1;
// ptr1 = &c2;  // 错误

// 变量指针：可以改变指向
var ptr2 = &c1;
ptr2 = &c2;  // OK
```

## 指针类型

- **单项指针** `*T` - 指向单个值
- **多项指针** `[*]T` - 可用于指针算术

`&` 运算符总是产生单项指针。

## 指针算术

虽然支持，但推荐使用切片：

```zig
// 指针算术（不推荐）
const arr = [_]i32{1, 2, 3, 4};
var ptr: [*]const i32 = &arr;
ptr += 1;  // 指向下一个元素

// 使用切片（推荐）
const slice = arr[0..];
const element = slice[1];  // 直接索引访问
```

## 可选值

### 核心概念
Zig 中所有对象默认**非空**。需要 null 时使用可选类型。

```zig
// 普通对象不能为 null
var num: i32 = 5;
// num = null;  // 编译错误

// 可选对象可以为 null
var opt: ?i32 = 5;
opt = null;  // OK
```

### 可选指针 vs 指向可选值的指针

```zig
// 可选指针：?*T
var num: i32 = 5;
var opt_ptr: ?*i32 = &num;
opt_ptr = null;  // 指针可以是 null

// 指向可选值的指针：*?T
var opt_num: ?i32 = 5;
const ptr_to_opt = &opt_num;  // 类型是 *?i32
```

## Null 处理

### 方法1：if 语句
```zig
const num: ?i32 = 5;
if (num) |value| {
    // value 是解包后的非空值
    std.debug.print("{d}\n", .{value});
}
```

### 方法2：orelse
```zig
const x: ?i32 = null;
const value = x orelse 15;  // 如果 x 是 null，使用 15
const doubled = (x orelse 0) * 2;
```

### 方法3：强制解包（.?）
```zig
const y: ?i32 = getOptionalValue();
const value = y.?;  // 如果 y 是 null，程序 panic
```

## 使用场景总结

| 场景 | 选择 | 示例 |
|------|------|------|
| 值不可能为 null | 普通类型 | `var x: i32` |
| 值可能为 null | 可选类型 | `var x: ?i32` |
| 避免复制大对象 | 使用指针 | `const ptr = &big_struct` |
| 函数可能返回 null | 返回可选值 | `fn find() ?User` |
| 处理 null 有默认值 | 使用 orelse | `value orelse default` |
| null 是错误情况 | 使用 .? | `optional.?` |

## 关键优势

1. **默认非空**：消除空指针错误的主要来源
2. **显式 null 处理**：必须处理可能的 null 值
3. **编译时安全**：许多 null 错误在编译时被捕获
4. **无隐藏成本**：指针操作明确可见
