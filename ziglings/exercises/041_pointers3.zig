//
// 这里比较绕的一点是：指针的可变性（var vs const）指的是
// 能不能改变指针 **指向的对象**，而不是能不能改变该对象里的值！
//
//     const locked: u8 = 5;
//     var unlocked: u8 = 10;
//
//     const p1: *const u8 = &locked;
//     var   p2: *const u8 = &locked;
//
// p1 和 p2 都指向不可变的值，不能修改它们指向的内容。
// 但是 p2 可以被重新赋值去指向别的东西，而 p1 不行！
//
//     const p3: *u8 = &unlocked;
//     var   p4: *u8 = &unlocked;
//     const p5: *const u8 = &unlocked;
//     var   p6: *const u8 = &unlocked;
//
// 这里 p3 和 p4 都能用来修改它们指向的值，
// 但是 p3 不能重新指向别的对象。
//
// 有趣的是，p5 和 p6 的行为就像 p1 和 p2，
// 只是它们指向的是 `unlocked` 的值。
// 这就是我们说的“可以对任何值创建一个常量引用”的意思！
//
const std = @import("std");

pub fn main() void {
    var foo: u8 = 5;
    var bar: u8 = 10;

    // 请定义指针 "p"，让它既能指向 foo 也能指向 bar，
    // 并且还能修改它所指向的值！
    ??? p: ??? = undefined;

    p = &foo;
    p.* += 1;
    p = &bar;
    p.* += 1;
    std.debug.print("foo={}, bar={}\n", .{ foo, bar });
}
