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
const time = @import("game/time.zig");

pub fn main() void {
    std.debug.print("Empire & Kin – Real-Time Core Ready\n", .{});
    std.debug.print("Philosophy: Continuous simulation (GTA action + Sims life + living city)\n\n", .{});

    // --- Clock (real-time simulation) ---
    var clock = time.Clock{
        .time_scale = 120.0, // 1 real second ≈ 2 game minutes for the demo
    };

    // --- Crew ---
    var the_kin = crew.createStarterCrew();
    std.debug.print("Crew: {s} ({d} members) | Avg Loyalty: {d}\n", .{ the_kin.name, the_kin.count, crew.averageLoyalty(the_kin) });

    // --- City ---
    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };

    // --- Economy & Rivals ---
    var eco = economy.init();
    var rival_families = rivals.createRivals();

    std.debug.print("\n--- Simulating 10 real seconds of world time ---\n", .{});

    // Simple fixed-step simulation loop (in a real engine this would be per-frame)
    const steps: u32 = 10;
    const dt_real: f64 = 1.0; // 1 real second per step for the demo

    var i: u32 = 0;
    while (i < steps) : (i += 1) {
        clock.tick(dt_real);
        economy.tick(&eco, &districts, &the_kin, dt_real * clock.time_scale);

        // Occasional event (very rough)
        if (i == 5) {
            const ev = events.rollEvent(@intFromFloat(clock.elapsed));
            std.debug.print("\n[Event] {s}: {s}\n", .{ ev.title, ev.description });
            events.applyEvent(ev, &districts, &the_kin, &eco.treasury);
        }
    }

    // --- Status ---
    economy.statusReport(eco, the_kin, clock.day, clock.hour(), clock.minute());

    // --- Rivals snapshot ---
    std.debug.print("\nRival pressure:\n", .{});
    for (rival_families) |r| {
        const war = if (rivals.isWar(r)) "WAR" else "cold";
        std.debug.print("  {s} – hostility {d} [{s}]\n", .{ r.name, r.hostility, war });
    }

    // --- Save ---
    save.saveGame(eco, the_kin, clock);
    std.debug.print("\nState saved (in-memory slot).\n", .{});

    std.debug.print("\nCore systems are continuous. Ready for real-time free-roam integration.\n", .{});
}
