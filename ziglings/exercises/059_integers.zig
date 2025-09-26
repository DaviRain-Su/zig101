//
// Zig 允许你用多种方便的格式来表示整数字面量。下面这些值都是相同的：
//
//     const a1: u8 = 65;          // 十进制
//     const a2: u8 = 0x41;        // 十六进制
//     const a3: u8 = 0o101;       // 八进制
//     const a4: u8 = 0b1000001;   // 二进制
//     const a5: u8 = 'A';         // ASCII 码点字面量
//     const a6: u16 = '\u{0041}'; // Unicode 码点可占用最多 21 位
//
// 你也可以在数字中加入下划线以增强可读性：
//
//     const t1: u32 = 14_689_520 // T 型福特 1909-1927 销量
//     const t2: u32 = 0xE0_24_F0 // 相同数值，用十六进制字节对表示
//
// 请修复这条消息：
const print = @import("std").debug.print;

pub fn main() void {
    const zig = [_]u8{
        0o131, // 八进制
        0b1101000, // 二进制
        0x66, // 十六进制
    };

    print("{s} is cool.\n", .{zig});
}
