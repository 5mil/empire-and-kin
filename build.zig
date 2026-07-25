const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gpu = b.option(bool, "gpu", "Enable SDL2+OpenGL GPU backend") orelse true;

    const options = b.addOptions();
    options.addOption(bool, "enable_gpu", gpu);

    const exe = b.addExecutable(.{
        .name = "empire",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.root_module.addOptions("build_options", options);

    if (gpu) {
        exe.linkSystemLibrary("SDL2");
        exe.linkSystemLibrary("GL");
        if (target.result.os.tag == .linux) {
            exe.linkSystemLibrary("pthread");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("m");
        }
        if (target.result.os.tag == .macos) {
            exe.linkFramework("OpenGL");
            exe.linkFramework("Cocoa");
            exe.linkFramework("IOKit");
            exe.linkFramework("CoreVideo");
        }
        if (target.result.os.tag == .windows) {
            exe.linkSystemLibrary("opengl32");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("shell32");
            exe.linkSystemLibrary("user32");
        }
        exe.linkLibC();
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run with GPU (SDL2+OpenGL)");
    run_step.dependOn(&run_cmd.step);

    const headless_opts = b.addOptions();
    headless_opts.addOption(bool, "enable_gpu", false);
    const headless = b.addExecutable(.{
        .name = "empire-headless",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    headless.root_module.addOptions("build_options", headless_opts);
    b.installArtifact(headless);
    const run_h = b.addRunArtifact(headless);
    run_h.step.dependOn(b.getInstallStep());
    const run_headless = b.step("run-headless", "Run NullBackend (no GPU)");
    run_headless.dependOn(&run_h.step);
}
