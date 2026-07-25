const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gpu = b.option(bool, "gpu", "Enable GLFW+OpenGL GPU backend") orelse true;

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
        exe.linkSystemLibrary("glfw");
        exe.linkSystemLibrary("GL");
        if (target.result.os.tag == .linux) {
            exe.linkSystemLibrary("X11");
            exe.linkSystemLibrary("pthread");
            exe.linkSystemLibrary("dl");
            exe.linkSystemLibrary("m");
        }
        if (target.result.os.tag == .macos) {
            exe.linkFramework("Cocoa");
            exe.linkFramework("IOKit");
            exe.linkFramework("CoreVideo");
            exe.linkFramework("OpenGL");
        }
        if (target.result.os.tag == .windows) {
            exe.linkSystemLibrary("opengl32");
            exe.linkSystemLibrary("gdi32");
            exe.linkSystemLibrary("shell32");
        }
        exe.linkLibC();
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the game (GPU if -Dgpu=true)");
    run_step.dependOn(&run_cmd.step);
}
