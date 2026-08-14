//! Thin session entry — delegates to session_run so main stays <1 KB.
const backend = @import("backend.zig");
const session_run = @import("session_run.zig");

pub fn run(gfx: backend.Backend) !void {
    try session_run.run(gfx);
}
