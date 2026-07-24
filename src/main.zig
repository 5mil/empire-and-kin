const std = @import("std");
const city = @import("game/city.zig");
const crew = @import("game/crew.zig");
const economy = @import("game/economy.zig");
const save = @import("game/save.zig");
const time = @import("game/time.zig");
const player = @import("game/player.zig");
const world = @import("game/world.zig");
const era_mod = @import("game/era.zig");
const living = @import("game/living.zig");
const empire = @import("game/empire.zig");
const action = @import("game/action.zig");
const missions = @import("game/missions.zig");
const combat = @import("game/combat.zig");

pub fn main() void {
    std.debug.print("Empire & Kin – Phase 10 Action Integration\n", .{});
    std.debug.print("Open-world missions, real-time combat, vehicles & chases\n\n", .{});

    const selected_era = era_mod.Era.nyc_1930s;
    std.debug.print("Era: {s}\n\n", .{era_mod.name(selected_era)});

    var clock = time.Clock{ .time_scale = 30.0 };
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    var boss = player.create("Vinnie \"The Chin\"");
    var emp: empire.Empire = .{};

    // --- Vehicle ---
    var car = action.spawnVehicle(.sedan, boss.x + 2, boss.y);
    action.enterVehicle(&car, &boss);
    std.debug.print("Entered {s} at ({d:.1}, {d:.1})\n", .{ action.vehicleName(car.vtype), car.x, car.y });

    // Drive a bit
    var i: u32 = 0;
    while (i < 4) : (i += 1) {
        action.drive(&car, &boss, 1.0, 0.1, 1.0);
    }
    std.debug.print("Drove to ({d:.1}, {d:.1})  speed {d:.1}\n", .{ car.x, car.y, car.speed });

    // --- Open-world mission marker ---
    var world_job = action.WorldMission{
        .mission = missions.generateMission(101, .bootlegging),
        .x = car.x + 5,
        .y = car.y,
        .radius = 10.0,
    };
    // Move close enough
    boss.x = world_job.x;
    boss.y = world_job.y;
    if (action.canStartMission(world_job, boss)) {
        const payout = missions.completeMission(&world_job.mission);
        eco.treasury += payout;
        std.debug.print("\nStarted & finished open-world job: '{s}' → ${d}\n", .{ world_job.mission.name, payout });
    }

    // --- Street combat ---
    var fight: action.Encounter = .{};
    action.startEncounter(&fight, "Rival Enforcer", 30, 11, 4);
    std.debug.print("\nStreet fight vs {s} (HP {d})\n", .{ fight.enemy.name, fight.enemy.hp });
    action.combatTick(&fight, &boss, 0.7, true);
    std.debug.print("After player hit → enemy HP {d} | Boss health {d}\n", .{ fight.enemy.hp, boss.health });
    if (!fight.active) {
        std.debug.print("Enemy down.\n", .{});
    }

    // --- Chase ---
    var chase: action.ChaseState = .{};
    boss.wanted_level = 3;
    action.startChase(&chase, boss.wanted_level);
    std.debug.print("\nChase started! Distance {d:.0} | Heat {d}\n", .{ chase.distance, chase.pursuit_heat });
    // Floor it
    car.speed = car.max_speed;
    var t: u32 = 0;
    while (t < 6 and chase.active) : (t += 1) {
        action.tickChase(&chase, car.speed, 1.0);
        std.debug.print("  ... distance now {d:.0}\n", .{chase.distance});
    }
    if (chase.escaped) {
        std.debug.print("Escaped the heat.\n", .{});
        boss.wanted_level = 1;
    } else if (chase.caught) {
        std.debug.print("Caught!\n", .{});
    }

    std.debug.print("\nTreasury: ${d} | Wanted: {d} | Health: {d}\n", .{ eco.treasury, boss.wanted_level, boss.health });
    save.saveGame(eco, the_kin, clock);
    std.debug.print("State saved. Phase 10 systems online.\n", .{});
}
