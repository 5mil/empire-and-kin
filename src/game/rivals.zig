const std = @import("std");

pub const RivalFamily = struct {
    name: []const u8,
    boss: []const u8,
    strength: u8, // 1-100
    territory: u8, // districts controlled approx
    hostility: u8, // 0-100 toward player
    cash: u32,
};

pub fn createRivals() [3]RivalFamily {
    return .{
        .{
            .name = "Maranzano Outfit",
            .boss = "Salvatore Maranzano",
            .strength = 75,
            .territory = 3,
            .hostility = 40,
            .cash = 8500,
        },
        .{
            .name = "Masseria Crew",
            .boss = "Joe Masseria",
            .strength = 80,
            .territory = 4,
            .hostility = 55,
            .cash = 12000,
        },
        .{
            .name = "Irish Mob (West Side)",
            .boss = "Owney Madden",
            .strength = 60,
            .territory = 2,
            .hostility = 30,
            .cash = 6200,
        },
    };
}

pub fn provoke(r: *RivalFamily, amount: u8) void {
    r.hostility = @min(100, r.hostility + amount);
}

pub fn coolDown(r: *RivalFamily, amount: u8) void {
    if (r.hostility > amount) {
        r.hostility -= amount;
    } else {
        r.hostility = 0;
    }
}

pub fn isWar(r: RivalFamily) bool {
    return r.hostility >= 70;
}

pub fn powerCheck(player_strength: u8, r: RivalFamily) bool {
    // Returns true if player is stronger
    return player_strength > r.strength;
}
