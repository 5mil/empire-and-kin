const crew = @import("crew.zig");
const economy = @import("economy.zig");
const player = @import("player.zig");

pub const RECRUIT_COST: u32 = 600;

pub fn canRecruit(c: crew.Crew) bool {
    return c.count < 8;
}

pub fn hire(c: *crew.Crew, eco: *economy.Economy, name: []const u8) bool {
    if (!canRecruit(c.*) or eco.treasury < RECRUIT_COST) return false;
    eco.treasury -= RECRUIT_COST;
    const idx = c.count;
    c.members[idx] = .{
        .name = name,
        .role = .enforcer,
        .loyalty = 55,
        .skill = 50,
        .fatigue = 0,
        .alive = true,
    };
    c.count += 1;
    return true;
}

pub fn nearCorner(p: player.Player) bool {
    const dx = p.x - 15.0;
    const dz = p.y - 20.0;
    return dx * dx + dz * dz < 9.0;
}
