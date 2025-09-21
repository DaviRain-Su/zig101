const std = @import("std");

pub const MAX_POWER = 1000;

pub const User = struct {
    power: u64 = 0, // set default power to 0
    name: []const u8,

    const Self = @This();

    pub const SUPER_POWER = MAX_POWER;

    pub fn init(name: []const u8, power: u64) Self {
        return .{
            .power = power,
            .name = name,
        };
    }

    pub fn diagnose(self: User) void {
        if (self.power > SUPER_POWER) {
            std.debug.print("It's over {d}\n", .{SUPER_POWER});
        }
    }

    fn levelUp(self: *User) void {
        std.debug.print("Leveling up...{*}\n", .{self});
        self.power += 1;
        std.debug.print("Level: {s} with power {d}\n", .{ self.name, self.power });
    }
};

test "levelUp" {
    var user = User.init("John Doe", 1000000);
    std.debug.print("USER ADDRESS:\n{*}\n{*}\n{*}\n", .{ &user, &user.power, &user.name });
    std.debug.print("user address: {*}\n", .{&user});
    const user_p = &user;
    std.debug.print("user address type: {any}\n", .{@TypeOf(user_p)});
    user.levelUp();
    std.debug.print("User: {s} with power {d}\n", .{ user.name, user.power });
    user.diagnose();
}

// define Empty struct
pub const Empty = struct {};

test "test empty struct" {
    try std.testing.expect(@sizeOf(Empty) == 0);
}

test "example user struct" {
    const user: User = .{
        .power = 1000000,
        .name = "John Doe",
    };

    std.debug.print("User: {s} with power {d}\n", .{ user.name, user.power });
    user.diagnose();
}

test "use init function" {
    const user = User.init("John Doe", 1000000);
    std.debug.print("User: {s} with power {d}\n", .{ user.name, user.power });
    user.diagnose();
}

// IMPORTANT:
//
// - 固定数组 [N]T : 固定长度数组，类型包含长度信息。例如 [3]u8。
//      - 取地址 &arr 得到 *[N]T（若 arr 是 const 绑定，则是 *const [N]T）。
//      - 可以用 arr[lo..hi] 取切片（类型 []T），运行时携带 length。
// - 推断长度数组 [_]T: 推断长度数组字面量，编译器从初始化器里数元素个数，推断出长度，最终类型还是 [N]T（只是省略 N 的写法）。
//      - 仅在字面量初始化时使用，最终类型还是 [N]T。
//      - 方便省略 N，编译期据元素数目确定。
// - 切片 []T / []const T: 切片类型，动态长度视图，包含指针+长度，不拥有数据；const 修饰元素不可变。
//      - 动态视图，不拥有数据，本质是 { ptr: *T, len: usize }。
//      - []const T 表示元素不可通过此视图修改（只读视图）。
//      - 可从数组取切片：arr[0..2] 是 []T。
//      - 可从数组指针得到切片：&arr（*[N]T）可隐式退化为 []T。
// - 指向数组的指针 *[N]T / *const [N]T：指向固定长度数组的指针，数组和长度都在类型里，
//   const 修饰整个数组对象不可通过这根指针修改。
//      - 指向一个“长度固定且作为类型一部分”的数组对象。
//      - 优点：在类型层面携带长度信息，编译器可做更强校验。
//      - 退化：传到需要切片的地方时可自动退化为 []T 或 []const T。
// - 与 std.mem.eql 搭配
//   - eql(comptime T, a: []const T, b: []const T) 比较两个切片内容是否相同。
//   - 可以传入[]T 或 []const T
//   - *[N]T 或 *const [N]T（会退化）
//   - [N]T 也行，但要先取地址或切片，常见写法是 &arr 或 arr[0..]
test "compare array []u8 with []const u8" {
    const array1 = [3]u8{ 1, 2, 3 };
    const array2 = [3]u8{ 1, 2, 3 };
    const ra1 = &array1; // 是一个指针指向的不可变长度为3的数组， &array1 的类型是 *const [3]u8（对 const 绑定的值取地址）
    const ra2 = &array2;

    //std.mem.eql(u8, a, b) 接受“连续 u8 序列”，常见是切片 []const u8，
    //但 Zig 会对数组指针进行必要的“数组退化”为切片：*const [N]u8 可隐式转换到 []const u8
    try std.testing.expect(std.mem.eql(u8, ra1, ra2));

    //array1[0..2] 的原生类型其实是切片 []u8（运行时长度），不是 *const [2]u8
    // Zig 允许从一个“恰好是编译期已知长度的切片表达式”进行“切片到数组指针”的转换：
    // []T 长度为常量 2 时，可转换为 *[2]T；const 绑定再叠加成 *const [2]u8
    const slice1 = array1[0..2];
    const slice2 = array2[0..2];
    //slice1/2 是“指向长度为 2 的数组”的指针类型，因此传给 eql 时同样会退化成 []const u8
    try std.testing.expect(std.mem.eql(u8, slice1, slice2));

    const array3 = [_]u8{ 1, 2, 3, 4 };
    const array4 = [_]u8{ 1, 2, 3, 4 };
    //[_]u8 让编译器推断长度，这里变成 [4]u8；&array3 类型是 *const [4]u8
    // eql 再次通过退化为切片进行内容比较
    try std.testing.expect(std.mem.eql(u8, &array3, &array4));

    var end: usize = 1;
    end += 1;
    const slice3 = array1[0..end];
    const slice4 = array2[0..end];
    //@compileLog(@TypeOf(slice3)); slice3 is [] const u8
    try std.testing.expect(std.mem.eql(u8, slice3, slice4));

    const slice5 = array1[0..];
    const slice6 = array2[0..];
    try std.testing.expect(std.mem.eql(u8, slice5, slice6));
}

