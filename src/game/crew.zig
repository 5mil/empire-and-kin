const std = @import("std");

pub const Role = enum {
    enforcer,
    accountant,
    driver,
    lookout,
    boss,
};

pub const Member = struct {
    name: []const u8,
    role: Role,
    loyalty: u8, // 0-100
    skill: u8, // 0-100
    fatigue: u8, // 0-100
    alive: bool = true,
};

pub const Crew = struct {
    name: []const u8,
    members: [8]Member,
    count: u8,
    morale: u8,
    cash: u32,
};

pub fn createStarterCrew() Crew {
    var crew = Crew{
        .name = "The Kin",
        .members = undefined,
        .count = 4,
        .morale = 70,
        .cash = 1200,
    };

    crew.members[0] = .{ .name = "Vinnie \"The Chin\"", .role = .boss, .loyalty = 95, .skill = 80, .fatigue = 10 };
    crew.members[1] = .{ .name = "Tony", .role = .enforcer, .loyalty = 75, .skill = 70, .fatigue = 20 };
    crew.members[2] = .{ .name = "Sal", .role = .driver, .loyalty = 80, .skill = 65, .fatigue = 15 };
    crew.members[3] = .{ .name = "Mickey", .role = .lookout, .loyalty = 70, .skill = 60, .fatigue = 5 };

    return crew;
}

pub fn averageLoyalty(c: Crew) u8 {
    if (c.count == 0) return 0;
    var total: u32 = 0;
    var i: u8 = 0;
    while (i < c.count) : (i += 1) {
        if (c.members[i].alive) total += c.members[i].loyalty;
    }
    return @intCast(total / c.count);
}

pub fn payCrew(c: *Crew, amount_per: u32) void {
    const total = amount_per * c.count;
    if (c.cash >= total) {
        c.cash -= total;
        // Paying improves morale a bit
        c.morale = @min(100, c.morale + 5);
    } else {
        // Can't pay → morale drop
        if (c.morale > 15) c.morale -= 15 else c.morale = 0;
    }
}

pub fn restCrew(c: *Crew) void {
    var i: u8 = 0;
    while (i < c.count) : (i += 1) {
        if (c.members[i].alive and c.members[i].fatigue > 10) {
            c.members[i].fatigue -= 10;
        }
    }
    c.morale = @min(100, c.morale + 3);
}
