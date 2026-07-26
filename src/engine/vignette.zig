const backend = @import("backend.zig");
const living = @import("../game/living.zig");

pub fn draw(gfx: backend.Backend, period: living.Period) void {
    const col = switch (period) {
        .dawn => backend.Color.rgb(200, 160, 180),
        .day => backend.Color.rgb(180, 200, 220),
        .dusk => backend.Color.rgb(220, 140, 100),
        .evening => backend.Color.rgb(140, 130, 180),
        .night => backend.Color.rgb(100, 110, 160),
    };
    gfx.drawText(living.periodName(period), 1180, 700, col);
}
