const std = @import("std");
const backend = @import("backend.zig");
const score = @import("../game/score.zig");
const city = @import("../game/city.zig");
const economy = @import("../game/economy.zig");
const empire = @import("../game/empire.zig");

pub fn draw(gfx: backend.Backend, eco: economy.Economy, d: city.District, emp: empire.Empire) void {
    const s = score.compute(eco, d, emp);
    var buf: [32]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "Score {d}", .{s}) catch "Score";
    gfx.drawText(line, 1080, 90, backend.Color.rgb(200, 180, 120));
}
