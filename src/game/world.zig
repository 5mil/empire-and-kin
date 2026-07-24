const std = @import("std");
const city = @import("city.zig");
const player = @import("player.zig");

/// Very simple district bounds for location awareness.
/// In a real engine these would come from the map / streaming system.
const DistrictBounds = struct {
    dtype: city.DistrictType,
    min_x: f32,
    max_x: f32,
    min_y: f32,
    max_y: f32,
};

const bounds = [_]DistrictBounds{
    .{ .dtype = .little_italy, .min_x = 0, .max_x = 40, .min_y = 0, .max_y = 40 },
    .{ .dtype = .hells_kitchen, .min_x = 40, .max_x = 80, .min_y = 0, .max_y = 50 },
    .{ .dtype = .brooklyn_waterfront, .min_x = 0, .max_x = 60, .min_y = 40, .max_y = 90 },
    .{ .dtype = .lower_east_side, .min_x = -30, .max_x = 0, .min_y = 0, .max_y = 40 },
    .{ .dtype = .harlem, .min_x = 20, .max_x = 70, .min_y = 90, .max_y = 140 },
    .{ .dtype = .midtown, .min_x = 30, .max_x = 90, .min_y = 50, .max_y = 100 },
};

/// Update which district the player is currently in based on position.
pub fn updatePlayerDistrict(p: *player.Player) void {
    for (bounds) |b| {
        if (p.x >= b.min_x and p.x < b.max_x and p.y >= b.min_y and p.y < b.max_y) {
            p.current_district = b.dtype;
            return;
        }
    }
    // fallback – stay where we are
}

pub fn districtName(d: city.DistrictType) []const u8 {
    return switch (d) {
        .lower_east_side => "Lower East Side",
        .little_italy => "Little Italy",
        .hells_kitchen => "Hell's Kitchen",
        .harlem => "Harlem",
        .brooklyn_waterfront => "Brooklyn Waterfront",
        .midtown => "Midtown",
    };
}
