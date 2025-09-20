const std = @import("std");
const expect = std.testing.expect;

test "always succeeds" {
    try expect(true); // src/test_pass.zig:5:11: error: error union is ignored if ignore try
}

test "always fails" {
    //try expect(false); // src/test_pass.zig:10:11: error: error union is ignored if ignore try
}

test "assigment" {
    const constant: i32 = 5;
    var variable: u32 = 4000;
    variable += 1;

    const inferred_constant = @as(i32, 10);
    var inferred_variable = @as(u32, 2000);
    inferred_variable += 1;
    std.debug.print("constant: {}, variable: {}, inferred_constant: {}, inferred_variable: {}\n", .{ constant, variable, inferred_constant, inferred_variable });
}

test "array" {
    const a = [5]u8{ 1, 2, 3, 4, 5 };
    const b = [_]u8{ 1, 2, 3, 4, 5 };

    std.debug.print("a: {any}, b: {any}, b len: {}\n", .{ a, b, b.len });
}

test "if statement" {
    const a = true;
    var x: u16 = 0;
    if (a) {
        x += 1;
    } else {
        x += 2;
    }
    std.debug.print("x: {}\n", .{x});
    try expect(x == 1);
}

test "if statment expression" {
    const a = true;
    var x: u16 = 0;
    x += if (a) 1 else 2;
    try expect(x == 1);
}

test "while" {
    var i: u8 = 2;
    while (i < 100) {
        i *= 2;
    }
    std.debug.print("i: {}\n", .{i});
    try expect(i == 128);
}

test "while with continue expression" {
    var sum: u8 = 0;
    var i: u8 = 1;
    while (i <= 10) : (i += 1) {
        sum += i;
    }
    std.debug.print("sum: {}\n", .{sum});
    try expect(sum == 55);
}

test "while with continue" {
    var sum: u8 = 0;
    var i: u8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) continue;
        sum += i;
        std.debug.print("i: {}, sum: {}\n", .{ i, sum });
    }
    std.debug.print("sum: {}\n", .{sum});
    try expect(sum == 4);
}

test "while with break" {
    var sum: u8 = 0;
    var i: u8 = 0;
    while (i <= 3) : (i += 1) {
        if (i == 2) break;
        sum += i;
        std.debug.print("i: {}, sum: {}\n", .{ i, sum });
    }
    std.debug.print("sum: {}\n", .{sum});
    try expect(sum == 1);
}

test "for" {
    const string = [_]u8{ 'a', 'b', 'c' };
    var sum: u128 = 0;
    for (string) |char| {
        sum += char;
    }
    std.debug.print("sum: {}\n", .{sum});
    try expect(sum == 294);

    for (string, 0..) |char, index| {
        std.debug.print("char: {}, index: {}\n", .{ char, index });
    }

    for (string) |char| {
        std.debug.print("char: {}\n", .{char});
    }

    for (string, 0..) |_, index| {
        std.debug.print("index: {}\n", .{index});
    }

    for (string) |_| {}
}

fn addFive(x: u32) u32 {
    return x + 5;
}

test "function" {
    const y = addFive(0);
    try expect(@TypeOf(y) == u32);
    try expect(y == 5);
}

