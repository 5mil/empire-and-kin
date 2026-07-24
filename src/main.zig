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
const empire_mod = @import("game/empire.zig");
const backend_mod = @import("engine/backend.zig");
const null_backend = @import("engine/null_backend.zig");

pub fn main() !void {
    std.debug.print("Empire & Kin – Steps 1–2: Engine backend + frame loop\n\n", .{});

    const selected_era = era_mod.Era.nyc_1930s;
    std.debug.print("Era: {s}\n", .{era_mod.name(selected_era)});
    std.debug.print("Art policy: public-domain historical sources preferred (see docs/ART_SOURCES.md)\n\n", .{});

    // --- Backend (Null for now → swap for Magister/Arcis/RealCity later) ---
    const gfx = null_backend.getBackend();
    try gfx.init("Empire & Kin", 1280, 720);

    // --- Simulation ---
    var clock = time.Clock{ .time_scale = 20.0 };
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    var boss = player.create("Vinnie \"The Chin\"");
    var emp: empire_mod.Empire = .{};
    _ = empire_mod.addRacket(&emp, .speakeasy, .little_italy);

    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };

    var streets: living.StreetLife = .{};
    var police: living.PoliceState = .{};
    var paused = false;

    // --- Frame loop (Step 2) ---
    while (!gfx.shouldClose()) {
        gfx.beginFrame();
        const dt = gfx.deltaTime();
        const input = gfx.pollInput();

        if (input.pause) paused = !paused;

        if (!paused) {
            clock.tick(dt);
            player.move(&boss, input.move_x, input.move_y, dt);
            world.updatePlayerDistrict(&boss);
            economy.tick(&eco, &districts, &the_kin, dt * clock.time_scale);

            const period = living.currentPeriod(clock);
            living.spawnStreetLife(&streets, living.activityLevel(period));
            living.tickStreetLife(&streets, dt * clock.time_scale);
            living.updatePolice(&police, districts[0].heat, boss.wanted_level, period, clock.elapsed);
        }

        // Debug “draw” via backend
        gfx.clear(backend_mod.Color.rgb(20, 20, 30));
        var line_buf: [128]u8 = undefined;
        const line = std.fmt.bufPrint(&line_buf, "{s} | Day {d} {d:0>2}:{d:0>2} | {s} | ${d}", .{
            world.districtName(boss.current_district),
            clock.day,
            clock.hour(),
            clock.minute(),
            if (paused) "PAUSED" else living.periodName(living.currentPeriod(clock)),
            eco.treasury,
        }) catch "status";
        gfx.drawText(line, 10, 10, backend_mod.Color.rgb(220, 220, 200));

        gfx.endFrame();
    }

    save.saveGame(eco, the_kin, clock);
    gfx.shutdown();
    std.debug.print("\nLoop ended. District={s} Influence setup ready. Save written.\n", .{
        world.districtName(boss.current_district),
    });
    _ = emp;
}
