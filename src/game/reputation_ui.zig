const empire = @import("empire.zig");

pub fn short(e: empire.Empire) []const u8 {
    return empire.reputationLabel(e);
}
