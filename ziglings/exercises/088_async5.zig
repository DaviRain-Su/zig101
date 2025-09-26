//
// 当然，我们可以用全局变量来解决 async 的返回值问题。
// 但这看起来并不是一个理想的方案。
//
// 那么，我们到底该如何真正从 async 函数中获取返回值呢？
//
// 使用 `await` 关键字，它会等待一个 async 函数完成，
// 然后捕获它的返回值。
//
//     fn foo() u32 {
//         return 5;
//     }
//
//     var foo_frame = async foo(); // 调用并获取函数帧
//     var value = await foo_frame; // 使用 await 等待结果
//
// 上面的例子只是一个取回 5 的“傻方法”。
// 但如果 foo() 做了更有趣的事情，比如等待一个网络请求返回 5，
// 那么代码会暂停，直到值准备好。
//
// 可以看到，async/await 基本上是把一个函数调用分成了两部分：
//
//    1. 调用函数 (`async`)
//    2. 获取返回值 (`await`)
//
// 另外请注意：函数中并不需要一定有 `suspend` 才能在 async 环境下被调用。
//
// 请使用 `await` 来获取 getPageTitle() 返回的字符串。
//
const print = @import("std").debug.print;

pub fn main() void {
    var myframe = async getPageTitle("http://example.com");

    var value = ???

    print("{s}\n", .{value});
}

fn getPageTitle(url: []const u8) []const u8 {
    // 请假装这实际上是在发起一个网络请求。
    _ = url;
    return "Example Title.";
}
