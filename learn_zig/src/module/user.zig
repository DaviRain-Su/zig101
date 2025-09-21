const std = @import("std");

pub const MAX_POWER = 1000;

pub const User = struct {
    power: u64 = 0, // set default power to 0
    name: []const u8,

    pub const SUPER_POWER = MAX_POWER;

    pub fn diagnose(self: User) void {
        if (self.power > SUPER_POWER) {
            std.debug.print("It's over {d}", .{SUPER_POWER});
        }
    }
};

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
