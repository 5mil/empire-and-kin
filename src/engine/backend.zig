const std = @import("std");

/// Thin renderer/input abstraction.
/// Game code depends on this — not on a specific engine.

pub const Key = enum {
    w,
    a,
    s,
    d,
    e,
    f,
    escape,
    space,
};

pub const InputState = struct {
    move_x: f32 = 0,
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

pub const Vec3 = struct {
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
};

/// Third-person style camera (look-at).
pub const Camera = struct {
    position: Vec3 = .{ .x = 0, .y = 12, .z = -16 },
    target: Vec3 = .{ .x = 0, .y = 0, .z = 0 },
    up: Vec3 = .{ .x = 0, .y = 1, .z = 0 },
    fov_deg: f32 = 55,
};

/// What a backend must provide.
pub const VTable = struct {
    init: *const fn (title: []const u8, width: u32, height: u32) anyerror!void,
    shutdown: *const fn () void,
    beginFrame: *const fn () void,
    endFrame: *const fn () void,
    pollInput: *const fn () InputState,
    deltaTime: *const fn () f64,
    shouldClose: *const fn () bool,
    drawText: *const fn (text: []const u8, x: i32, y: i32, color: Color) void,
    clear: *const fn (color: Color) void,
    setCamera: *const fn (cam: Camera) void,
    drawGround: *const fn (size: f32, color: Color) void,
    drawBox: *const fn (pos: Vec3, w: f32, h: f32, d: f32, color: Color) void,
    drawPlayerProxy: *const fn (pos: Vec3, facing_yaw: f32, color: Color) void,
    /// Phase 2: draw a building mesh scaled to footprint. Returns true if a GLB was used.
    drawBuilding: *const fn (pos: Vec3, w: f32, h: f32, d: f32, color: Color) bool,
    /// Phase 2: street prop mesh (lamp, tree, hydrant…). Returns true if a GLB was used.
    drawProp: *const fn (pos: Vec3, w: f32, h: f32, d: f32, color: Color) bool,
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
    pub fn setCamera(self: Backend, cam: Camera) void {
        self.vtable.setCamera(cam);
    }
    pub fn drawGround(self: Backend, size: f32, color: Color) void {
        self.vtable.drawGround(size, color);
    }
    pub fn drawBox(self: Backend, pos: Vec3, w: f32, h: f32, d: f32, color: Color) void {
        self.vtable.drawBox(pos, w, h, d, color);
    }
    pub fn drawPlayerProxy(self: Backend, pos: Vec3, facing_yaw: f32, color: Color) void {
        self.vtable.drawPlayerProxy(pos, facing_yaw, color);
    }
    pub fn drawBuilding(self: Backend, pos: Vec3, w: f32, h: f32, d: f32, color: Color) bool {
        return self.vtable.drawBuilding(pos, w, h, d, color);
    }
    pub fn drawProp(self: Backend, pos: Vec3, w: f32, h: f32, d: f32, color: Color) bool {
        return self.vtable.drawProp(pos, w, h, d, color);
    }
};
