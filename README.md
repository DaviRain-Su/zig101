# Learning Zig

## zig 101

## zigling

# Compare Zig with Rust

```zig
fn Add(comptime T: type, a: T, b: T) T {
    return a + b;
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
