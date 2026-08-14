//! Full play session (extracted from main). Keep main.zig tiny.
//! Future: split GameState + per-mode ticks further.

const backend = @import("backend.zig");
const gfx_select = @import("gfx_select.zig");
const build_options = @import("build_options");

// PLACEHOLDER_FULL_CONTENT - will update
pub fn run(gfx: backend.Backend) !void {
    _ = gfx;
    _ = build_options;
    @import("std").debug.print("session_run stub - full body incoming\n", .{});
}
