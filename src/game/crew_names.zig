pub fn nameFor(seed: u32) []const u8 {
    return switch (seed % 8) {
        0 => "Rocco",
        1 => "Frankie",
        2 => "Paulie",
        3 => "Vito",
        4 => "Angelo",
        5 => "Joey",
        6 => "Nino",
        else => "Carlo",
    };
}