fn fibonacci(n: u16) u16 {
    if (n == 0 or n == 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

test "function recursion" {
    const x = fibonacci(10);
    try expect(x == 55);
}

// defer

test "defer" {
    var x: i16 = 5;
    {
        defer x += 2;
        defer x += 3;
        try expect(x == 5);
        std.debug.print("x: {}\n", .{x});
    }
    try expect(x == 10);
    std.debug.print("x: {}\n", .{x});
}

test "multi defer" {
    var x: f32 = 5;
    {
        defer x += 2;
        defer x /= 2;
    }
    try expect(x == 4.5);
    std.debug.print("x: {}\n", .{x});
}

const FileOpenError = error{
    AccessDenied,
    OutOfMemory,
    FileNotFound,
};

const AllocationError = error{OutOfMemory};

test "coerce error from a subset to a superset" {
    const err: FileOpenError = AllocationError.OutOfMemory;
    try expect(err == FileOpenError.OutOfMemory);
}

test "error union" {
    const maybe_error: AllocationError!u16 = 10;
    const no_error = maybe_error catch 0;

    try expect(@TypeOf(no_error) == u16);
    try expect(no_error == 10);
}

fn failingFunction() error{Oops}!void {
    return error.Oops;
}

test "returning an error" {
    failingFunction() catch |err| {
        try expect(err == error.Oops);
        return;
    };
}

fn failFn() error{Oops}!i32 {
    try failingFunction();
    return 12;
}

test "try" {
    const v = failFn() catch |err| {
        try expect(err == error.Oops);
        return;
    };
    try expect(v == 12); // is never reached
}

var problems: u32 = 98;

fn failFnCounter() error{Oops}!void {
    errdefer problems += 1;
    try failingFunction();
}

test "errdefer" {
    failFnCounter() catch |err| {
        try expect(err == error.Oops);
        std.debug.print("problems: {}\n", .{problems});
        try expect(problems == 99);
        return;
    };
}

fn createFile() !void {
    return error.AccessDenied;
}

test "inferred error set" {
    const x: error{AccessDenied}!void = createFile();

    _ = x catch {};
}

const A = error{ NotDir, PathNotFound };
const B = error{ OutOfMemory, PathNotFound };
const C = A || B;

test "test merged error" {
    std.debug.print("{}\n", .{C});
}

test "switch statement" {
    var x: i18 = 10;
    switch (x) {
        -1...1 => {
            x = -x;
        },
        10, 100 => {
            x = @divExact(x, 10);
        },
        else => {},
    }
    try expect(x == 1);
}

test "switch expression" {
    var x: i18 = 10;
    x = switch (x) {
        -1...1 => -x,
        10, 100 => @divExact(x, 10),
        else => x,
    };
    try expect(x == 1);
}

fn fizzBuzz(n: u32) !void {
    for (1..n + 1) |i| {
        const fizz = i % 3 == 0;
        const buzz = i % 5 == 0;
        if (fizz and buzz) {
            std.debug.print("FizzBuzz\n", .{});
        } else if (fizz) {
            std.debug.print("Fizz\n", .{});
        } else if (buzz) {
            std.debug.print("Buzz\n", .{});
        } else {
            std.debug.print("{}\n", .{i});
        }
    }
}

const FizzBuzzType = enum {
    fizz,
    buzz,
    fizzbuzz,
    number,
};

fn getFizzBuzzType(n: usize) FizzBuzzType {
    const fizz = n % 3 == 0;
    const buzz = n % 5 == 0;

    if (fizz and buzz) return .fizzbuzz;
    if (fizz) return .fizz;
    if (buzz) return .buzz;
    return .number;
}

fn fizzBuzzSwitch(n: u32) !void {
    for (1..n + 1) |i| {
        switch (getFizzBuzzType(i)) {
            .fizzbuzz => std.debug.print("FizzBuzz\n", .{}),
            .fizz => std.debug.print("Fizz\n", .{}),
            .buzz => std.debug.print("Buzz\n", .{}),
            .number => std.debug.print("{}\n", .{i}),
        }
    }
}

fn fizzBuzz2(n: u32) !void {
    for (1..n + 1) |i| {
        const fizz = i % 3 == 0;
        const buzz = i % 5 == 0;

        if (fizz and buzz) {
            std.debug.print("FizzBuzz\n", .{});
        } else if (fizz) {
            std.debug.print("Fizz\n", .{});
        } else if (buzz) {
            std.debug.print("Buzz\n", .{});
        } else {
            std.debug.print("{}\n", .{i});
        }
    }
}

const FizzBuzz = struct {
    fizz: bool,
    buzz: bool,

    pub fn new(fizz: bool, buzz: bool) FizzBuzz {
        return FizzBuzz{ .fizz = fizz, .buzz = buzz };
    }
};

const FizzBuzzState = union(enum) {
    fizzbuzz,
    fizz,
    buzz,
    number: u32,

    fn from(n: u32) FizzBuzzState {
        const fizz = n % 3 == 0;
        const buzz = n % 5 == 0;

        if (fizz and buzz) return .fizzbuzz;
        if (fizz) return .fizz;
        if (buzz) return .buzz;
        return .{ .number = n };
    }
};

fn fizzBuzz3(n: u32) !void {
    for (1..n + 1) |i| {
        const cast_i: u32 = @intCast(i);
        switch (FizzBuzzState.from(cast_i)) {
            .fizzbuzz => std.debug.print("FizzBuzz\n", .{}),
            .fizz => std.debug.print("Fizz\n", .{}),
            .buzz => std.debug.print("Buzz\n", .{}),
            .number => |num| std.debug.print("{}\n", .{num}),
        }
    }
}

test "fizzbuzz" {
    try fizzBuzz(15);
    std.debug.print("--------------\n", .{});
}

test "fizzbuzz switch" {
    const num: u32 = 15;
    try fizzBuzzSwitch(num);
    std.debug.print("--------------\n", .{});
}

test "fizzbuzz3" {
    try fizzBuzz3(15);
    std.debug.print("--------------\n", .{});
}

test "out of bounds" {
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = 5;
    //const b = a[index]; // index out of bounds

    //_ = b;
    _ = a;
    index = index;
}

test "out of bounds, no safety" {
    @setRuntimeSafety(false);
    const a = [3]u8{ 1, 2, 3 };
    var index: u8 = 5;
    const b = a[index]; // index out of bounds

    _ = b;
    index = index;
}

test "unreachable" {
    const x: i32 = 1;
    //const y: u32 = if (x == 2) 5 else unreachable;
    //_ = y;
    _ = x;
}

fn assciiToUpper(x: u8) u8 {
    return switch (x) {
        'a'...'z' => x + 'A' - 'a',
        'A'...'Z' => x,
        else => unreachable,
    };
}

test "unreachable switch" {
    try expect(assciiToUpper('a') == 'A');
    try expect(assciiToUpper('A') == 'A');
    //std.debug.print("{}\n", .{assciiToUpper(255)});
}

fn increment(num: *u8) void {
    num.* += 1;
}

test "pointers" {
    var x: u8 = 1;
    increment(&x);
    std.debug.print("x = {}\n", .{x});
    try expect(x == 2);
}

test "naughty pointer" {
    var x: u16 = 5;
    x -= 5;
    //var y: *u8 = @ptrFromInt(x); // cast causes pointer to be null
    //y = y;
}

test "const pointers" {
    //const x: u8 = 1;
    //var y = &x;
    //y.* += 1; // cannot assign to constant
}

test "usize" {
    try expect(@sizeOf(usize) == @sizeOf(*u8));
    try expect(@sizeOf(isize) == @sizeOf(*u8));
    std.debug.print("usize size: {}\n", .{@sizeOf(usize)});
}

fn doubleAllManyPointer(buffer: [*]u8, byte_count: usize) void {
    var i: usize = 0;
    while (i < byte_count) : (i += 1) buffer[i] *= 2;
}

// TODO : Pointer to array
test "many-item pointers" {
    var buffer: [10]u8 = [_]u8{1} ** 10;
    std.debug.print("buffer[0] = {}\n", .{buffer[0]});
    std.debug.print("buffer = {any}\n", .{buffer});
    const buffer_ptr: *[10]u8 = &buffer;
    std.debug.print("buffer_ptr[0] = {}\n", .{buffer_ptr[0]});

    // TODO: convert *[10]u8 to [*]u8
    const buffer_may_ptr: [*]u8 = buffer_ptr;
    std.debug.print("buffer_may_ptr = {any}\n", .{buffer_may_ptr});
    doubleAllManyPointer(buffer_may_ptr, buffer.len);
    std.debug.print("buffer = {any}\n", .{buffer});
    for (buffer) |byte| try expect(byte == 2);

    // TODO: &buffer[0] And @ptrCast(&buffer[0])
    const first_elem_ptr: *u8 = &buffer_may_ptr[0];
    const first_elem_ptr_2: *u8 = @ptrCast(buffer_may_ptr);
    std.debug.print("first_elem_ptr = {}\n", .{first_elem_ptr});
    std.debug.print("first_elem_ptr_2 = {}\n", .{first_elem_ptr_2});
    try expect(first_elem_ptr == first_elem_ptr_2);
}

fn total(values: []const u8) usize {
    var sum: usize = 0;
    for (values) |v| sum += v;
    return sum;
}

test "slices" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    try expect(total(slice) == 6);
}

test "slice 2" {
    const array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..3];
    std.debug.print("slice = {any}\n", .{@TypeOf(slice)});
    try expect(@TypeOf(slice) == *const [3]u8);

    var array2 = [_]u8{ 1, 2, 3, 4, 5 };
    std.debug.print("array2 = {any}\n", .{@TypeOf(array2)});
    const slice2 = array2[0..3];
    std.debug.print("slice2 = {any}\n", .{@TypeOf(slice2)});
    std.debug.print("slice2 = {any}\n", .{slice2});
    array2 = [_]u8{ 6, 7, 8, 9, 10 };
    std.debug.print("slice2 = {any}\n", .{@TypeOf(slice2)});
    std.debug.print("slice2 = {any}\n", .{slice2});
    try expect(@TypeOf(slice2) == *[3]u8);
}

