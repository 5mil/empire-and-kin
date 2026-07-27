const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const gpu = b.option(bool, "gpu", "Enable GLFW+OpenGL GPU backend") orelse false;
    const android = b.option(bool, "android", "Android / mobile backend (touch, no GLFW)") orelse false;
    const touch = b.option(bool, "touch", "Enable virtual touch overlay on GPU") orelse false;

    // Windows GLFW prebuilt prefix, e.g. $HOME/glfw-3.4.bin.WIN64
    const glfw_prefix = b.option([]const u8, "glfw_prefix", "Path to Windows GLFW SDK (for cross-compile)");

    // Which import lib name: "glfw3dll" (DLL) or "glfw3" (static). Default glfw3dll.
    const glfw_lib = b.option([]const u8, "glfw_lib", "GLFW link name (glfw3dll or glfw3)") orelse "glfw3dll";

    // Optional Android NDK sysroot for aarch64-linux-android linking
    const ndk_sysroot = b.option([]const u8, "ndk_sysroot", "Android NDK sysroot path");

    const options = b.addOptions();
    options.addOption(bool, "enable_gpu", gpu and !android);
    options.addOption(bool, "enable_android", android);
    options.addOption(bool, "enable_touch", touch or android);

    const need_libc = (gpu and !android) or target.result.os.tag == .windows;

    const exe = b.addExecutable(.{
        .name = "empire",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = need_libc,
        }),
    });
    exe.root_module.addOptions("build_options", options);

    if (gpu and !android) {
        if (target.result.os.tag == .windows) {
            if (glfw_prefix) |prefix| {
                exe.root_module.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{prefix}) });
                exe.root_module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib-mingw-w64", .{prefix}) });
                exe.root_module.addLibraryPath(.{ .cwd_relative = prefix });
            }
            exe.root_module.linkSystemLibrary(glfw_lib, .{});
            exe.root_module.linkSystemLibrary("opengl32", .{});
            exe.root_module.linkSystemLibrary("gdi32", .{});
            exe.root_module.linkSystemLibrary("shell32", .{});
            exe.root_module.linkSystemLibrary("user32", .{});
        } else {
            if (glfw_prefix) |prefix| {
                exe.root_module.addIncludePath(.{ .cwd_relative = b.fmt("{s}/include", .{prefix}) });
                exe.root_module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/lib", .{prefix}) });
            }
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
        }
    }

    if (ndk_sysroot) |sys| {
        exe.root_module.addIncludePath(.{ .cwd_relative = b.fmt("{s}/usr/include", .{sys}) });
        exe.root_module.addLibraryPath(.{ .cwd_relative = b.fmt("{s}/usr/lib/aarch64-linux-android/24", .{sys}) });
    }

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run (use -Dgpu=true for GLFW+OpenGL)");
    run_step.dependOn(&run_cmd.step);

    // Headless always available
    const headless_opts = b.addOptions();
    headless_opts.addOption(bool, "enable_gpu", false);
    headless_opts.addOption(bool, "enable_android", false);
    headless_opts.addOption(bool, "enable_touch", false);

    const headless = b.addExecutable(.{
        .name = "empire-headless",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = target.result.os.tag == .windows,
        }),
    });
    headless.root_module.addOptions("build_options", headless_opts);
    b.installArtifact(headless);

    const run_h = b.addRunArtifact(headless);
    const headless_install = b.addInstallArtifact(headless, .{});
    run_h.step.dependOn(&headless_install.step);
    const run_headless = b.step("run-headless", "Run NullBackend (no GPU)");
    run_headless.dependOn(&run_h.step);

    // Android-oriented executable (touch backend, no GLFW)
    const android_opts = b.addOptions();
    android_opts.addOption(bool, "enable_gpu", false);
    android_opts.addOption(bool, "enable_android", true);
    android_opts.addOption(bool, "enable_touch", true);

    const android_exe = b.addExecutable(.{
        .name = "empire-android",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = false,
        }),
    });
    android_exe.root_module.addOptions("build_options", android_opts);
    b.installArtifact(android_exe);

    const run_android = b.addRunArtifact(android_exe);
    const android_install = b.addInstallArtifact(android_exe, .{});
    run_android.step.dependOn(&android_install.step);
    // Auto-close after N frames so CI / phone scripts can exit
    const run_android_step = b.step("run-android", "Run Android/touch backend (no window)");
    run_android_step.dependOn(&run_android.step);

    // Shared library for packaging into an APK (NativeActivity loads libempire.so)
    const lib_opts = b.addOptions();
    lib_opts.addOption(bool, "enable_gpu", false);
    lib_opts.addOption(bool, "enable_android", true);
    lib_opts.addOption(bool, "enable_touch", true);

    const lib = b.addLibrary(.{
        .name = "empire",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/android_lib.zig"),
            .target = target,
            .optimize = optimize,
            .link_libc = false,
        }),
        .linkage = .dynamic,
    });
    lib.root_module.addOptions("build_options", lib_opts);
    b.installArtifact(lib);

    const lib_step = b.step("android-lib", "Build libempire.so for APK packaging");
    lib_step.dependOn(&b.addInstallArtifact(lib, .{}).step);
}
