const backend = @import("backend.zig");
const district_travel = @import("../game/district_travel.zig");
const player = @import("../game/player.zig");

pub fn prompt(p: player.Player) []const u8 {
    if (district_travel.nearGate(p)) |g| {
        return "[E] Travel";
    }
    return "";
}

pub fn labelNear(p: player.Player) []const u8 {
    if (district_travel.nearGate(p)) |g| return g.label;
    return "";
}

pub fn draw(gfx: backend.Backend, p: player.Player) void {
    if (district_travel.nearGate(p)) |g| {
        gfx.drawText(g.label, 520, 640, backend.Color.rgb(200, 210, 255));
        gfx.drawText("[E] Travel to district", 480, 656, backend.Color.rgb(180, 190, 220));
    }
}
