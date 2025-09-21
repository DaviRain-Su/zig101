# Learning Zig

## zig 101

## zigling

# Compare Zig with Rust

```zig
fn add(comptime T: type, a: T, b: T) T {
    return a + b;
}

fn contains(comptime T: type, value: T, slice: []const T) bool {
    for (slice) |item| {
        if (item == value) return true;
    }
    return false;
}

pub fn equals(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;
    for (a, b) |item_a, item_b| {
        if (item_a != item_b) return false;
    }
    return true;
}
```

```rust
fn add<T>(a: T, b: T) -> T
where
    T: std::ops::Add<Output = T>,
{
    a + b
}
```
