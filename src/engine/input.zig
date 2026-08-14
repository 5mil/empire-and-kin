const std = @import("std");
const backend = @import("backend.zig");

pub const RawKeys = struct {
    w: bool = false,
    a: bool = false,
    s: bool = false,
    d: bool = false,
    up: bool = false,
    down: bool = false,
    left: bool = false,
    right: bool = false,
    e: bool = false,
    f: bool = false,
    escape: bool = false,
    space: bool = false,
    stick_x: f32 = 0,
    stick_y: f32 = 0,
    pad_a: bool = false,
    pad_b: bool = false,
    pad_start: bool = false,
    key_1: bool = false,
    key_2: bool = false,
    key_3: bool = false,
    key_4: bool = false,
    key_5: bool = false,
    tab: bool = false,
    q: bool = false,
    enter: bool = false,
    r: bool = false,
    f5: bool = false,
    f9: bool = false,
    h: bool = false,
    x: bool = false,
    m: bool = false,
    c: bool = false,
    shift: bool = false,
    bracket_l: bool = false,
    bracket_r: bool = false,
};

pub const ButtonEdge = struct {
    prev: bool = false,
    pub fn pressed(self: *ButtonEdge, down: bool) bool {
        const edge = down and !self.prev;
        self.prev = down;
        return edge;
    }
};

pub const Mapper = struct {
    edge_pause: ButtonEdge = .{},
    edge_interact: ButtonEdge = .{},
    edge_attack: ButtonEdge = .{},
    pub fn map(self: *Mapper, raw: RawKeys) backend.InputState {
        var mx: f32 = 0;
        var my: f32 = 0;
        if (raw.a or raw.left) mx -= 1;
        if (raw.d or raw.right) mx += 1;
        if (raw.w or raw.up) my += 1;
        if (raw.s or raw.down) my -= 1;
        if (@abs(raw.stick_x) > 0.15 or @abs(raw.stick_y) > 0.15) {
            mx = raw.stick_x;
            my = raw.stick_y;
        }
        const len = @sqrt(mx * mx + my * my);
        if (len > 1.0) {
            mx /= len;
            my /= len;
        }
        // Sprint
        if (raw.shift) {
            mx *= 1.45;
            my *= 1.45;
        }
        return .{
            .move_x = mx,
            .move_y = my,
            .interact = self.edge_interact.pressed(raw.e or raw.pad_a),
            .attack = self.edge_attack.pressed(raw.f or raw.pad_b),
            .pause = self.edge_pause.pressed(raw.escape or raw.pad_start or raw.space),
        };
    }
};

pub fn bindingHelp() []const u8 {
    return "WASD move | Shift sprint/handbrake | E interact | M map | C character | [ ] camera zoom | Q/E orbit";
}
