const era = @import("era.zig");
const backend = @import("../engine/backend.zig");

pub fn asphalt(e: era.Era) backend.Color {
    return switch (e) {
        .nyc_1930s => backend.Color.rgb(42, 40, 38),
        .nyc_1980s => backend.Color.rgb(48, 48, 52),
    };
}

pub fn neon(e: era.Era) backend.Color {
    return switch (e) {
        .nyc_1930s => backend.Color.rgb(255, 230, 140),
        .nyc_1980s => backend.Color.rgb(255, 80, 180),
    };
}
