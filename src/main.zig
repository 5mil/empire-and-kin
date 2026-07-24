const std = @import("std");
const combat = @import("game/combat.zig");
const missions = @import("game/missions.zig");
const healing = @import("game/healing.zig");
const city = @import("game/city.zig");
const crew = @import("game/crew.zig");
const economy = @import("game/economy.zig");
const events = @import("game/events.zig");
const rivals = @import("game/rivals.zig");
const save = @import("game/save.zig");

pub fn main() void {
    std.debug.print("Empire & Kin - Phase 5 Ready\n", .{});
    std.debug.print("Systems: Healing | Combat | Missions | City | Crew | Economy | Events | Rivals | Save\n\n", .{});

    // --- Crew ---
    var the_kin = crew.createStarterCrew();
    std.debug.print("Crew: {s} ({d} members) | Loyalty avg: {d}\n", .{ the_kin.name, the_kin.count, crew.averageLoyalty(the_kin) });

    // --- City Districts ---
    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };

    // --- Economy ---
    var eco = economy.init();
    economy.dailyTick(&eco, &districts, &the_kin);

    // --- Rivals ---
    var rival_families = rivals.createRivals();
    std.debug.print("\nRival Families:\n", .{});
    for (rival_families) |r| {
        const status = if (rivals.isWar(r)) "AT WAR" else "tense";
        std.debug.print("  - {s} (Boss: {s}) | Strength {d} | Hostility {d} [{s}]\n", .{ r.name, r.boss, r.strength, r.hostility, status });
    }

    // Provoke one rival a bit
    rivals.provoke(&rival_families[1], 25);
    std.debug.print("\nProvoked {s} \u2192 hostility now {d}\n", .{ rival_families[1].name, rival_families[1].hostility });

    // --- Random Event ---
    const ev = events.rollEvent(eco.day + 17);
    std.debug.print("\nEVENT: {s}\n  {s}\n", .{ ev.title, ev.description });
    events.applyEvent(ev, &districts, &the_kin, &eco.treasury);

    // --- Save / Load demo ---
    save.saveGame(eco, the_kin);
    std.debug.print("\nGame saved.\n", .{});

    if (save.loadGame()) |loaded| {
        std.debug.print("Loaded \u2192 Day {d} | Treasury ${d} | Influence {d} | Crew morale {d}\n", .{ loaded.day, loaded.treasury, loaded.influence, loaded.crew_morale });
    }

    economy.statusReport(eco, the_kin);
}
