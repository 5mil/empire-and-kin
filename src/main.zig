const std = @import("std");
const combat = @import("game/combat.zig");
const missions = @import("game/missions.zig");
const healing = @import("game/healing.zig");
const city = @import("game/city.zig");
const crew = @import("game/crew.zig");
const economy = @import("game/economy.zig");

pub fn main() void {
    std.debug.print("Empire & Kin - Phase 4 Ready\n", .{});
    std.debug.print("Systems: Healing | Combat | Missions | City | Crew | Economy\n\n", .{});

    // --- Crew ---
    var the_kin = crew.createStarterCrew();
    std.debug.print("Crew: {s} ({d} members) | Loyalty avg: {d}\n", .{ the_kin.name, the_kin.count, crew.averageLoyalty(the_kin) });

    // --- City Districts ---
    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };

    std.debug.print("\nDistricts under watch:\n", .{});
    for (districts) |d| {
        std.debug.print("  - {s}: Control {d}% | Heat {d} | Daily potential ${d}\n", .{ d.name, d.control, d.heat, city.dailyIncome(d) });
    }

    // --- Economy daily tick ---
    var eco = economy.init();
    economy.dailyTick(&eco, &districts, &the_kin);
    economy.statusReport(eco, the_kin);

    // --- Quick combat + mission reminder ---
    var enforcer = combat.Fighter{ .name = "Tony", .hp = 45, .attack = 14, .defense = 6 };
    var rival = combat.Fighter{ .name = "Rival", .hp = 30, .attack = 9, .defense = 3 };
    const dmg = combat.resolveHit(enforcer, rival);
    combat.applyDamage(&rival, dmg);
    std.debug.print("\nStreet fight: {s} drops rival for {d} dmg (rival HP: {d})\n", .{ enforcer.name, dmg, rival.hp });

    var job = missions.generateMission(42, .bootlegging);
    const payout = missions.completeMission(&job);
    std.debug.print("Job done: '{s}' \u2192 ${d}\n", .{ job.name, payout });
}
