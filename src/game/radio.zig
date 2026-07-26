pub fn chatter(seed: u32) []const u8 {
    return switch (seed % 6) {
        0 => "Radio: 10-4 unit on Mulberry",
        1 => "Radio: possible numbers bank",
        2 => "Radio: keep eyes on the docks",
        3 => "Radio: quiet sector",
        4 => "Radio: heat rising midtown",
        else => "Radio: all units standby",
    };
}
