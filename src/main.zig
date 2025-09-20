const std = @import("std");
const zig101 = @import("zig101");

pub fn main() !void {
    // Prints to stderr, ignoring potential errors.
    //std.debug.print("All your {s} are belong to us.\n", .{"codebase"});
    //try zig101.bufferedPrint();
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buffer);
    const stdout = &stdout_writer.interface;
    try stdout.print("Hello, {s}!\n", .{"world"});
    try stdout.flush();

    const age = 23;
    //age = 24; // error: cannot assign to constant
    std.debug.print("age, {}\n", .{age});
    const ns = [4]u8{ 48, 24, 12, 6 };
    const sl = ns[0..];
    std.debug.print("ns, {any}\n", .{ns});
    std.debug.print("sl, {any}, sl len {}\n", .{ sl, sl.len });

    const a = [_]u8{ 1, 2, 3 };
    const c = a ** 4;
    try stdout.print("{any}\n", .{c});
    try stdout.flush();

    const a1 = [_]u8{ 1, 2, 3 };
    const b1 = [_]u8{ 4, 5 };
    const c1 = a1 ++ b1;
    try stdout.print("{any}\n", .{c1});
    try stdout.flush();

    var y: i32 = 123;
    const x = add_one: {
        y += 1;
        break :add_one y;
    };
    if (x == 124 and y == 124) {
        try stdout.print("Hey!\n", .{});
        try stdout.flush();
    }

    //try stdout.print("Hello, {}!\n", .{@TypeOf("world")});
    //
    const simple_array = [_]i32{ 1, 2, 3, 4 };
    const string_obj: []const u8 = "A string object";
    std.debug.print("Type 1: {}\n", .{@TypeOf(simple_array)});
    std.debug.print("Type 2: {}\n", .{@TypeOf("A string literal")});
    std.debug.print("Type 3: {}\n", .{@TypeOf(&simple_array)});
    std.debug.print("Type 4: {}\n", .{@TypeOf(string_obj)});

    const array: [3]i64 = .{ 1, 2, 3 };
    var sum: i64 = 0;
    for (array) |value| {
        sum += value;
    }
    std.debug.print("array's sum is {d}.\n", .{sum});

    const my_struct: MyStruct = .{
        .a = 1,
        .b = 2,
        .c = 3,
    };

    var sum1: i64 = 0;
    inline for (comptime std.meta.fieldNames(MyStruct)) |field_name| {
        sum1 += @field(my_struct, field_name);
    }
    std.debug.print("struct's sum is {d}.\n", .{sum1});

    const my_struct1: GenericMyStruct(i64) = .{
        .a = 1,
        .b = 2,
        .c = 3,
    };
    std.debug.print("struct's sum is {d}.\n", .{my_struct1.sumFields()});
}

pub fn GenericMyStruct(comptime T: type) type {
    return struct {
        a: T,
        b: T,
        c: T,

        fn sumFields(my_struct: GenericMyStruct(T)) T {
            var sum: T = 0;
            const fields = comptime std.meta.fieldNames(GenericMyStruct(T));
            inline for (fields) |field_name| {
                sum += @field(my_struct, field_name);
            }
            return sum;
        }
    };
}

const MyStruct = struct {
    a: i64,
    b: i64,
    c: i64,
};

test "simple test" {
    const gpa = std.testing.allocator;
    var list: std.ArrayList(i32) = .empty;
    defer list.deinit(gpa); // Try commenting this out and see if zig detects the memory leak!
    try list.append(gpa, 42);
    try std.testing.expectEqual(@as(i32, 42), list.pop());
}

test "fuzz example" {
    const Context = struct {
        fn testOne(context: @This(), input: []const u8) anyerror!void {
            _ = context;
            // Try passing `--fuzz` to `zig build test` and see if it manages to fail this test case!
            try std.testing.expect(!std.mem.eql(u8, "canyoufindme", input));
        }
    };
    try std.testing.fuzz(Context{}, Context.testOne, .{});
}
