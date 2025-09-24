# Zig 构建系统

Zig 内置构建系统，无需外部工具。构建脚本使用 Zig 编写，通常保存为 `build.zig`。

## 核心概念

### build() 函数
每个构建脚本必须包含公共的 `build()` 函数：

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("hello.zig"),
        .target = b.host,  // 当前主机平台
    });
    b.installArtifact(exe);  // 安装到 zig-out 目录
}
```

### 目标对象类型

| 方法 | 产物 | 用途 |
|------|------|------|
| `addExecutable()` | 可执行文件 | 应用程序 |
| `addStaticLibrary()` | 静态库 (.a/.lib) | 编译时链接 |
| `addSharedLibrary()` | 动态库 (.so/.dll) | 运行时链接 |
| `addTest()` | 测试可执行文件 | 运行单元测试 |

## 配置选项

### 构建模式
```zig
const exe = b.addExecutable(.{
    .name = "app",
    .root_source_file = b.path("main.zig"),
    .target = b.host,
    .optimize = .ReleaseFast,  // 优化选项
});
```

| 模式 | 特点 | 使用场景 |
|------|------|----------|
| `Debug` | 包含调试信息（默认） | 开发调试 |
| `ReleaseFast` | 优化速度 | 性能关键应用 |
| `ReleaseSafe` | 保留安全检查 | 生产环境 |
| `ReleaseSmall` | 优化体积 | 嵌入式系统 |

### 版本设置
```zig
.version = .{ .major = 2, .minor = 9, .patch = 7 }
```

### 检测操作系统
```zig
const builtin = @import("builtin");
if (builtin.target.os.tag == .windows) {
    // Windows 特定代码
}
```

## 构建步骤

### 添加运行步骤
```zig
// 创建运行工件
const run_artifact = b.addRunArtifact(exe);

// 创建运行步骤
const run_step = b.step("run", "Run the project");
run_step.dependOn(&run_artifact.step);

// 使用: zig build run
```

### 构建单元测试
```zig
// 创建测试目标
const test_exe = b.addTest(.{
    .name = "unit_tests",
    .root_source_file = b.path("src/main.zig"),
    .target = b.host,
});

// 添加测试运行步骤
const run_test = b.addRunArtifact(test_exe);
const test_step = b.step("test", "Run unit tests");
test_step.dependOn(&run_test.step);

// 使用: zig build test
```

## 用户选项

```zig
// 定义用户选项
const use_zlib = b.option(
    bool,
    "use_zlib",
    "Should link to zlib?"
) orelse false;

// 根据选项配置
if (use_zlib) {
    exe.linkSystemLibrary("zlib");
}

// 使用: zig build -Duse_zlib=true
```

## 链接库

### 系统库（已安装的库）
```zig
exe.linkLibC();                    // 链接 C 标准库
exe.linkLibCpp();                  // 链接 C++ 标准库
exe.linkSystemLibrary("png");      // 链接系统库（使用 pkg-config）
```

### 本地库（项目内的库）
```zig
// 创建本地库
const lib = b.addStaticLibrary(.{
    .name = "mylib",
    .root_source_file = b.path("src/lib.zig"),
    .target = b.host,
});

// 链接本地库
exe.linkLibrary(lib);
```

## 构建 C 代码

### 基本设置
```zig
const lib = b.addStaticLibrary(.{
    .name = "clib",
    .optimize = optimize,
    .target = target,
});
lib.linkLibC();
```

### 添加 C 文件
```zig
// 编译器标志
const c_flags = [_][]const u8{
    "-Wall", "-Wextra", "-Werror"
};

// C 源文件
const c_files = [_][]const u8{
    "src/file1.c",
    "src/file2.c",
};

// 添加到构建
lib.addCSourceFiles(&c_files, &c_flags);

// 或添加单个文件
lib.addCSourceFile("src/single.c", &c_flags);
```

### C 宏定义
```zig
lib.defineCMacro("DEBUG", "1");
lib.defineCMacro("VERSION", "\"1.0.0\"");
```

### 路径配置
```zig
// 包含路径（头文件）
const inc_path: std.Build.LazyPath = .{
    .path = "./include"
};
lib.addIncludePath(inc_path);

// 库路径
const lib_path: std.Build.LazyPath = .{
    .cwd_relative = "/usr/local/lib/"
};
lib.addLibraryPath(lib_path);
```

## 完整示例

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    // 标准选项
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 创建可执行文件
    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // 链接库
    exe.linkLibC();
    exe.linkSystemLibrary("sqlite3");

    // 安装
    b.installArtifact(exe);

    // 运行步骤
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // 测试步骤
    const tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const test_cmd = b.addRunArtifact(tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&test_cmd.step);
}
```

## 常用命令

```bash
zig build              # 默认构建
zig build run          # 构建并运行
zig build test         # 运行测试
zig build --help       # 查看可用步骤
zig build -Dopt=value  # 设置选项
zig targets            # 查看支持的目标平台
```

## 要点

1. **必须安装工件**：使用 `b.installArtifact()` 将输出保存到 `zig-out`
2. **自动依赖发现**：编译器通过 import 语句自动发现所有模块
3. **内置 C 编译器**：可直接编译 C/C++ 代码
4. **交叉编译**：通过设置 `target` 轻松实现交叉编译
5. **步骤依赖**：使用 `dependOn()` 建立步骤间的依赖关系
