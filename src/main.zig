const std = @import("std");
const build_options = @import("build_options");
const gfx_mod = @import("engine/gfx_select.zig").BackendMod;
const session = @import("engine/session.zig");

pub fn main() !void {
    _ = build_options;
    std.debug.print("Empire & Kin - 0.7.1-alpha (Phase 8 lamps + windows)\n", .{});
    const gfx = gfx_mod.getBackend();
    try gfx.init("Empire & Kin", 1280, 720);
    try session.run(gfx);
}
