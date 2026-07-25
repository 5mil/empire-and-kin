const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Default false so headless / CI works without display libs.
    // Use: zig build run -Dgpu=true
    const gpu = b.option(bool, "gpu", "Enable GLFW+OpenGL GPU backend") orelse false;

    const options = b.addOptions();
    options.addOption(bool, "enable_gpu", gpu);

    const exe = b.addExecutable(.{
        .name = "empire",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = gpu,
        }),
    });
    exe.root_module.addOptions("build_options", options);

    if (gpu) {
        exe.root_module.linkSystemLibrary("glfw", .{});
        exe.root_module.linkSystemLibrary("GL", .{});
        if (target.result.os.tag == .linux) {
            exe.root_module.linkSystemLibrary("pthread", .{});
            exe.root_module.linkSystemLibrary("dl", .{});
            exe.root_module.linkSystemLibrary("m", .{});
        }
        if (target.result.os.tag == .macos) {
            exe.root_module.linkFramework("OpenGL", .{});
            exe.root_module.linkFramework("Cocoa", .{});
            exe.root_module.linkFramework("IOKit", .{});
            exe.root_module.linkFramework("CoreVideo", .{});
        }
        if (target.result.os.tag == .windows) {
            exe.root_module.linkSystemLibrary("opengl32", .{});
            exe.root_module.linkSystemLibrary("gdi32", .{});
            exe.root_module.linkSystemLibrary("shell32", .{});
            exe.root_module.linkSystemLibrary("user32", .{});
        }
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run (use -Dgpu=true for GLFW+OpenGL)");
    run_step.dependOn(&run_cmd.step);

    const headless_opts = b.addOptions();
    headless_opts.addOption(bool, "enable_gpu", false);

    const headless = b.addExecutable(.{
        .name = "empire-headless",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    headless.root_module.addOptions("build_options", headless_opts);
    b.installArtifact(headless);

    const run_h = b.addRunArtifact(headless);
    const headless_install = b.addInstallArtifact(headless, .{});
    run_h.step.dependOn(&headless_install.step);
    const run_headless = b.step("run-headless", "Run NullBackend (no GPU)");
    run_headless.dependOn(&run_h.step);
}
