const std = @import("std");

/// Thin renderer/input abstraction.
/// Game code depends on this — not on a specific engine.
/// Implement with Magister/Arcis/RealCity (or raylib/SDL) later.

pub const Key = enum {
    w,
    a,
    s,
    d,
    e, // interact / enter vehicle
    f, // attack
    escape, // pause
    space,
};

pub const InputState = struct {
    move_x: f32 = 0, // -1 .. 1
    move_y: f32 = 0,
    interact: bool = false,
    attack: bool = false,
    pause: bool = false,
};

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8 = 255,

    pub fn rgb(r: u8, g: u8, b: u8) Color {
        return .{ .r = r, .g = g, .b = b };
    }
};

/// What a backend must provide.
pub const VTable = struct {
    init: *const fn (title: []const u8, width: u32, height: u32) anyerror!void,
    shutdown: *const fn () void,
    beginFrame: *const fn () void,
    endFrame: *const fn () void,
    pollInput: *const fn () InputState,
    /// dt in real seconds since last frame (0 if unknown)
    deltaTime: *const fn () f64,
    shouldClose: *const fn () bool,
    /// Debug draw — enough for early steps
    drawText: *const fn (text: []const u8, x: i32, y: i32, color: Color) void,
    clear: *const fn (color: Color) void,
};

pub const Backend = struct {
    vtable: VTable,

    pub fn init(self: Backend, title: []const u8, w: u32, h: u32) !void {
        try self.vtable.init(title, w, h);
    }
    pub fn shutdown(self: Backend) void {
        self.vtable.shutdown();
    }
    pub fn beginFrame(self: Backend) void {
        self.vtable.beginFrame();
    }
    pub fn endFrame(self: Backend) void {
        self.vtable.endFrame();
    }
    pub fn pollInput(self: Backend) InputState {
        return self.vtable.pollInput();
    }
    pub fn deltaTime(self: Backend) f64 {
        return self.vtable.deltaTime();
    }
    pub fn shouldClose(self: Backend) bool {
        return self.vtable.shouldClose();
    }
    pub fn drawText(self: Backend, text: []const u8, x: i32, y: i32, color: Color) void {
        self.vtable.drawText(text, x, y, color);
    }
    pub fn clear(self: Backend, color: Color) void {
        self.vtable.clear(color);
    }
};
