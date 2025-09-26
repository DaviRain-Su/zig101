//
// 在目前的大多数示例中，输入在编译时已知，因此程序所使用的内存量是固定的。
// 然而，如果要响应在编译时未知大小的输入，比如：
//  - 来自命令行参数的用户输入
//  - 来自其他程序的输入
//
// 那么你需要向操作系统在运行时申请内存。
//
// Zig 提供了多种分配器。在 Zig 文档中，推荐在简单的程序里使用 Arena 分配器，
// 因为它们只分配一次然后退出：
//
//     const std = @import("std");
//
//     // 内存分配可能失败，所以返回类型是 !void
//     pub fn main() !void {
//
//         var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
//         defer arena.deinit();
//
//         const allocator = arena.allocator();
//
//         const ptr = try allocator.create(i32);
//         std.debug.print("ptr={*}\n", .{ptr});
//
//         const slice_ptr = try allocator.alloc(f64, 5);
//         std.debug.print("slice_ptr={*}\n", .{slice_ptr});
//     }

// 与其分配一个简单整数或固定大小的切片，
// 这个程序需要分配一个和输入数组大小相同的切片。

// 给定一组数字，计算它的“运行平均值”。
// 换句话说，每个第 N 个元素应包含最近 N 个元素的平均值。

const std = @import("std");

fn runningAverage(arr: []const f64, avg: []f64) void {
    var sum: f64 = 0;

    for (0.., arr) |index, val| {
        sum += val;
        const f_index: f64 = @floatFromInt(index + 1);
        avg[index] = sum / f_index;
    }
}

pub fn main() !void {
    // 假装这是用户输入得到的
    const arr: []const f64 = &[_]f64{ 0.3, 0.2, 0.1, 0.1, 0.4 };

    // 初始化分配器
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    // 程序退出时释放内存
    defer arena.deinit();

    // 获取分配器
    const allocator = arena.allocator();

    // 为这个数组分配内存
    const avg: []f64 = try allocator.alloc(f64, arr.len);

    runningAverage(arr, avg);
    std.debug.print("Running Average: ", .{});
    for (avg) |val| {
        std.debug.print("{d:.2} ", .{val});
    }
    std.debug.print("\n", .{});
}

// 想了解更多关于内存分配和不同类型分配器的细节，
// 可以参考 https://www.youtube.com/watch?v=vHWiDx_l4V0
