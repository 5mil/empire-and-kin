const backend = @import("backend.zig");
const zone = @import("../game/zone.zig");
const player = @import("../game/player.zig");

pub fn draw(gfx: backend.Backend, p: player.Player) void {
    gfx.drawText(zone.nameAt(p), 480, 716, backend.Color.rgb(100, 110, 130));
}
