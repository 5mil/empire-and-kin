const std = @import("std");
const combat = @import("game/combat.zig");
const missions = @import("game/missions.zig");
const healing = @import("game/healing.zig");

pub fn main() void {
    std.debug.print("Empire & Kin - Phase 3 Ready\n", .{});
    std.debug.print("Systems online: Healing | Combat | Missions\n", .{});

    // Demo combat
    var enforcer = combat.Fighter{ .name = "Vinnie", .hp = 40, .attack = 12, .defense = 5 };
    var rival = combat.Fighter{ .name = "Tommy", .hp = 35, .attack = 10, .defense = 4 };

    const dmg = combat.resolveHit(enforcer, rival);
    combat.applyDamage(&rival, dmg);
    std.debug.print("Combat demo: {s} hits {s} for {d} dmg. Rival HP left: {d}\n", .{ enforcer.name, rival.name, dmg, rival.hp });

    // Demo mission
    var job = missions.generateMission(1, .heist);
    const payout = missions.completeMission(&job);
    std.debug.print("Mission demo: '{s}' completed. Payout: ${d}\n", .{ job.name, payout });
}
