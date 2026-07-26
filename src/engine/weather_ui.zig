const backend = @import("backend.zig");
const weather = @import("../game/weather.zig");

pub fn draw(gfx: backend.Backend, w: weather.Weather) void {
    const col = switch (w) {
        .clear => backend.Color.rgb(180, 200, 220),
        .rain => backend.Color.rgb(120, 140, 180),
        .fog => backend.Color.rgb(160, 160, 150),
    };
    gfx.drawText(weather.name(w), 1180, 680, col);
}
