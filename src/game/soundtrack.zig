const living = @import("living.zig");

pub fn cue(period: living.Period) []const u8 {
    return switch (period) {
        .dawn => "soft_horns",
        .day => "street_hustle",
        .dusk => "amber_sax",
        .evening => "club_bass",
        .night => "noir_piano",
    };
}
