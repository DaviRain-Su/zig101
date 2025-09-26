//
// **哨兵值**（sentinel value）表示数据的结束。
// 假设有一个小写字母的序列，其中大写字母 'S' 是哨兵，表示序列的结束：
//
//     abcdefS
//
// 如果我们的序列中也允许大写字母，那 'S' 就成了糟糕的哨兵，
// 因为它可能作为普通值出现在序列中：
//
//     abcdQRST
//          ^-- 哎呀！序列最后一个字母其实是 R！
//
// 一个常见的选择是用数值 0 来表示字符串的结束。
// 在 ASCII 和 Unicode 中，这个值叫做 **空字符**（Null Character）。
//
// Zig 支持以下几种带哨兵的数组、切片和指针：
//
//     const a: [4:0]u32       =  [4:0]u32{1, 2, 3, 4};
//     const b: [:0]const u32  = &[4:0]u32{1, 2, 3, 4};
//     const c: [*:0]const u32 = &[4:0]u32{1, 2, 3, 4};
//
// 数组 `a` 实际存储了 5 个 `u32` 值，最后一个是 0。
// 不过编译器会帮你处理这些细节。你可以把 `a` 当成只有 4 个元素的数组来使用。
//
// 切片 `b` 只能指向以零结尾的数组，但用法和普通切片一样。
//
// 指针 `c` 和我们在练习 054 学过的多项指针几乎一样，
// 唯一不同是它保证以 0 结尾。
// 因为有这个保证，我们可以在不知道长度的情况下安全地找到它的结尾。
// （普通的多项指针是做不到这一点的！）
//
// ⚠️ 重要提示：哨兵值必须和被终止的数据的类型一致！
//
const print = @import("std").debug.print;
const sentinel = @import("std").meta.sentinel;

pub fn main() void {
    // 这里是一个以零结尾的 u32 数组：
    var nums = [_:0]u32{ 1, 2, 3, 4, 5, 6 };

    // 这里是一个以零结尾的多项指针：
    const ptr: [*:0]u32 = &nums;

    // 好玩一下，把位置 3 的值替换为哨兵值 0。
    // 感觉有点调皮。
    nums[3] = 0;

    // 所以现在我们有了一个以零结尾的数组和一个多项指针，
    // 它们指向相同的数据：一个既以哨兵结尾又包含哨兵的序列。
    //
    // 尝试循环打印它们两个，就能看出它们相同和不同的地方。
    //
    // （结果是：数组会完整打印，包括中间的哨兵 0；
    // 多项指针会在遇到第一个哨兵值时停止。）
    printSequence(nums);
    printSequence(ptr);

    print("\n", .{});
}

// 这是一个通用的序列打印函数。几乎完成了，
// 只是还缺少几个部分。请修复它！
fn printSequence(my_seq: anytype) void {
    const my_typeinfo = @typeInfo(@TypeOf(my_seq));

    // `my_typeinfo` 里的 TypeInfo 是一个联合类型。
    // 我们用 switch 来处理 Array 或 Pointer，
    // 取决于传入的 my_seq 是哪种类型：
    switch (my_typeinfo) {
        .array => {
            print("Array:", .{});

            // 循环遍历 my_seq 中的元素。
            for (???) |s| {
                print("{}", .{s});
            }
        },
        .pointer => {
            // 看这个 —— 超酷：
            const my_sentinel = sentinel(@TypeOf(my_seq));
            print("Many-item pointer:", .{});

            // 循环遍历 my_seq 中的元素，直到遇到哨兵值。
            var i: usize = 0;
            while (??? != my_sentinel) {
                print("{}", .{my_seq[i]});
                i += 1;
            }
        },
        else => unreachable,
    }
    print(". ", .{});
}
