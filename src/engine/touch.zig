//! On-screen virtual controls for Android / touch devices.
//! Zones are normalized 0..1 (origin top-left of screen).
//! Also usable on desktop: inject pointer via setPointer().

const input = @import("input.zig");
const backend = @import("backend.zig");

pub const Pointer = struct {
    x: f32 = -1, // normalized 0..1, -1 = up
    y: f32 = -1,
    down: bool = false,
};

var ptr: Pointer = .{};
var ptr2: Pointer = .{}; // second finger (actions)

pub fn setPointer(x_norm: f32, y_norm: f32, down: bool) void {
    ptr = .{ .x = x_norm, .y = y_norm, .down = down };
}

pub fn setPointer2(x_norm: f32, y_norm: f32, down: bool) void {
    ptr2 = .{ .x = x_norm, .y = y_norm, .down = down };
}

pub fn clear() void {
    ptr = .{};
    ptr2 = .{};
}

fn inRect(p: Pointer, x0: f32, y0: f32, x1: f32, y1: f32) bool {
    if (!p.down) return false;
    return p.x >= x0 and p.x <= x1 and p.y >= y0 and p.y <= y1;
}

/// Left stick zone: bottom-left third.
/// Right action buttons: bottom-right.
/// Top row: pause / menu / save.
pub fn toRawKeys() input.RawKeys {
    var raw: input.RawKeys = .{};

    // Virtual stick (left half bottom)
    const stick_cx: f32 = 0.18;
    const stick_cy: f32 = 0.78;
    if (ptr.down and ptr.x < 0.42 and ptr.y > 0.55) {
        const dx = (ptr.x - stick_cx) / 0.14;
        const dy = (stick_cy - ptr.y) / 0.14; // screen y down → game y up
        raw.stick_x = @max(-1, @min(1, dx));
        raw.stick_y = @max(-1, @min(1, dy));
        if (raw.stick_y > 0.35) raw.w = true;
        if (raw.stick_y < -0.35) raw.s = true;
        if (raw.stick_x < -0.35) raw.a = true;
        if (raw.stick_x > 0.35) raw.d = true;
    }

    // Action cluster (right)
    if (inRect(ptr, 0.72, 0.70, 0.88, 0.88) or inRect(ptr2, 0.72, 0.70, 0.88, 0.88)) raw.e = true; // Interact
    if (inRect(ptr, 0.88, 0.70, 0.99, 0.88) or inRect(ptr2, 0.88, 0.70, 0.99, 0.88)) raw.f = true; // Attack / secondary
    if (inRect(ptr, 0.72, 0.52, 0.88, 0.68) or inRect(ptr2, 0.72, 0.52, 0.88, 0.68)) raw.r = true; // Bribe / tip
    if (inRect(ptr, 0.88, 0.52, 0.99, 0.68) or inRect(ptr2, 0.88, 0.52, 0.99, 0.68)) raw.space = true; // Pause

    // Top chrome
    if (inRect(ptr, 0.02, 0.02, 0.12, 0.10) or inRect(ptr2, 0.02, 0.02, 0.12, 0.10)) raw.key_1 = true;
    if (inRect(ptr, 0.14, 0.02, 0.24, 0.10) or inRect(ptr2, 0.14, 0.02, 0.24, 0.10)) raw.key_2 = true;
    if (inRect(ptr, 0.88, 0.02, 0.98, 0.10) or inRect(ptr2, 0.88, 0.02, 0.98, 0.10)) raw.enter = true;
    if (inRect(ptr, 0.02, 0.12, 0.14, 0.20) or inRect(ptr2, 0.02, 0.12, 0.14, 0.20)) raw.f5 = true;

    return raw;
}

/// Draw translucent control hints (screen pixels).
pub fn drawOverlay(gfx: backend.Backend, screen_w: i32, screen_h: i32) void {
    const w = @as(f32, @floatFromInt(screen_w));
    const h = @as(f32, @floatFromInt(screen_h));
    // Labels only — boxes would need UI rect API; text is enough for alpha
    gfx.drawText("STICK", @intFromFloat(w * 0.12), @intFromFloat(h * 0.92), backend.Color.rgb(180, 200, 220));
    gfx.drawText("[E]", @intFromFloat(w * 0.76), @intFromFloat(h * 0.78), backend.Color.rgb(120, 255, 180));
    gfx.drawText("[F]", @intFromFloat(w * 0.90), @intFromFloat(h * 0.78), backend.Color.rgb(255, 140, 120));
    gfx.drawText("[R]", @intFromFloat(w * 0.76), @intFromFloat(h * 0.58), backend.Color.rgb(200, 200, 120));
    gfx.drawText("||", @intFromFloat(w * 0.92), @intFromFloat(h * 0.58), backend.Color.rgb(220, 220, 220));
}