test "slice 3" {
    var array = [_]u8{ 1, 2, 3, 4, 5 };
    const slice = array[0..];
    _ = slice;
}

// TODO: compare *T(single pointer), *[N]T, [*]T, []T(Slice)
// *T is a pointer to a single element
// *[N]T is a pointer to an array of N elements
// [*]T is a pointer to an array of unknown length
// []T(Slice) is a slice of an array of unknown length

const Direction = enum { north, south, east, west };

const Value = enum(u8) { zero, one, two };

test "enum ordinal value" {
    try expect(@intFromEnum(Value.zero) == 0);
    try expect(@intFromEnum(Value.one) == 1);
    try expect(@intFromEnum(Value.two) == 2);
}

const Value2 = enum(u32) {
    hundred = 100,
    thousand = 1000,
    million = 1000000,
    next,
};

test "set enum ordinal value" {
    try expect(@intFromEnum(Value2.hundred) == 100);
    try expect(@intFromEnum(Value2.thousand) == 1000);
    try expect(@intFromEnum(Value2.million) == 1000000);
    try expect(@intFromEnum(Value2.next) == 1000001);
}

test "enum ordinal value 2" {
    try expect(@intFromEnum(Value2.hundred) == 100);
    try expect(@intFromEnum(Value2.thousand) == 1000);
    try expect(@intFromEnum(Value2.million) == 1000000);
    try expect(@intFromEnum(Value2.next) == 1000001);
}

