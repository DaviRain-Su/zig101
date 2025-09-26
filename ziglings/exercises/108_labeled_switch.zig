//
// 你在练习 011、012、013 和 014 中听说过 while 循环
// 你在练习 030 和 031 中也听说过 switch 表达式。
// 你在练习 063 中还见过标签（label）的用法。
//
// 通过将 while 循环和 switch 语句与 continue 和 break 语句结合，
// 我们可以创建非常简洁的状态机（State Machine）。
//
// 其中一个例子是：
//
//      pub fn main() void {
//          var op: u8 = 1;
//          while (true) {
//              switch (op) {
//                  1 => { op = 2; continue; },
//                  2 => { op = 3; continue; },
//                  3 => return,
//                  else => {},
//              }
//              break;
//          }
//          std.debug.print("这一行语句永远无法被执行\n", .{});
//      }
//
// 通过结合我们到目前为止学到的所有内容，我们现在可以继续学习带标签的 switch。
//
// 带标签的 switch 是一些额外的语法糖，它还能带来各种好处（性能提升）。
// 不相信？直接看源码：https://github.com/ziglang/zig/pull/21367
//
// 下面是前面片段用带标签的 switch 实现的方式：
//
//      pub fn main() void {
//          foo: switch (@as(u8, 1)) {
//              1 => continue :foo 2,
//              2 => continue :foo 3,
//              3 => return,
//              else => {},
//          }
//          std.debug.print("这一行语句永远无法被执行\n", .{});
//      }
//
// 这个第二种写法的执行流程是：
//  1. switch 从值 `1` 开始；
//  2. switch 匹配到 case `1`，它使用 continue 语句重新求值带标签的 switch，
//     现在提供的值是 `2`；
//  3. 在 case `2` 中，我们重复 case `1` 的模式，
//     但这次要被求值的值是 `3`；
//  4. 最后我们到达 case `3`，这里直接从整个函数返回，
//     所以 debug 语句不会被执行；
//  5. 在这个例子里，由于输入没有明确的穷尽模式，可以是任意 `u8` 整数，
//     我们需要用 `else => {}` 分支来处理所有没有覆盖的情况。
//

const std = @import("std");

const PullRequestState = enum(u8) {
    Draft,
    InReview,
    Approved,
    Rejected,
    Merged,
};

pub fn main() void {
    // 哎呀，你的 pull request 一直被拒绝，
    // 你会怎么修复它？
    pr: switch (PullRequestState.Draft) {
        PullRequestState.Draft => continue :pr PullRequestState.InReview,
        PullRequestState.InReview => continue :pr PullRequestState.Rejected,
        PullRequestState.Approved => continue :pr PullRequestState.Merged,
        PullRequestState.Rejected => {
            std.debug.print("这个 pull request 被拒绝了。\n", .{});
            return;
        },
        PullRequestState.Merged => break, // 你知道这里应该跳出到哪里吗？
    }
    std.debug.print("这个 pull request 已经被合并了。\n", .{});
}
