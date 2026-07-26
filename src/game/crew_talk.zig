pub fn line(seed: u32) []const u8 {
    return switch (seed % 6) {
        0 => "Tony: We oughta lean on that deli",
        1 => "Sal: Car's running hot, boss",
        2 => "Mickey: Cops been by twice",
        3 => "Tony: Dutch boys on Mulberry",
        4 => "Sal: Need a rest, Cap",
        else => "Mickey: Quiet for once",
    };
}
