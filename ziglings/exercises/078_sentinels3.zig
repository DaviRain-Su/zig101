//
// 我们之前通过使用切片并指定一个明确的长度，成功从一个多项指针里得到一个可打印的字符串。
//
// 但是在一次强制转换中“丢失”了哨兵之后，
// 我们还能回到哨兵结尾的指针吗？
//
// 答案是：可以。Zig 的 @ptrCast() 内建函数可以做到。来看一下它的函数签名：
//
//     @ptrCast(value: anytype) anytype
//
// 试试看你能否用它解决相同的多项指针问题，
// 但这次不需要长度！
//
const print = @import("std").debug.print;

pub fn main() void {
    // 我们再次把一个哨兵结尾的字符串强制转换成了一个多项指针，
    // 这样它就不再包含长度或哨兵信息。
    const data: [*]const u8 = "Weird Data!";

    // 请把 `data` 转换成 `printable`：
    const printable: [*:0]const u8 = ???;

    print("{s}\n", .{printable});
}