const Suit = enum {
    Clubs,
    Spades,
    Diamonds,
    Hearts,

    pub fn isClubs(self: Suit) bool {
        return self == .Clubs;
    }
};

test "enum method" {
    try expect(Suit.Spades.isClubs() == Suit.isClubs(.Spades));
}

const Mode = enum {
    var count: u32 = 0;
    on,
    off,
};

test "hmm" {
    Mode.count += 1;
    try expect(Mode.count == 1);
}

const VecV3 = struct {
    x: f32,
    y: f32,
    z: f32,
};
test "struct usage" {
    const my_vector = VecV3{
        .x = 0.0,
        .y = 0.0,
        .z = 0.0,
    };
    _ = my_vector;
}

test "missing struct filed" {
    // error: missing struct filed: y
    //const my_vector = VecV3{
    //    .x = 0.0,
    //    .z = 40.0,
    //};

    //_ = my_vector;
}

const Vec4 = struct {
    x: f32 = 0.0,
    y: f32 = 0.0,
    z: f32 = 0.0,
    w: f32 = 0.0,
};

test "struct defaults" {
    const my_vector = Vec4{
        .x = 23.0,
        .y = 22.0,
    };
    _ = my_vector;
}

const Stuff = struct {
    x: i32,
    y: i32,

    fn swap(self: *Stuff) void {
        const tmp = self.x;
        self.x = self.y;
        self.y = tmp;
    }
};

test "automatic dereference" {
    var thing = Stuff{
        .x = 10,
        .y = 20,
    };
    thing.swap();
    try expect(thing.x == 20);
    try expect(thing.y == 10);
}

const Result = union {
    int: i64,
    float: f64,
    bool: bool,
};

test "simple union" {
    //var result = Result{ .int = 1234 };
    //result.float = 1234.5678; // panic: access of union field 'float' while field 'int' is active
}

const Tag = enum { a, b, c };

// const Tagged = union(enum) { a: u8, b: u32, c: bool}
const Tagged = union(Tag) {
    a: u8,
    b: f32,
    c: bool,
};

test "switch on tagged union" {
    var value = Tagged{ .b = 1.5 };
    // TODO: swith (value) use on Tagged(union(enum))
    switch (value) {
        .a => |*byte| byte.* += 1,
        .b => |*float| float.* += 1.0,
        .c => |*b| b.* = !b.*,
    }
    try expect(value.b == 2.5);
}

