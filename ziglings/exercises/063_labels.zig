//
// 循环体是代码块，而代码块本身也是表达式。我们已经看到，
// 它们可以用来计算并返回值。更进一步的是，代码块还可以用
// 标签（label）来命名：
//
//     my_label: { ... }
//
// 给代码块加上标签后，你就可以用 'break' 跳出该块：
//
//     outer_block: {           // 外层代码块
//         while (true) {       // 内层循环
//             break :outer_block;
//         }
//         unreachable;
//     }
//
// 正如我们刚刚学到的，你可以通过 break 语句返回一个值。
// 这是否意味着你可以从任何带标签的代码块返回一个值呢？
// 答案是：没错！
//
//     const foo = make_five: {
//         const five = 1 + 1 + 1 + 1 + 1;
//         break :make_five five;
//     };
//
// 标签也可以用在循环上。能够从嵌套循环的特定层级跳出，
// 这种情况虽然不常见，但一旦需要时，就会非常方便。
// 有时候从内层循环返回一个值实在太好用了，几乎让人觉得像作弊，
// （还能帮你避免写一堆临时变量）。
//
//     const bar: u8 = two_loop: while (true) {
//         while (true) {
//             break :two_loop 2;
//         }
//     } else 0;
//
// 在上面的例子中，break 跳出了带标签 "two_loop" 的外层循环
// 并返回值 2。else 子句附加在外层 two_loop 上，
// 如果循环在没有执行 break 的情况下结束，就会执行 else 子句。
//
// 最后，你也可以在使用 'continue' 时配合块标签：
//
//     my_while: while (true) {
//         continue :my_while;
//     }
//
const print = @import("std").debug.print;

// 前面提到过，我们很快就会明白为什么这两个数字
// 不需要显式类型。先坚持一下！
const ingredients = 4;
const foods = 4;

const Food = struct {
    name: []const u8,
    requires: [ingredients]bool,
};

//                 Chili  Macaroni  Tomato Sauce  Cheese
// ------------------------------------------------------
//  Mac & Cheese              x                     x
//  Chili Mac        x        x
//  Pasta                     x          x
//  Cheesy Chili     x                              x
// ------------------------------------------------------

const menu: [foods]Food = [_]Food{
    Food{
        .name = "Mac & Cheese",
        .requires = [ingredients]bool{ false, true, false, true },
    },
    Food{
        .name = "Chili Mac",
        .requires = [ingredients]bool{ true, true, false, false },
    },
    Food{
        .name = "Pasta",
        .requires = [ingredients]bool{ false, true, true, false },
    },
    Food{
        .name = "Cheesy Chili",
        .requires = [ingredients]bool{ true, false, false, true },
    },
};

pub fn main() void {
    // 欢迎来到 Cafeteria USA！选择你最喜欢的食材，
    // 我们会为你做出一份美味的餐点。
    //
    // 食客注意：并不是所有的食材组合都能做出一道菜。
    // 默认的餐点是奶酪通心粉（Mac & Cheese）。
    //
    // 开发者注意：在我们的微型示例里，硬编码食材编号
    // （基于数组位置）还凑合，但在真实应用中就相当糟糕了！
    const wanted_ingredients = [_]u8{ 0, 3 }; // Chili, Cheese

    // 查看菜单上的每一道菜...
    const meal = food_loop: for (menu) |food| {

        // 再查看这道菜所需的每个食材...
        for (food.requires, 0..) |required, required_ingredient| {

            // 这个食材不是必须的，跳过。
            if (!required) continue;

            // 看看顾客是否想要这个食材。
            // （注意 want_it 是数组中的索引号，
            // 对应每道菜食材需求表中的位置。）
            const found = for (wanted_ingredients) |want_it| {
                if (required_ingredient == want_it) break true;
            } else false;

            // 如果没找到这个必须的食材，
            // 这道菜就做不了。继续检查下一道菜。
            if (!found) continue :food_loop;
        }

        // 如果能执行到这里，说明所需的食材顾客都想要。
        //
        // 请返回这道菜。
        break;
    };
    // ^ 哎呀！我们忘了在找不到匹配时，
    // 默认返回 Mac & Cheese 了。

    print("请享用你的 {s}!\n", .{meal.name});
}

// 挑战：你也可以去掉内层循环里的 'found' 变量。
// 看看你能不能找出怎么做！
