const std = @import("std");

pub const Fighter = struct {
    name: []const u8,
    hp: u8,
    attack: u8,
    defense: u8,
};

pub fn resolveHit(attacker: Fighter, defender: Fighter) u8 {
    // Simple damage: attack - defense, min 1
    const raw = if (attacker.attack > defender.defense)
        attacker.attack - defender.defense
    else
        1;
    return @min(raw, defender.hp);
}

pub fn isAlive(f: Fighter) bool {
    return f.hp > 0;
}

pub fn applyDamage(f: *Fighter, dmg: u8) void {
    if (dmg >= f.hp) {
        f.hp = 0;
    } else {
        f.hp -= dmg;
    }
}
