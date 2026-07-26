pub const Weather = enum { clear, rain, fog };

pub fn fromSeed(seed: u32) Weather {
    return switch (seed % 10) {
        0, 1 => .rain,
        2 => .fog,
        else => .clear,
    };
}

pub fn name(w: Weather) []const u8 {
    return switch (w) {
        .clear => "Clear",
        .rain => "Rain",
        .fog => "Fog",
    };
}

pub fn pedSpeedMult(w: Weather) f32 {
    return switch (w) {
        .clear => 1.0,
        .rain => 0.7,
        .fog => 0.85,
    };
}