test "匿名结构体" {
    //pub fn print(comptime fmt: []const u8, args: anytype) void
    // .{ 2023, 8 }
    std.debug.print("{any}\n", .{@TypeOf(.{ 2023, 8 })});
    const inner_struct = .{ 2023, 8 };
    const inner_struct2 = .{ 2023, 8 };
    try std.testing.expect(std.mem.eql(u8, @typeName(@TypeOf(inner_struct)), @typeName(@TypeOf(inner_struct2))));
}

pub fn contains(comptime T: type, value: T, slice: []const T) bool {
    for (slice) |item| {
        if (item == value) return true;
    }
    return false;
}

test "contains" {
    const array = [_]u8{ 1, 2, 3, 4 };
    try std.testing.expect(contains(u8, 2, &array));
    try std.testing.expect(!contains(u8, 5, &array));
}

pub fn equals(comptime T: type, a: []const T, b: []const T) bool {
    if (a.len != b.len) return false;
    for (a, b) |item_a, item_b| {
        if (item_a != item_b) return false;
    }
    return true;
}

test "equals" {
    const array1 = [_]u8{ 1, 2, 3, 4 };
    const array2 = [_]u8{ 1, 2, 3, 4 };
    try std.testing.expect(equals(u8, &array1, &array2));
}

pub fn indexOf(comptime T: type, value: T, slice: []const T) ?usize {
    for (slice, 0..) |item, index| {
        if (item == value) return index;
    }
    return null;
}

test "indexOf" {
    const array = [_]u8{ 1, 2, 3, 4 };
    try std.testing.expect(indexOf(u8, 2, &array) == 1);
    try std.testing.expect(indexOf(u8, 5, &array) == null);
}

//  接受一个 T 类型并给我们一个 *T 类型。
// .* 是相反的操作，应用于一个 *T 类型的值时，它给我们一个 T 类型。即，&获取地址，.*获取值。
//
// 一种类似于接口的模式是带标签的联合（tagged unions），不过与真正的接口相比，这种模式相对受限。
