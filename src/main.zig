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
const scene = @import("engine/scene.zig");
const input = @import("engine/input.zig");
const controller = @import("engine/controller.zig");

pub fn main() !void {
    std.debug.print("Empire & Kin – Step 4: Input → player controller\n\n", .{});
    std.debug.print("Bindings: {s}\n\n", .{input.bindingHelp()});

    const selected_era = era_mod.Era.nyc_1930s;
    std.debug.print("Era: {s}\n\n", .{era_mod.name(selected_era)});

    const gfx = null_backend.getBackend();
    try gfx.init("Empire & Kin", 1280, 720);

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
    var ctrl: controller.Controller = .{};

    while (!gfx.shouldClose()) {
        gfx.beginFrame();
        const dt = gfx.deltaTime();

        const raw = null_backend.pollRawKeys();
        const state = ctrl.tick(raw, &boss, dt);

        if (!ctrl.paused) {
            clock.tick(dt);
            economy.tick(&eco, &districts, &the_kin, dt * clock.time_scale);

            const period = living.currentPeriod(clock);
            living.spawnStreetLife(&streets, living.activityLevel(period));
            living.tickStreetLife(&streets, dt * clock.time_scale);
            living.updatePolice(&police, districts[0].heat, boss.wanted_level, period, clock.elapsed);
        }

        if (ctrl.district_changed) {
            std.debug.print("[district] entered {s}\n", .{world.districtName(boss.current_district)});
        }

        const period_now = living.currentPeriod(clock);
        scene.drawMinimalScene(gfx, boss, period_now);

        var line_buf: [192]u8 = undefined;
        const line = std.fmt.bufPrint(&line_buf, "{s} | {s} | pos ({d:.1},{d:.1}) | move ({d:.1},{d:.1}) | ${d}", .{
            world.districtName(boss.current_district),
            if (ctrl.paused) "PAUSED" else living.periodName(period_now),
            boss.x,
            boss.y,
            state.move_x,
            state.move_y,
            eco.treasury,
        }) catch "status";
        gfx.drawText(line, 10, 10, backend_mod.Color.rgb(220, 220, 200));

        gfx.endFrame();
    }

    save.saveGame(eco, the_kin, clock);
    gfx.shutdown();
    std.debug.print("\nStep 4 complete. Input mapper + controller ready for real devices.\n", .{});
    _ = emp;
}
