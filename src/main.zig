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

pub fn main() void {
    std.debug.print("Empire & Kin – Phase 7 Free-Roam Skeleton\n", .{});
    std.debug.print("Player controller + district awareness + pauseable empire menu\n\n", .{});

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

    // --- Simulate a short free-roam session ---
    std.debug.print("--- Free-roam demo (moving through the city) ---\n", .{});

    // Step 1: start in Little Italy
    world.updatePlayerDistrict(&boss);
    std.debug.print("[{d:0>2}:{d:0>2}] {s} is in {s}  (x={d:.1}, y={d:.1})\n", .{
        clock.hour(), clock.minute(), boss.name, world.districtName(boss.current_district), boss.x, boss.y,
    });

    // Move east toward Hell's Kitchen
    var i: u32 = 0;
    while (i < 8) : (i += 1) {
        const dt: f64 = 1.0;
        clock.tick(dt);
        player.move(&boss, 1.0, 0.3, dt); // walk east-northeast
        world.updatePlayerDistrict(&boss);
        economy.tick(&eco, &districts, &the_kin, dt * clock.time_scale);

        std.debug.print("[{d:0>2}:{d:0>2}] Moved → {s}  (x={d:.1}, y={d:.1})\n", .{
            clock.hour(), clock.minute(), world.districtName(boss.current_district), boss.x, boss.y,
        });
    }

    // Open the empire management menu (pauses the world)
    ui.toggle(&menu);
    if (menu.open) {
        ui.drawEmpireOverview(boss, the_kin, eco, &districts, clock);
    }

    // Close menu and continue
    ui.toggle(&menu);
    std.debug.print("Menu closed – world continues.\n", .{});

    // Quick save
    save.saveGame(eco, the_kin, clock);
    std.debug.print("State saved.\n", .{});
}
