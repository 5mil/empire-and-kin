//! GLFW 3 window + OpenGL 3.3 core context.

const std = @import("std");
const gl = @import("gl.zig");

pub const c = struct {
    pub const GLFW_TRUE: c_int = 1;
    pub const GLFW_FALSE: c_int = 0;
    pub const GLFW_CONTEXT_VERSION_MAJOR: c_int = 0x00022002;
    pub const GLFW_CONTEXT_VERSION_MINOR: c_int = 0x00022003;
    pub const GLFW_OPENGL_PROFILE: c_int = 0x00022008;
    pub const GLFW_OPENGL_CORE_PROFILE: c_int = 0x00032001;
    pub const GLFW_OPENGL_FORWARD_COMPAT: c_int = 0x00022006;
    pub const GLFW_KEY_ESCAPE: c_int = 256;
    pub const GLFW_KEY_SPACE: c_int = 32;
    pub const GLFW_KEY_W: c_int = 87;
    pub const GLFW_KEY_A: c_int = 65;
    pub const GLFW_KEY_S: c_int = 83;
    pub const GLFW_KEY_D: c_int = 68;
    pub const GLFW_KEY_E: c_int = 69;
    pub const GLFW_KEY_F: c_int = 70;
    pub const GLFW_KEY_Q: c_int = 81;
    pub const GLFW_KEY_R: c_int = 82;
    pub const GLFW_KEY_H: c_int = 72;
    pub const GLFW_KEY_X: c_int = 88;
    pub const GLFW_KEY_TAB: c_int = 258;
    pub const GLFW_KEY_ENTER: c_int = 257;
    pub const GLFW_KEY_1: c_int = 49;
    pub const GLFW_KEY_2: c_int = 50;
    pub const GLFW_KEY_3: c_int = 51;
    pub const GLFW_KEY_4: c_int = 52;
    pub const GLFW_KEY_5: c_int = 53;
    pub const GLFW_KEY_F5: c_int = 294;
    pub const GLFW_KEY_F9: c_int = 298;
    pub const GLFW_PRESS: c_int = 1;

    pub const GLFWwindow = opaque {};
    pub const GLFWmonitor = opaque {};

    pub extern fn glfwInit() c_int;
    pub extern fn glfwTerminate() void;
    pub extern fn glfwWindowHint(hint: c_int, value: c_int) void;
    pub extern fn glfwCreateWindow(width: c_int, height: c_int, title: [*:0]const u8, monitor: ?*GLFWmonitor, share: ?*GLFWwindow) ?*GLFWwindow;
    pub extern fn glfwDestroyWindow(window: *GLFWwindow) void;
    pub extern fn glfwMakeContextCurrent(window: ?*GLFWwindow) void;
    pub extern fn glfwSwapBuffers(window: *GLFWwindow) void;
    pub extern fn glfwPollEvents() void;
    pub extern fn glfwWindowShouldClose(window: *GLFWwindow) c_int;
    pub extern fn glfwGetFramebufferSize(window: *GLFWwindow, width: *c_int, height: *c_int) void;
    pub extern fn glfwGetKey(window: *GLFWwindow, key: c_int) c_int;
    pub extern fn glfwGetTime() f64;
    pub extern fn glfwSwapInterval(interval: c_int) void;
    pub extern fn glfwGetProcAddress(procname: [*:0]const u8) ?*anyopaque;
    pub extern fn glfwSetErrorCallback(cb: ?*const fn (c_int, [*:0]const u8) callconv(.C) void) ?*const fn (c_int, [*:0]const u8) callconv(.C) void;
};

fn errorCallback(code: c_int, desc: [*:0]const u8) callconv(.C) void {
    std.debug.print("[GLFW] error {d}: {s}\n", .{ code, desc });
}

pub const Window = struct {
    handle: *c.GLFWwindow,
    width: u32,
    height: u32,

    pub fn create(title: [*:0]const u8, width: u32, height: u32) !Window {
        _ = c.glfwSetErrorCallback(errorCallback);
        if (c.glfwInit() != c.GLFW_TRUE) return error.GlfwInitFailed;
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
        c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
        c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
        c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GLFW_TRUE);
        const win = c.glfwCreateWindow(@intCast(width), @intCast(height), title, null, null) orelse {
            c.glfwTerminate();
            return error.WindowCreateFailed;
        };
        c.glfwMakeContextCurrent(win);
        c.glfwSwapInterval(1);
        try gl.load(c.glfwGetProcAddress);
        var fb_w: c_int = 0;
        var fb_h: c_int = 0;
        c.glfwGetFramebufferSize(win, &fb_w, &fb_h);
        return .{ .handle = win, .width = @intCast(fb_w), .height = @intCast(fb_h) };
    }

    pub fn destroy(self: *Window) void {
        c.glfwDestroyWindow(self.handle);
        c.glfwTerminate();
    }

    pub fn poll(self: *Window) void {
        c.glfwPollEvents();
        var fb_w: c_int = 0;
        var fb_h: c_int = 0;
        c.glfwGetFramebufferSize(self.handle, &fb_w, &fb_h);
        self.width = @intCast(fb_w);
        self.height = @intCast(fb_h);
    }

    pub fn swap(self: *Window) void {
        c.glfwSwapBuffers(self.handle);
    }

    pub fn shouldClose(self: *Window) bool {
        return c.glfwWindowShouldClose(self.handle) == c.GLFW_TRUE;
    }

    pub fn keyDown(self: *Window, key: c_int) bool {
        return c.glfwGetKey(self.handle, key) == c.GLFW_PRESS;
    }

    pub fn time() f64 {
        return c.glfwGetTime();
    }
};
