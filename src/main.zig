const std = @import("std");
const city = @import("game/city.zig");
const crew = @import("game/crew.zig");
const economy = @import("game/economy.zig");
const rivals = @import("game/rivals.zig");
const save = @import("game/save.zig");
const time = @import("game/time.zig");
const player = @import("game/player.zig");
const world = @import("game/world.zig");
const ui = @import("game/ui.zig");
const era_mod = @import("game/era.zig");
const living = @import("game/living.zig");

pub fn main() void {
    std.debug.print("Empire & Kin – Phase 8 Living World\n", .{});
    std.debug.print("Pedestrians, traffic, day/night, dynamic police\n\n", .{});

    const selected_era = era_mod.Era.nyc_1930s;
    std.debug.print("Era: {s}\n\n", .{era_mod.name(selected_era)});

    // --- Core ---
    var clock = time.Clock{ .time_scale = 180.0 }; // fast demo: ~3 min per real sec
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    var boss = player.create("Vinnie \"The Chin\"");
    boss.wanted_level = 2; // start with a little heat

    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };

    // --- Street life ---
    var streets: living.StreetLife = .{};
    var police: living.PoliceState = .{};

    // Simulate several hours of game time so we see day → dusk → night
    std.debug.print("--- Living world simulation ---\n", .{});

    var step: u32 = 0;
    while (step < 12) : (step += 1) {
        const dt: f64 = 1.0;
        clock.tick(dt);
        const period = living.currentPeriod(clock);
        const activity = living.activityLevel(period);

        // Respawn / scale street life with time of day
        living.spawnStreetLife(&streets, activity);
        living.tickStreetLife(&streets, dt * clock.time_scale);

        // Police react to district heat + player wanted + time of day
        const heat = districts[0].heat;
        living.updatePolice(&police, heat, boss.wanted_level, period, clock.elapsed);

        economy.tick(&eco, &districts, &the_kin, dt * clock.time_scale);
        world.updatePlayerDistrict(&boss);

        if (step % 3 == 0) {
            std.debug.print("[{d:0>2}:{d:0>2}] {s:<7} | Peds {d:2}  Cars {d:2}  | Police: {s} (alert {d})\n", .{
                clock.hour(),
                clock.minute(),
                living.periodName(period),
                streets.ped_count,
                streets.vehicle_count,
                living.policeStatus(police),
                police.alert_level,
            });
        }
    }

    // Raise heat and wanted to show police escalation
    std.debug.print("\n--- Heat spike (raid gone wrong) ---\n", .{});
    districts[0].heat = 80;
    boss.wanted_level = 4;
    living.updatePolice(&police, districts[0].heat, boss.wanted_level, living.currentPeriod(clock), clock.elapsed);
    std.debug.print("Police response → {s} | Units nearby: {d}\n", .{
        living.policeStatus(police),
        police.units_nearby,
    });

    // Quick status
    std.debug.print("\nLocation: {s} | Wanted: {d} | Treasury: ${d}\n", .{
        world.districtName(boss.current_district),
        boss.wanted_level,
        eco.treasury,
    });

    save.saveGame(eco, the_kin, clock);
    std.debug.print("State saved.\n", .{});
}
