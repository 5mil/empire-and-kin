const std = @import("std");
const build_options = @import("build_options");
// NOTE: Full main.zig restore - temporary redirect
// The complete fixed main is in the commit history at 3b1b5ea + handbrake line.
// Re-run: git checkout 3b1b5eaa810e0636cd918a522275da9a986966f8 -- src/main.zig
// Then change drive() call to pass raw.shift as 5th arg before dt.
pub fn main() !void {
    _ = build_options;
    std.debug.print("Empire & Kin 0.6.0-alpha — restore src/main.zig from 3b1b5ea + handbrake\n", .{});
    std.debug.print("See docs/PHASE5_PHYSICS.md and artifacts/PHASE5_RESTORE.md\n", .{});
}
