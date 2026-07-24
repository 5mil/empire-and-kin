const std = @import("std");

pub const DistrictType = enum {
    lower_east_side,
    little_italy,
    hells_kitchen,
    harlem,
    brooklyn_waterfront,
    midtown,
};

pub const District = struct {
    name: []const u8,
    dtype: DistrictType,
    control: u8, // 0-100, player influence
    heat: u8, // police attention 0-100
    racket_income: u32,
    population: u16,
};

pub fn createDistrict(dtype: DistrictType) District {
    return switch (dtype) {
        .lower_east_side => .{
            .name = "Lower East Side",
            .dtype = dtype,
            .control = 35,
            .heat = 20,
            .racket_income = 180,
            .population = 4200,
        },
        .little_italy => .{
            .name = "Little Italy",
            .dtype = dtype,
            .control = 55,
            .heat = 15,
            .racket_income = 220,
            .population = 2800,
        },
        .hells_kitchen => .{
            .name = "Hell's Kitchen",
            .dtype = dtype,
            .control = 40,
            .heat = 35,
            .racket_income = 260,
            .population = 5100,
        },
        .harlem => .{
            .name = "Harlem",
            .dtype = dtype,
            .control = 25,
            .heat = 25,
            .racket_income = 190,
            .population = 6800,
        },
        .brooklyn_waterfront => .{
            .name = "Brooklyn Waterfront",
            .dtype = dtype,
            .control = 30,
            .heat = 40,
            .racket_income = 310,
            .population = 3500,
        },
        .midtown => .{
            .name = "Midtown",
            .dtype = dtype,
            .control = 10,
            .heat = 60,
            .racket_income = 450,
            .population = 9200,
        },
    };
}

pub fn dailyIncome(d: District) u32 {
    // Income scales with control, reduced by heat
    const control_factor = @as(u32, d.control);
    const heat_penalty = @as(u32, d.heat) / 5;
    if (control_factor <= heat_penalty) return 0;
    return (d.racket_income * (control_factor - heat_penalty)) / 100;
}

pub fn increaseControl(d: *District, amount: u8) void {
    d.control = @min(100, d.control + amount);
}

pub fn raiseHeat(d: *District, amount: u8) void {
    d.heat = @min(100, d.heat + amount);
}