//test "integer rules" {
//const decimal_int: i32 = 9822;
//const hex_int: u8 = 0xff;
//const another_hex_int: u8 = 0xFF;
//const octal_int: u16 = 0o77;
//const binary_int: u8 = 0b10101010;
//}

test "tuple" {
    const values = .{
        @as(u32, 1234),
        @as(f32, 1234.5678),
        true,
        "hi",
    } ++ .{false} ** 2;
    std.debug.print("{any}\n", .{values});
    try expect(values[0] == 1234);
    try expect(values[4] == false);
    inline for (values, 0..) |v, i| {
        if (i != 2) continue;
        try expect(v);
        std.debug.print("{any}\n", .{v});
    }
    try expect(values.len == 6);
    try expect(values.@"3"[0] == 'h');
}

const User = struct {
    power: u64,
    name: []const u8,
};

test "struct2" {
    const user = User{
        .power = 100,
        .name = "John",
    };
    std.debug.print("{s}'s power is {d}\n", .{ user.name, user.power });
    std.debug.print("{any}\n", .{@TypeOf(.{ 2023, 8 })});
    //std.debug.print("{any}\n", .{@TypeOf(.{ .year = 2023, .month = 8 })});
    try expect(user.power == 100);
    try expect(std.mem.eql(u8, user.name, "John"));
}

fn contains(haystack: []const u32, needle: u32) bool {
    for (haystack) |item| {
        if (item == needle) return true;
    }
    return false;
}

test "contains" {
    try expect(contains(&[_]u32{ 1, 2, 3 }, 2));
    try expect(!contains(&[_]u32{ 1, 2, 3 }, 4));
}

fn eql(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;

    for (a, b) |a_elem, b_elem| {
        if (a_elem != b_elem) return false;
    }

    return true;
}

test "eql" {
    try expect(eql(u32, &[_]u32{ 1, 2, 3 }, &[_]u32{ 1, 2, 3 }));
    try expect(!eql(u32, &[_]u32{ 1, 2, 3 }, &[_]u32{ 1, 2, 4 }));
}

fn indexOf(haystack: []const u32, needle: u32) ?usize {
    for (haystack, 0..) |value, idx| {
        if (needle == value) return idx;
    }
    return null;
}

test "indexOf" {
    try expect(indexOf(&[_]u32{ 1, 2, 3 }, 2) == 1);
    try expect(indexOf(&[_]u32{ 1, 2, 3 }, 4) == null);
}

const Stage = enum {
    validate,
    awaiting_confirmation,
    confirmed,
    err,

    fn isComplete(self: Stage) bool {
        return self == .confirmed or self == .err;
    }
};

test "enum" {
    try expect(!Stage.validate.isComplete());
    try expect(!Stage.awaiting_confirmation.isComplete());
    try expect(Stage.confirmed.isComplete());
    try expect(Stage.err.isComplete());

    // @tagName to get the name of the enum value string
    std.debug.print("Stage: {s}\n", .{@tagName(Stage.validate)});
}

const Timestamp = union(enum) {
    unix: i32,
    utc: DateTime,

    const DateTime = struct {
        year: i32,
        month: u8,
        day: u8,
        hour: u8,
        minute: u8,
        second: u8,
    };

    pub fn fromUnix(timestamp: i32) Timestamp {
        return Timestamp{ .unix = timestamp };
    }

    pub fn fromUtc(year: i32, month: u8, day: u8, hour: u8, minute: u8, second: u8) Timestamp {
        return Timestamp{ .utc = DateTime{ .year = year, .month = month, .day = day, .hour = hour, .minute = minute, .second = second } };
    }

    fn seconds(self: Timestamp) u16 {
        switch (self) {
            .utc => |utc| return utc.second,
            .unix => |unix| {
                const seconds_since_midnight: i32 = @rem(unix, 86400);
                return @intCast(@rem(seconds_since_midnight, 60));
            },
        }
    }
};

test "Timestamp" {
    const tt = Timestamp{ .unix = 1630456800 };
    try expect(tt.seconds() == 0);
    try expect(Timestamp.fromUnix(1630456860).seconds() == 0);
}

test "optional" {
    const home: ?[]const u8 = null;
    const name: ?[]const u8 = "John Doe";
    try expect(home == null);
    try expect(name != null);
    std.debug.print("name: {s}\n", .{name.?});
}
