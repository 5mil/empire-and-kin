const std = @import("std");

pub const Era = enum {
    nyc_1930s,
    nyc_1980s,
};

pub fn name(e: Era) []const u8 {
    return switch (e) {
        .nyc_1930s => "1930s New York",
        .nyc_1980s => "1980s New York",
    };
}

pub fn shortLabel(e: Era) []const u8 {
    return switch (e) {
        .nyc_1930s => "1930s",
        .nyc_1980s => "1980s",
    };
}

pub fn description(e: Era) []const u8 {
    return switch (e) {
        .nyc_1930s => "Post-Prohibition. The Five Families are forming. Jewish, Irish and Italian outfits still battle for the rackets.",
        .nyc_1980s => "The Commission still rules, but the Westies, Chinatown tongs and rising crews carve their own pieces of the city.",
    };
}
