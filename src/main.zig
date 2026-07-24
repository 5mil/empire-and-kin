const std = @import("std");
const city = @import("game/city.zig");
const crew = @import("game/crew.zig");
const economy = @import("game/economy.zig");
const events = @import("game/events.zig");
const rivals = @import("game/rivals.zig");
const save = @import("game/save.zig");
const time = @import("game/time.zig");
const player = @import("game/player.zig");
const world = @import("game/world.zig");
const ui = @import("game/ui.zig");
const era_mod = @import("game/era.zig");

pub fn main() void {
    std.debug.print("Empire & Kin – Era Select + Multi-Ethnic Underworld\n\n", .{});

    // === ERA SELECTION (demo both) ===
    // In a real build this would be a title-screen choice.
    const selected_era = era_mod.Era.nyc_1930s; // change to .nyc_1980s to switch
    // const selected_era = era_mod.Era.nyc_1980s;

    std.debug.print("Selected Era: {s}\n", .{era_mod.name(selected_era)});
    std.debug.print("{s}\n\n", .{era_mod.description(selected_era)});

    // --- Core systems ---
    var clock = time.Clock{ .time_scale = 60.0 };
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    var boss = player.create("Vinnie \"The Chin\"");
    var menu = ui.PauseMenu{};

    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
        city.createDistrict(.lower_east_side),
    };

    // --- Load era-specific rivals ---
    var org_buf: [rivals.MAX_RIVALS]rivals.RivalOrg = undefined;
    const rival_count = rivals.getRivalsForEra(selected_era, &org_buf);
    rivals.printRoster(org_buf[0..rival_count], rival_count);

    // --- Short free-roam demo ---
    std.debug.print("\n--- Free-roam (district awareness) ---\n", .{});
    world.updatePlayerDistrict(&boss);
    std.debug.print("{s} starts in {s}\n", .{ boss.name, world.districtName(boss.current_district) });

    var i: u32 = 0;
    while (i < 5) : (i += 1) {
        const dt: f64 = 1.0;
        clock.tick(dt);
        player.move(&boss, 1.0, 0.2, dt);
        world.updatePlayerDistrict(&boss);
        economy.tick(&eco, &districts, &the_kin, dt * clock.time_scale);
    }
    std.debug.print("After moving → now in {s}\n", .{world.districtName(boss.current_district)});

    // Empire menu
    ui.toggle(&menu);
    if (menu.open) {
        ui.drawEmpireOverview(boss, the_kin, eco, &districts, clock);
    }
    ui.toggle(&menu);

    save.saveGame(eco, the_kin, clock);
    std.debug.print("Era: {s} | State saved.\n", .{era_mod.shortLabel(selected_era)});
}
