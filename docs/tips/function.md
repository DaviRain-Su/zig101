
## Zig 函数参数的关键点：

### 1. **参数默认不可变**
```zig
pub fn addi32(a: i32, b: i32) i32 {
    // a 和 b 在这里相当于 const
    // a = b; // ❌ 编译错误：cannot assign to constant
    return a + b;
}
```

### 2. **通过指针实现可变**
```zig
pub fn addi32Byref(a: *i32, b: i32) i32 {
    a.* = b;  // ✅ 可以通过指针修改原始值
    return a.* + b;
}
```

### 3. **其他相关模式**

**如果只需要函数内部修改（不影响外部）：**
```zig
pub fn example(input: i32) i32 {
    var a = input;  // 创建可变的本地副本
    a += 10;        // 可以修改本地副本
    return a;
}
```

**常量指针 vs 可变指针：**
```zig
// 常量指针：可以读取但不能修改
pub fn readOnly(ptr: *const i32) void {
    std.debug.print("value: {}\n", .{ptr.*});
    // ptr.* = 10; // ❌ 错误
}

// 可变指针：可以读取和修改
pub fn readWrite(ptr: *i32) void {
    ptr.* += 1;  // ✅ 可以修改
}
```

这种设计让代码更安全、更明确，避免了意外修改参数的情况。
