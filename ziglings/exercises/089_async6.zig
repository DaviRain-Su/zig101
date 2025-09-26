//
// 当我们需要同时做多件事时，async/await 的威力和用途就会更加明显。
// Foo 和 Bar 互不依赖，可以同时进行，但 End 必须等它们都完成之后才能执行。
//
//               +---------+
//               |  Start  |
//               +---------+
//                  /    \
//                 /      \
//        +---------+    +---------+
//        |   Foo   |    |   Bar   |
//        +---------+    +---------+
//                 \      /
//                  \    /
//               +---------+
//               |   End   |
//               +---------+
//
// 我们可以在 Zig 中这样表达：
//
//     fn foo() u32 { ... }
//     fn bar() u32 { ... }
//
//     // Start
//
//     var foo_frame = async foo();
//     var bar_frame = async bar();
//
//     var foo_value = await foo_frame;
//     var bar_value = await bar_frame;
//
//     // End
//
// 请等待 **两个** 页面标题！
//
const print = @import("std").debug.print;

pub fn main() void {
    var com_frame = async getPageTitle("http://example.com");
    var org_frame = async getPageTitle("http://example.org");

    var com_title = com_frame;
    var org_title = org_frame;

    print(".com: {s}, .org: {s}.\n", .{ com_title, org_title });
}

fn getPageTitle(url: []const u8) []const u8 {
    // 请假装这实际上是在发起一个网络请求。
    _ = url;
    return "Example Title";
}
