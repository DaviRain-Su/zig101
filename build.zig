const std = @import("std");
// 直接导入 pretty_test 的 build.zig 文件
const pretty_test = @import("pretty_test/build.zig");

pub fn build(b: *std.Build) void {
    // 只在这里声明一次 target 和 optimize
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 模块定义
    const mod = b.addModule("zig101", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    // 可执行文件
    const exe = b.addExecutable(.{
        .name = "zig101",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "zig101", .module = mod },
            },
        }),
    });

    b.installArtifact(exe);

    // 运行步骤
    const run_step = b.step("run", "Run the app");
    const run_cmd = b.addRunArtifact(exe);
    run_step.dependOn(&run_cmd.step);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    // 测试步骤
    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const exe_tests = b.addTest(.{
        .root_module = exe.root_module,
    });
    const run_exe_tests = b.addRunArtifact(exe_tests);

    // 美化测试 - 关键：传入 target 和 optimize
    const test_step = b.step("test", "Run tests");
    //test_step.dependOn(pretty_test.addPrettyTest(b, .{
    //    .test_files = &.{
    //        .{ .path = b.path("src/root.zig") },
    //        .{ .path = b.path("src/main.zig") },
    //        .{ .path = b.path("src/test_pass.zig") },
    //    },
    //    .target = target, // 必须传入！
    //    .optimize = optimize, // 必须传入！
    //    .verbose = true,
    //    .show_output = true,
    //}));
    test_step.dependOn(&run_mod_tests.step);
    test_step.dependOn(&run_exe_tests.step);

    // 如果你想要单独的美化测试步骤
    //const pretty_only = b.step("test-pretty", "Run only pretty tests");
    //pretty_only.dependOn(pretty_test.addPrettyTest(b, .{
    //    .test_files = &.{
    //        .{ .path = b.path("src/root.zig") },
    //        .{ .path = b.path("src/main.zig") },
    //    },
    //    .target = target,
    //    .optimize = optimize,
    //    .verbose = true,
    //}));
}
