//
// 在编译期把 **类型** 传递给函数，让我们能够生成可处理多种类型的代码。
// 但这并不能帮助我们把 **不同类型的值** 传给同一个函数。
//
// 为此，Zig 提供了 `anytype` 占位符，它告诉 Zig 在编译期推断参数的实际类型。
//
//     fn foo(thing: anytype) void { ... }
//
// 接着我们可以使用一些内建函数（builtins）比如：
//   @TypeOf(), @typeInfo(), @typeName(), @hasDecl(), @hasField()
// 来判断传入值的类型信息。
// 这些逻辑都会 **完全在编译期执行**。
//
const print = @import("std").debug.print;

// 让我们定义三个结构体：Duck、RubberDuck 和 Duct。
// 注意 Duck 和 RubberDuck 都有 waddle() 和 quack() 方法，
// 并且它们定义在各自的命名空间里（也叫 “decls”）。
...

// 这个函数有一个参数，它的类型在编译期推断。
// 它使用内建函数 @TypeOf() 和 @hasDecl() 来实现 **鸭子类型（duck typing）**。
// 所谓鸭子类型就是：
// 「如果它会走路像鸭子，还会叫像鸭子，那它就是鸭子。」
// 用这种方式来判断某个类型是否是“鸭子”。
fn isADuck(possible_duck: anytype) bool {
    // 我们将使用 @hasDecl() 来判断类型是否具备成为“鸭子”所需的一切。
    //
    // 在这个例子里，如果类型 Foo 有一个 increment() 方法，
    // 那么 'has_increment' 就会是 true：
    //
    //     const has_increment = @hasDecl(Foo, "increment");
    //
    // 请确保 MyType 同时具有 waddle() 和 quack() 方法：
    const MyType = @TypeOf(possible_duck);
    const walks_like_duck = ???;
    const quacks_like_duck = ???;

    const is_duck = walks_like_duck and quacks_like_duck;

    if (is_duck) {
        // 我们还会在这里调用 quack() 方法，
        // 以证明 Zig 允许我们对“足够像鸭子”的东西执行“鸭子动作”。
        //
        // 由于所有检查和推断都是在编译期完成的，
        // 我们依然保持完全的 **类型安全**：
        // 如果试图在一个没有 quack() 方法的结构体（比如 Duct）上调用它，
        // 会导致 **编译错误**，而不是运行时崩溃！
        possible_duck.quack();
    }

    return is_duck;
}
