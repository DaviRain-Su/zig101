const std = @import("std");

pub const Stage = enum {
    validate,
    awaiting_confirmation,
    confirmed,
    err,

    const Self = @This();

    fn isComplete(self: Self) bool {
        return self == .confirmed or self == .err;
    }
};

test "Stage.isComplete" {
    const stage = Stage.confirmed;
    try std.testing.expect(stage.isComplete());
    std.debug.print("state string: {s}\n", .{@tagName(stage)});
}

pub const Number = union(enum) {
    int: i64,
    float: f64,
    nan: void,
};

test "Number.isNaN" {
    const number = Number{ .nan = {} };
    std.debug.print("number: {s}\n", .{@tagName(number)});
}

test "option usage" {
    const name: ?[]const u8 = "John Doe";
    // use .? to unwrap the value
    std.debug.print("name: {s}\n", .{name.?});
}

pub const OpenError = error{
    AccessDenied,
    NotFound,
};

test "OpenError" {
    const err = OpenError.AccessDenied;
    std.debug.print("error: {s}\n", .{@errorName(err)});
    const err1 = OpenError.NotFound;
    std.debug.print("error code: {s}\n", .{@errorName(err1)});
}

// Zig 的函数名采用了驼峰命名法（camelCase），而变量名会采用小写加下划线（snake case）的命名方式。
// 类型则采用的是 PascalCase 风格。除了这三条规则外，一个有趣的交叉规则是，
// 如果一个变量表示一个类型，或者一个函数返回一个类型，那么这个变量或者函数遵循 PascalCase。
//
// @import，@rem和@intCast。因为这些都是函数，他们的命名遵循驼峰命名法。
// @TypeOf也是一个内置函数，但是他遵循 PascalCase，为何？因为他返回的是一个类型，因此它的命名采用了类型命名方法。
// 当我们使用一个变量，去接收@TypeOf的返回值，这个变量也需要遵循类型命名规则（即 PascalCase）:
// const T = @TypeOf(3);
//
