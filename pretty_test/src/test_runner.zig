const std = @import("std");
const builtin = @import("builtin");
const print = std.debug.print;

// ANSI 颜色代码
const Color = struct {
    const reset = "\x1b[0m";
    const red = "\x1b[31m";
    const green = "\x1b[32m";
    const yellow = "\x1b[33m";
    const blue = "\x1b[34m";
    const cyan = "\x1b[36m";
    const gray = "\x1b[90m";
    const bold = "\x1b[1m";
    const dim = "\x1b[2m";
};

pub fn main() !void {
    // Windows 上启用 ANSI 颜色
    if (builtin.os.tag == .windows) {
        const windows = std.os.windows;
        const kernel32 = windows.kernel32;
        const handle = kernel32.GetStdHandle(windows.STD_OUTPUT_HANDLE);
        var mode: windows.DWORD = undefined;
        if (kernel32.GetConsoleMode(handle, &mode) != 0) {
            _ = kernel32.SetConsoleMode(handle, mode | 0x0004);
        }
    }

    const test_list = builtin.test_functions;
    const start_time = std.time.milliTimestamp();

    // 打印美化头部
    print("\n", .{});
    print("{s}╔══════════════════════════════════════════════════════════╗{s}\n", .{ Color.cyan, Color.reset });
    print("{s}║{s}             {s}Zig Pretty Test Runner{s}                      {s}║{s}\n", .{ Color.cyan, Color.reset, Color.bold, Color.reset, Color.cyan, Color.reset });
    print("{s}╚══════════════════════════════════════════════════════════╝{s}\n", .{ Color.cyan, Color.reset });
    print("\n", .{});

    print("{s}Running {d} test(s){s}\n", .{ Color.blue, test_list.len, Color.reset });

    // 修复：打印横线，使用重复字符
    var i: usize = 0;
    print("{s}", .{Color.gray});
    while (i < 60) : (i += 1) {
        print("─", .{});
    }
    print("{s}\n\n", .{Color.reset});

    var passed: usize = 0;
    var failed: usize = 0;
    var skipped: usize = 0;

    // 运行每个测试
    for (test_list) |test_fn| {
        const test_start = std.time.milliTimestamp();

        // 打印测试名称 - 需要手动填充空格
        print("test ", .{});
        print("{s}", .{test_fn.name});

        // 计算需要填充的空格数
        const name_len = test_fn.name.len;
        if (name_len < 50) {
            var j: usize = name_len;
            while (j < 50) : (j += 1) {
                print(" ", .{});
            }
        }
        print(" ", .{});

        // 运行测试
        if (test_fn.func()) |_| {
            // 测试通过
            const duration = std.time.milliTimestamp() - test_start;
            passed += 1;
            print("{s}✓ passed{s}", .{ Color.green, Color.reset });
            if (duration > 0) {
                print(" {s}({d}ms){s}", .{ Color.dim, duration, Color.reset });
            }
            print("\n", .{});
        } else |err| switch (err) {
            error.SkipZigTest => {
                // 测试跳过
                skipped += 1;
                print("{s}⊘ skipped{s}\n", .{ Color.yellow, Color.reset });
            },
            else => {
                // 测试失败
                const duration = std.time.milliTimestamp() - test_start;
                failed += 1;
                print("{s}✗ FAILED{s}", .{ Color.red, Color.reset });
                if (duration > 0) {
                    print(" {s}({d}ms){s}", .{ Color.dim, duration, Color.reset });
                }
                print("\n", .{});
                print("  {s}└─ Error: {any}{s}\n", .{ Color.red, err, Color.reset });
            },
        }
    }

    // 打印总结
    const elapsed = std.time.milliTimestamp() - start_time;
    const elapsed_sec = @as(f64, @floatFromInt(elapsed)) / 1000.0;

    // 打印分隔线
    print("\n{s}", .{Color.gray});
    i = 0;
    while (i < 60) : (i += 1) {
        print("─", .{});
    }
    print("{s}\n", .{Color.reset});

    print("{s}Test Result:{s} ", .{ Color.bold, Color.reset });

    if (failed == 0) {
        print("{s}✓ PASSED{s}\n\n", .{ Color.green, Color.reset });
    } else {
        print("{s}✗ FAILED{s}\n\n", .{ Color.red, Color.reset });
    }

    // 统计信息
    print("  {s}{d} passed{s}", .{ Color.green, passed, Color.reset });
    if (failed > 0) {
        print("  {s}{d} failed{s}", .{ Color.red, failed, Color.reset });
    }
    if (skipped > 0) {
        print("  {s}{d} skipped{s}", .{ Color.yellow, skipped, Color.reset });
    }
    print("\n", .{});

    // 时间和通过率
    print("  {s}Duration:{s} {d:.2}s\n", .{ Color.cyan, Color.reset, elapsed_sec });

    const total = passed + failed + skipped;
    if (total > 0) {
        const pass_rate = (@as(f64, @floatFromInt(passed)) / @as(f64, @floatFromInt(total))) * 100.0;
        print("  {s}Pass Rate:{s} ", .{ Color.cyan, Color.reset });
        const rate_color = if (pass_rate == 100) Color.green else if (pass_rate >= 80) Color.yellow else Color.red;
        print("{s}{d:.1}%{s}\n", .{ rate_color, pass_rate, Color.reset });
    }

    print("\n", .{});

    // 如果有测试失败，返回非零退出码
    if (failed > 0) {
        std.process.exit(1);
    }
}
