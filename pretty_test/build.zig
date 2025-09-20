const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b;
    // 这个 build 函数可以留空，因为我们只是导出 addPrettyTest 函数
}

/// 添加美化测试的函数
pub fn addPrettyTest(
    b: *std.Build,
    options: PrettyTestOptions,
) *std.Build.Step {
    // 不要在这里调用 standardTargetOptions！
    const target = options.target orelse @panic("target is required - pass it from your build.zig");
    const optimize = options.optimize orelse @panic("optimize is required - pass it from your build.zig");

    // 创建测试步骤
    const test_step = b.allocator.create(std.Build.Step) catch @panic("OOM");
    test_step.* = std.Build.Step.init(.{
        .id = .custom,
        .name = options.name orelse "pretty_test",
        .owner = b,
    });

    // 为每个测试文件创建测试
    for (options.test_files) |test_file| {
        // Zig 0.15.1 使用 root_module
        const tests = b.addTest(.{
            .root_module = b.createModule(.{
                .root_source_file = test_file.path,
                .target = target,
                .optimize = optimize,
            }),
        });

        // 设置自定义测试运行器
        tests.test_runner = .{
            .mode = .simple, // 使用 simple 模式
            .path = b.path("pretty_test/src/test_runner.zig"),
        };

        // 创建运行步骤
        const run_tests = b.addRunArtifact(tests);

        // 如果有过滤器，通过命令行参数传递
        if (options.filter) |filter| {
            run_tests.addArg("--test-filter");
            run_tests.addArg(filter);
        }

        // 添加环境变量
        if (options.verbose orelse false) {
            run_tests.setEnvironmentVariable("VERBOSE", "true");
        }
        if (options.show_output orelse false) {
            run_tests.setEnvironmentVariable("SHOW_OUTPUT", "true");
        }

        test_step.dependOn(&run_tests.step);
    }

    return test_step;
}

pub const PrettyTestOptions = struct {
    /// 测试文件列表
    test_files: []const TestFile,

    /// 测试名称
    name: ?[]const u8 = null,

    /// 目标平台 - 必须从调用方传入
    target: ?std.Build.ResolvedTarget = null,

    /// 优化级别 - 必须从调用方传入
    optimize: ?std.builtin.OptimizeMode = null,

    /// 显示详细输出
    verbose: ?bool = null,

    /// 过滤测试
    filter: ?[]const u8 = null,

    /// 显示测试输出
    show_output: ?bool = null,
};

pub const TestFile = struct {
    path: std.Build.LazyPath,
    suite_name: ?[]const u8 = null,
};
