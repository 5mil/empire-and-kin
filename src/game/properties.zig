const std = @import("std");
const city = @import("city.zig");

pub const PropertyType = enum {
    safehouse,
    front_business,
    warehouse,
    garage,
    social_club,
};

pub fn propertyName(p: PropertyType) []const u8 {
    return switch (p) {
        .safehouse => "Safehouse",
        .front_business => "Front Business",
        .warehouse => "Warehouse",
        .garage => "Garage",
        .social_club => "Social Club",
    };
}

pub const Property = struct {
    ptype: PropertyType,
    district: city.DistrictType,
    name: []const u8,
    level: u8,
    condition: u8,
    monthly_upkeep: u32,
    capacity: u8,
    owned: bool = true,
};

pub const MAX_PROPERTIES = 16;

pub const Portfolio = struct {
    items: [MAX_PROPERTIES]Property = undefined,
    count: u8 = 0,
};

pub fn addProperty(pf: *Portfolio, p: Property) bool {
    if (pf.count >= MAX_PROPERTIES) return false;
    pf.items[pf.count] = p;
    pf.count += 1;
    return true;
}

pub fn upgradeProperty(pf: *Portfolio, idx: u8) bool {
    if (idx >= pf.count) return false;
    if (pf.items[idx].level >= 5) return false;
    pf.items[idx].level += 1;
    pf.items[idx].capacity += 2;
    pf.items[idx].monthly_upkeep += 40;
    pf.items[idx].condition = @min(100, pf.items[idx].condition + 15);
    return true;
}

pub fn repairProperty(pf: *Portfolio, idx: u8) bool {
    if (idx >= pf.count) return false;
    if (pf.items[idx].condition >= 100) return false;
    pf.items[idx].condition = 100;
    return true;
}

pub fn totalUpkeep(pf: Portfolio) u32 {
    var t: u32 = 0;
    var i: u8 = 0;
    while (i < pf.count) : (i += 1) t += pf.items[i].monthly_upkeep;
    return t;
}

pub fn createStarterPortfolio() Portfolio {
    var pf: Portfolio = .{};
    _ = addProperty(&pf, .{ .ptype = .safehouse, .district = .little_italy, .name = "Mulberry St. Flat", .level = 1, .condition = 80, .monthly_upkeep = 50, .capacity = 4 });
    _ = addProperty(&pf, .{ .ptype = .front_business, .district = .little_italy, .name = "Bella's Grocery", .level = 1, .condition = 90, .monthly_upkeep = 75, .capacity = 2 });
    _ = addProperty(&pf, .{ .ptype = .garage, .district = .hells_kitchen, .name = "10th Ave Garage", .level = 1, .condition = 70, .monthly_upkeep = 40, .capacity = 3 });
    return pf;
}
