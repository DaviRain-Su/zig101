# Zig 控制流、结构体与类型系统

## 控制流

### If/Else 语句
```zig
const x = 5;
if (x > 10) {
    std.debug.print("x > 10\n", .{});
} else {
    std.debug.print("x <= 10\n", .{});
}
```

### Switch 语句

**基本用法：**
```zig
const Role = enum { SE, DE, PM, PO, KS };

const role = Role.SE;
const area = switch (role) {
    .PM, .PO => "Product",          // 多值分支
    .SE, .DE => "Engineering",      // 类型推断（.前缀）
    .KS => "Sales",
};
```

**特性：**
- **必须穷尽所有可能**（编译器强制）
- **范围匹配**：`0...100` （包含两端）
- **else 分支**：默认/不支持的情况
- **标记 switch**：可用 `continue :label` 跳转

```zig
const level: u8 = 25;
const category = switch (level) {
    0...25 => "beginner",
    26...75 => "intermediate",
    76...100 => "professional",
    else => @panic("Invalid level"),
};
```

### Defer 和 Errdefer

**defer**：退出当前作用域时执行（无条件）
```zig
fn example() !void {
    defer std.debug.print("清理资源\n", .{});  // 最后执行
    defer std.debug.print("第二个\n", .{});     // 倒数第二
    defer std.debug.print("第一个\n", .{});     // 倒数第三
    // 函数逻辑...
}  // 执行顺序：第一个 -> 第二个 -> 清理资源（LIFO）
```

**errdefer**：仅在发生错误时执行（条件）
```zig
fn allocateResource() !void {
    const resource = try createResource();
    errdefer destroyResource(resource);  // 仅错误时清理

    try riskyOperation();  // 如果失败，自动清理 resource
}
```

### 循环

**For 循环：**
```zig
const items = [_]u8{1, 2, 3, 4, 5};

// 遍历值
for (items) |value| {
    std.debug.print("{d} ", .{value});
}

// 同时遍历索引和值
for (items, 0..) |value, index| {
    std.debug.print("[{d}]={d} ", .{index, value});
}

// 仅索引（丢弃值）
for (items, 0..) |_, index| {
    std.debug.print("{d} ", .{index});
}
```

**While 循环：**
```zig
var i: u8 = 0;
while (i < 5) : (i += 1) {  // 增量表达式可选
    std.debug.print("{d} ", .{i});
}

// break 和 continue
while (true) {
    if (i == 10) break;      // 退出循环
    if (i % 2 == 0) continue; // 跳过当前迭代
    i += 1;
}
```

## 函数参数不可变

函数参数在 Zig 中是不可变的：

```zig
// ❌ 错误
fn add2(x: u32) u32 {
    x = x + 2;  // 错误：不能修改参数
    return x;
}

// ✅ 使用指针修改
fn add2(x: *u32) void {
    x.* = x.* + 2;  // 通过解引用修改
}
```

**优化**：编译器自动选择传值或传引用（对复杂类型）。

## 结构体和 OOP

### 基本结构体
```zig
const User = struct {
    id: u64,                    // 数据成员用逗号分隔
    name: []const u8,
    email: []const u8,

    // 构造函数（约定）
    pub fn init(id: u64, name: []const u8, email: []const u8) User {
        return User{ .id = id, .name = name, .email = email };
    }

    // 实例方法
    pub fn print_name(self: User) void {
        std.debug.print("{s}\n", .{self.name});
    }
};
```

### Self 参数规则

```zig
const Vec3 = struct {
    x: f64, y: f64, z: f64,

    // 不修改状态：self: T
    pub fn length(self: Vec3) f64 {
        return @sqrt(self.x * self.x + self.y * self.y + self.z * self.z);
    }

    // 修改状态：self: *T
    pub fn scale(self: *Vec3, factor: f64) void {
        self.x *= factor;
        self.y *= factor;
        self.z *= factor;
    }
};
```

### pub 关键字

控制模块外部可见性：
```zig
// math.zig
pub const PI = 3.14159;              // 公开常量
const E = 2.71828;                    // 私有常量

pub const Circle = struct {           // 公开结构体
    radius: f64,

    pub fn area(self: Circle) f64 {  // 公开方法
        return PI * self.radius * self.radius;
    }

    fn helper() void {}               // 私有方法
};
```

### 匿名结构体字面量

使用 `.{}` 语法让编译器推断类型：
```zig
// 具名
const user = User{ .id = 1, .name = "Alice" };

// 匿名（类型推断）
std.debug.print("{s}: {d}\n", .{"Count", 42});  // .{} 是匿名结构体
```

## 类型系统

### 类型推断

使用 `.` 前缀进行类型推断：
```zig
const Color = enum { Red, Green, Blue };

const color = Color.Red;
const name = switch (color) {
    .Red => "红色",      // 编译器推断为 Color.Red
    .Green => "绿色",    // 编译器推断为 Color.Green
    .Blue => "蓝色",     // 编译器推断为 Color.Blue
};
```

### 类型转换

**安全转换（@as）：**
```zig
const x: u32 = 100;
const y = @as(u64, x);  // 安全扩展
```

**特殊转换函数：**
```zig
// 整数 ↔ 浮点
const i: i32 = 42;
const f: f32 = @floatFromInt(i);      // i32 -> f32
const j: i32 = @intFromFloat(f);      // f32 -> i32

// 指针转换
const bytes = [_]u8{0x12, 0x34, 0x56, 0x78};
const ptr: *const u32 = @ptrCast(&bytes);  // 指针类型转换
```

## 模块系统

每个 `.zig` 文件是一个模块，内部表示为结构体：

```zig
// math.zig - 模块即结构体
pub const PI = 3.14159;
pub fn add(a: f64, b: f64) f64 {
    return a + b;
}

// main.zig - 使用模块
const math = @import("math.zig");
const sum = math.add(1.0, 2.0);
const pi = math.PI;
```

## 重要规则汇总

1. **Switch 必须穷尽**所有可能
2. **函数参数不可变**（使用指针绕过）
3. **结构体声明必须用 const**
4. **修改状态的方法**：`self: *T`
5. **不修改状态的方法**：`self: T`
6. **defer 执行顺序**：LIFO（后进先出）
7. **errdefer**：仅错误时执行
8. **类型推断**：使用 `.` 前缀
9. **pub**：控制模块外可见性
