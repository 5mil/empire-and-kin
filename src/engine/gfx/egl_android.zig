//! EGL + Android NativeWindow surface for OpenGL ES 3.0.
//! Used by gles_backend when running inside a NativeActivity / GameActivity.
//!
//! Desktop note: without a real ANativeWindow this module stays inert;
//! `zig build run-android` still uses the headless Android backend demo.

const std = @import("std");
const gl = @import("gl.zig");

/// Minimal EGL / Android C surface (explicit ABI — no system headers required).
pub const c = struct {
    pub const EGLint = c_int;
    pub const EGLBoolean = c_uint;
    pub const EGLDisplay = ?*anyopaque;
    pub const EGLConfig = ?*anyopaque;
    pub const EGLSurface = ?*anyopaque;
    pub const EGLContext = ?*anyopaque;
    pub const EGLNativeWindowType = ?*anyopaque;

    pub const EGL_DEFAULT_DISPLAY: ?*anyopaque = null;
    pub const EGL_NO_DISPLAY: EGLDisplay = null;
    pub const EGL_NO_SURFACE: EGLSurface = null;
    pub const EGL_NO_CONTEXT: EGLContext = null;
    pub const EGL_TRUE: EGLBoolean = 1;
    pub const EGL_FALSE: EGLBoolean = 0;

    pub const EGL_SURFACE_TYPE: EGLint = 0x3033;
    pub const EGL_WINDOW_BIT: EGLint = 0x0004;
    pub const EGL_RED_SIZE: EGLint = 0x3024;
    pub const EGL_GREEN_SIZE: EGLint = 0x3023;
    pub const EGL_BLUE_SIZE: EGLint = 0x3022;
    pub const EGL_ALPHA_SIZE: EGLint = 0x3021;
    pub const EGL_DEPTH_SIZE: EGLint = 0x3025;
    pub const EGL_RENDERABLE_TYPE: EGLint = 0x3040;
    pub const EGL_OPENGL_ES3_BIT: EGLint = 0x0040;
    pub const EGL_NONE: EGLint = 0x3038;
    pub const EGL_CONTEXT_CLIENT_VERSION: EGLint = 0x3098;
    pub const EGL_WIDTH: EGLint = 0x3057;
    pub const EGL_HEIGHT: EGLint = 0x3056;

    pub extern fn eglGetDisplay(display_id: ?*anyopaque) EGLDisplay;
    pub extern fn eglInitialize(display: EGLDisplay, major: ?*EGLint, minor: ?*EGLint) EGLBoolean;
    pub extern fn eglTerminate(display: EGLDisplay) EGLBoolean;
    pub extern fn eglChooseConfig(display: EGLDisplay, attrib_list: [*]const EGLint, configs: [*]EGLConfig, config_size: EGLint, num_config: *EGLint) EGLBoolean;
    pub extern fn eglCreateWindowSurface(display: EGLDisplay, config: EGLConfig, win: EGLNativeWindowType, attrib_list: ?[*]const EGLint) EGLSurface;
    pub extern fn eglCreateContext(display: EGLDisplay, config: EGLConfig, share: EGLContext, attrib_list: ?[*]const EGLint) EGLContext;
    pub extern fn eglMakeCurrent(display: EGLDisplay, draw: EGLSurface, read: EGLSurface, ctx: EGLContext) EGLBoolean;
    pub extern fn eglSwapBuffers(display: EGLDisplay, surface: EGLSurface) EGLBoolean;
    pub extern fn eglDestroySurface(display: EGLDisplay, surface: EGLSurface) EGLBoolean;
    pub extern fn eglDestroyContext(display: EGLDisplay, ctx: EGLContext) EGLBoolean;
    pub extern fn eglGetError() EGLint;
    pub extern fn eglQuerySurface(display: EGLDisplay, surface: EGLSurface, attribute: EGLint, value: *EGLint) EGLBoolean;
    pub extern fn eglGetProcAddress(procname: [*:0]const u8) ?*anyopaque;
};

