pub const Level = enum { easy, normal, hard };

pub fn heatMult(l: Level) f32 {
    return switch (l) {
        .easy => 0.7,
        .normal => 1.0,
        .hard => 1.4,
    };
}

pub fn payMult(l: Level) f32 {
    return switch (l) {
        .easy => 1.2,
        .normal => 1.0,
        .hard => 0.85,
    };
}
