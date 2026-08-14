//! Temporary stub until full body is assembled from parts.
//!
//!   cat src/engine/session_run_part0.zig.txt \
//!       src/engine/session_run_part1.zig.txt \
//!       src/engine/session_run_part2.zig.txt \
//!       > src/engine/session_run.zig
//!
//! Or copy artifacts/session_run_FULL.zig. See docs/MAIN_SIZE.md.
const std = @import("std");
const backend = @import("backend.zig");
const build_options = @import("build_options");

pub fn run(gfx: backend.Backend) !void {
    _ = build_options;
    std.debug.print("Assemble session_run from parts (docs/MAIN_SIZE.md)\n", .{});
    gfx.shutdown();
}