pub const Context = struct {
    display: c.EGLDisplay = c.EGL_NO_DISPLAY,
    surface: c.EGLSurface = c.EGL_NO_SURFACE,
    context: c.EGLContext = c.EGL_NO_CONTEXT,
    width: u32 = 1280,
    height: u32 = 720,
    ready: bool = false,

    pub fn createFromWindow(window: c.EGLNativeWindowType, width: u32, height: u32) !Context {
        var self: Context = .{};
        self.width = if (width == 0) 1280 else width;
        self.height = if (height == 0) 720 else height;

        self.display = c.eglGetDisplay(c.EGL_DEFAULT_DISPLAY);
        if (self.display == c.EGL_NO_DISPLAY) return error.EglNoDisplay;

        var major: c.EGLint = 0;
        var minor: c.EGLint = 0;
        if (c.eglInitialize(self.display, &major, &minor) == c.EGL_FALSE) return error.EglInitFailed;
        std.debug.print("[EGL] {d}.{d}\n", .{ major, minor });

        const cfg_attribs = [_]c.EGLint{
            c.EGL_SURFACE_TYPE,    c.EGL_WINDOW_BIT,
            c.EGL_RED_SIZE,        8,
            c.EGL_GREEN_SIZE,      8,
            c.EGL_BLUE_SIZE,       8,
            c.EGL_ALPHA_SIZE,      8,
            c.EGL_DEPTH_SIZE,      24,
            c.EGL_RENDERABLE_TYPE, c.EGL_OPENGL_ES3_BIT,
            c.EGL_NONE,
        };
        var config: c.EGLConfig = null;
        var num: c.EGLint = 0;
        if (c.eglChooseConfig(self.display, &cfg_attribs, @ptrCast(&config), 1, &num) == c.EGL_FALSE or num < 1)
            return error.EglNoConfig;

        self.surface = c.eglCreateWindowSurface(self.display, config, window, null);
        if (self.surface == c.EGL_NO_SURFACE) return error.EglSurfaceFailed;

        const ctx_attribs = [_]c.EGLint{
            c.EGL_CONTEXT_CLIENT_VERSION, 3,
            c.EGL_NONE,
        };
        self.context = c.eglCreateContext(self.display, config, c.EGL_NO_CONTEXT, &ctx_attribs);
        if (self.context == c.EGL_NO_CONTEXT) return error.EglContextFailed;

        if (c.eglMakeCurrent(self.display, self.surface, self.surface, self.context) == c.EGL_FALSE)
            return error.EglMakeCurrentFailed;

        try gl.load(eglGetProc);

        var w: c.EGLint = 0;
        var h: c.EGLint = 0;
        _ = c.eglQuerySurface(self.display, self.surface, c.EGL_WIDTH, &w);
        _ = c.eglQuerySurface(self.display, self.surface, c.EGL_HEIGHT, &h);
        if (w > 0) self.width = @intCast(w);
        if (h > 0) self.height = @intCast(h);

        self.ready = true;
        std.debug.print("[EGL] GLES3 context ready {d}x{d}\n", .{ self.width, self.height });
        return self;
    }

    fn eglGetProc(name: [*:0]const u8) callconv(.c) ?*anyopaque {
        return c.eglGetProcAddress(name);
    }

    pub fn swap(self: *Context) void {
        if (!self.ready) return;
        _ = c.eglSwapBuffers(self.display, self.surface);
    }

    pub fn querySize(self: *Context) void {
        if (!self.ready) return;
        var w: c.EGLint = 0;
        var h: c.EGLint = 0;
        _ = c.eglQuerySurface(self.display, self.surface, c.EGL_WIDTH, &w);
        _ = c.eglQuerySurface(self.display, self.surface, c.EGL_HEIGHT, &h);
        if (w > 0) self.width = @intCast(w);
        if (h > 0) self.height = @intCast(h);
    }

    pub fn destroy(self: *Context) void {
        if (self.display != c.EGL_NO_DISPLAY) {
            _ = c.eglMakeCurrent(self.display, c.EGL_NO_SURFACE, c.EGL_NO_SURFACE, c.EGL_NO_CONTEXT);
            if (self.context != c.EGL_NO_CONTEXT) _ = c.eglDestroyContext(self.display, self.context);
            if (self.surface != c.EGL_NO_SURFACE) _ = c.eglDestroySurface(self.display, self.surface);
            _ = c.eglTerminate(self.display);
        }
        self.* = .{};
    }
};
