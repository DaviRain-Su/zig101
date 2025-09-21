const std = @import("std");
const zig101 = @import("zig101");
const print = std.debug.print;

pub fn main() !void {
    print("Hello, world!\n", .{});
    // display foo function string Type
    print("foo function type: {s}\n", .{@typeName(@TypeOf(foo))});
    print("bar function type: {s}\n", .{@typeName(@TypeOf(bar))});
    foo(1, 2, .{ 3, 4, 5 });
    var y: f32 = 3.14;
    const FloatType = @TypeOf(y); // FloatType = f32
    print("FloatType: {s}\n", .{@typeName(FloatType)});
    y = 2.71828;
    print("y: {}\n", .{y});
    // 多个参数时，返回它们的共同类型
    const a: u8 = 10;
    const b: u16 = 20;
    const CommonType = @TypeOf(a, b); // CommonType = u16
    print("CommonType: {s}\n", .{@typeName(CommonType)});
    print("a: {}, b: {}\n", .{ a, b });
    // 用于创建相同类型的变量
    const original = "Hello";
    var copy: @TypeOf(original) = "World";
    print("original type: {s}\n", .{@typeName(@TypeOf(original))});
    print("original: {s}, copy: {s}\n", .{ original, copy });
    copy = original;
    print("original: {s}, copy: {s}\n", .{ original, copy });
}

const F = struct { usize, usize, usize };

fn foo(x: usize, y: usize, z: F) void {
    const z1, const z2, const z3 = z;
    print("Foo\n", .{});
    print("z1: {}, z2: {}, z3: {}\n", .{ z1, z2, z3 });
    print("foo({} {} {})\n", .{ x, y, z });
}

fn bar() void {}
