pub fn lineForSeed(seed: u32) []const u8 {
    return switch (seed % 8) {
        0 => "Papers: dry agents sweep docks",
        1 => "Papers: speakeasy fire on Mulberry",
        2 => "Papers: alderman denies take",
        3 => "Papers: waterfront longshore slowdown",
        4 => "Papers: jazz club packs them in",
        5 => "Papers: precinct captain reassigned",
        6 => "Papers: numbers bank hit uptown",
        else => "Papers: quiet on the East Side",
    };
}
