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
const null_backend = @import("engine/null_backend.zig");
const scene = @import("engine/scene.zig");
const input = @import("engine/input.zig");
const controller = @import("engine/controller.zig");
const hud = @import("engine/hud.zig");
const empire_ui = @import("engine/empire_ui.zig");

pub fn main() !void {
    std.debug.print("Empire & Kin – Step 6: Empire pause UI\n\n", .{});
    std.debug.print("Bindings: {s}\n", .{input.bindingHelp()});
    std.debug.print("Empire menu: {s}\n\n", .{empire_ui.ORDER_KEYS});

    const selected_era = era_mod.Era.nyc_1930s;
    std.debug.print("Era: {s}\n\n", .{era_mod.name(selected_era)});

    const gfx = null_backend.getBackend();
    try gfx.init("Empire & Kin", 1280, 720);

    var clock = time.Clock{ .time_scale = 20.0 };
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    var boss = player.create("Vinnie \"The Chin\"");
    boss.wanted_level = 1;

    var emp: empire_mod.Empire = .{};
    _ = empire_mod.addRacket(&emp, .speakeasy, .little_italy);
    _ = empire_mod.addRacket(&emp, .numbers, .little_italy);
    _ = empire_mod.addRacket(&emp, .protection, .hells_kitchen);
    _ = empire_mod.assignCrewToRacket(&emp, 0, 1);
    _ = empire_mod.assignCrewToRacket(&emp, 1, 3);
    empire_mod.addInfluence(&emp, 15);
    empire_mod.changeReputation(&emp, 10);

    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
        city.createDistrict(.lower_east_side),
    };

    var streets: living.StreetLife = .{};
    var police: living.PoliceState = .{};
    var ctrl: controller.Controller = .{};
    var menu: empire_ui.EmpireMenu = .{};
    var order_edge: [5]input.ButtonEdge = .{ .{}, .{}, .{}, .{}, .{} };

    while (!gfx.shouldClose()) {
        gfx.beginFrame();
        const dt = gfx.deltaTime();
        const raw = null_backend.pollRawKeys();
        _ = ctrl.tick(raw, &boss, dt);

        if (ctrl.paused) {
            const keys = empire_ui.MenuKeys{
                .order_collect = order_edge[0].pressed(raw.key_1),
                .order_rest = order_edge[1].pressed(raw.key_2),
                .order_enforce = order_edge[2].pressed(raw.key_3),
                .order_scout = order_edge[3].pressed(raw.key_4),
                .order_guard = order_edge[4].pressed(raw.key_5),
            };
            empire_ui.handleOrders(keys, &emp, &the_kin, districts[0..], &menu);
            scene.drawMinimalScene(gfx, boss, living.currentPeriod(clock));
            empire_ui.draw(gfx, emp, the_kin, &districts, menu);
        } else {
            clock.tick(dt);
            economy.tick(&eco, &districts, &the_kin, dt * clock.time_scale);
            const period = living.currentPeriod(clock);
            living.spawnStreetLife(&streets, living.activityLevel(period));
            living.tickStreetLife(&streets, dt * clock.time_scale);
            living.updatePolice(&police, districts[0].heat, boss.wanted_level, period, clock.elapsed);

            if (ctrl.district_changed) {
                std.debug.print("[district] entered {s}\n", .{world.districtName(boss.current_district)});
            }

            scene.drawMinimalScene(gfx, boss, period);
            hud.drawDistrictDebug(gfx, boss, &districts, clock, eco, period, false, police.alert_level);
        }

        gfx.endFrame();
    }

    save.saveGame(eco, the_kin, clock);
    gfx.shutdown();
    std.debug.print("\nStep 6 complete. Empire pause UI + crew orders online.\n", .{});
}
