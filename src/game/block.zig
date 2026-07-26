const city = @import("city.zig");

pub fn controlLabel(c: u8) []const u8 {
    if (c >= 80) return "Iron grip";
    if (c >= 60) return "Strong";
    if (c >= 40) return "Contested";
    if (c >= 20) return "Weak";
    return "None";
}

pub fn heatLabel(h: u8) []const u8 {
    if (h >= 70) return "Blazing";
    if (h >= 40) return "Warm";
    if (h >= 15) return "Cool";
    return "Cold";
}

_ = city;
