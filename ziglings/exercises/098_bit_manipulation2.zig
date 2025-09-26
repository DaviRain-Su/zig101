//
// 位操作的另一个有用应用是把位当作标志位 (flags)。
// 这在处理某些列表并存储条目的状态时尤其有用，例如：
// 一个数字列表，并为其中的每个质数设置一个标志位。
//
// 举个例子，我们来看 Exercism 上的 Pangram 练习：
// https://exercism.org/tracks/zig/exercises/pangram
//
// **全字母句 (pangram)** 指的是包含字母表中每个字母至少一次的句子。
// 它不区分大小写，所以字母是大写还是小写无所谓。
// 最著名的英文全字母句是：
//
//           "The quick brown fox jumps over the lazy dog."
//
// 有几种方法可以选择 pangram 中出现的字母（不管它们出现一次还是多次）。
//
// 例如，可以用一个 `bool` 数组，并按照字母顺序（a=0，b=1，等等）
// 在句子中找到的字母对应位置标记为 `true`。
// 但是，这既不节省内存，也不是特别快。
// 因此我们选择一种更简单的方法，原理类似：
// 定义一个至少有 26 位的变量（例如 `u32`），
// 并在对应位置为找到的字母设置标志位。
//
// Zig 在标准库中提供了相应的函数，
// 但我们选择不用这些额外的东西来解决，
// 毕竟我们是来学习的。
//
const std = @import("std");
const ascii = std.ascii;
const print = std.debug.print;

pub fn main() !void {
    // 检查这个句子是否是全字母句
    print("Is this a pangram? {}!\n", .{isPangram("The quick brown fox jumps over the lazy dog.")});
}

fn isPangram(str: []const u8) bool {
    // 首先检查字符串长度是否至少有 26
    if (str.len < 26) return false;

    // 使用一个 32 位变量，其中 26 位即可
    var bits: u32 = 0;

    // 遍历字符串中的所有字符
    for (str) |c| {
        // 如果字符是字母
        if (ascii.isAscii(c) and ascii.isAlphabetic(c)) {
            // 就在对应位置设置标志位
            //
            // 我们用一个小技巧：
            // 由于 ASCII 表中字母是从 65 开始的，
            // 并且是顺序编号的，
            // 所以我们只需用当前字符减去 'a'，
            // 就能得到所需的位位置。
            bits |= @as(u32, 1) << @truncate(ascii.toLower(c) - 'a');
        }
    }
    // 最后我们返回一个比较结果：
    // 如果 26 位都被设置了，
    // 那么这个字符串就是一个全字母句。
    //
    // 但是，我们应该和什么比较呢？
    return bits == 0x..???;
}
