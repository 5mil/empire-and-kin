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

pub fn main() void {
    std.debug.print("Empire & Kin – Phase 9 Empire Layer\n", .{});
    std.debug.print("Rackets, crew orders, influence & reputation\n\n", .{});

    const selected_era = era_mod.Era.nyc_1930s;
    std.debug.print("Era: {s}\n\n", .{era_mod.name(selected_era)});

    var clock = time.Clock{ .time_scale = 60.0 };
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    var boss = player.create("Vinnie \"The Chin\"");
    var emp: empire.Empire = .{};

    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };

    // --- Build the empire ---
    _ = empire.addRacket(&emp, .speakeasy, .little_italy);
    _ = empire.addRacket(&emp, .numbers, .little_italy);
    _ = empire.addRacket(&emp, .protection, .hells_kitchen);
    _ = empire.addRacket(&emp, .smuggling, .brooklyn_waterfront);

    // Assign crew
    _ = empire.assignCrewToRacket(&emp, 0, 1); // Tony on speakeasy
    _ = empire.assignCrewToRacket(&emp, 1, 3); // Mickey on numbers
    _ = empire.assignCrewToRacket(&emp, 2, 2); // Sal on protection

    empire.printEmpireStatus(emp, the_kin);

    // --- Issue orders ---
    std.debug.print("--- Crew Orders ---\n", .{});
    const collected = empire.issueOrder(&the_kin, 1, .collect, &emp, &districts[0]);
    eco.treasury += collected;
    std.debug.print("Tony collected ${d} from the rackets.\n", .{collected});

    _ = empire.issueOrder(&the_kin, 2, .enforce, &emp, &districts[1]);
    std.debug.print("Sal enforced in Hell's Kitchen → control now {d}%\n", .{districts[1].control});

    _ = empire.issueOrder(&the_kin, 3, .scout, &emp, &districts[0]);
    std.debug.print("Mickey scouted Little Italy → heat now {d}\n", .{districts[0].heat});

    _ = empire.issueOrder(&the_kin, 0, .rest, &emp, &districts[0]);
    std.debug.print("Boss rested. Morale: {d}\n", .{the_kin.morale});

    // Upgrade a racket
    _ = empire.upgradeRacket(&emp, 0);
    std.debug.print("\nUpgraded Speakeasy to level {d}\n", .{emp.rackets[0].level});

    empire.changeReputation(&emp, 15);
    empire.addInfluence(&emp, 25);

    empire.printEmpireStatus(emp, the_kin);

    std.debug.print("Reputation: {s}\n", .{empire.reputationLabel(emp)});
    std.debug.print("Treasury: ${d}\n", .{eco.treasury});

    save.saveGame(eco, the_kin, clock);
    std.debug.print("\nState saved.\n", .{});
}
