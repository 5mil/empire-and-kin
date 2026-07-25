const std = @import("std");
const city = @import("game/city.zig");
const crew = @import("game/crew.zig");
const economy = @import("game/economy.zig");
const save = @import("game/save.zig");
const time = @import("game/time.zig");
const player = @import("game/player.zig");
const world = @import("game/world.zig");
const living = @import("game/living.zig");
const empire_mod = @import("game/empire.zig");
const action = @import("game/action.zig");
const properties = @import("game/properties.zig");
const garage = @import("game/garage.zig");
const null_backend = @import("engine/null_backend.zig");
const scene = @import("engine/scene.zig");
const input = @import("engine/input.zig");
const controller = @import("engine/controller.zig");
const hud = @import("engine/hud.zig");
const empire_ui = @import("engine/empire_ui.zig");
const wanted_ui = @import("engine/wanted_ui.zig");

pub fn main() !void {
    std.debug.print("Empire & Kin – Step 8: Wanted stars + police pursuit\n\n", .{});
    const gfx = null_backend.getBackend();
    try gfx.init("Empire & Kin", 1280, 720);

    var clock = time.Clock{ .time_scale = 20.0 };
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    var boss = player.create("Vinnie \"The Chin\"");
    boss.x = 10;
    boss.y = 20;

    var emp: empire_mod.Empire = .{};
    _ = empire_mod.addRacket(&emp, .speakeasy, .little_italy);
    _ = empire_mod.addRacket(&emp, .protection, .hells_kitchen);

    var portfolio = properties.createStarterPortfolio();
    var fleet = garage.createStarterFleet();
    _ = garage.setActive(&fleet, 0);

    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };
    districts[0].heat = 55;

    var streets: living.StreetLife = .{};
    var police: living.PoliceState = .{};
    var chase: action.ChaseState = .{};
    var ctrl: controller.Controller = .{};
    var menu: empire_ui.EmpireMenu = .{};

    var edge_ord: [5]input.ButtonEdge = .{ .{}, .{}, .{}, .{}, .{} };
    var edge_tab: input.ButtonEdge = .{};
    var edge_q: input.ButtonEdge = .{};
    var edge_e: input.ButtonEdge = .{};
    var edge_enter: input.ButtonEdge = .{};
    var edge_r: input.ButtonEdge = .{};
    var edge_f: input.ButtonEdge = .{};
    var edge_veh_e: input.ButtonEdge = .{};
    var heat_event_done = false;

    while (!gfx.shouldClose()) {
        gfx.beginFrame();
        const dt = gfx.deltaTime();
        const raw = null_backend.pollRawKeys();
        const car_ptr = garage.activeVehicle(&fleet);
        const in_car = if (car_ptr) |v| v.occupied else false;
        const speed: f32 = if (car_ptr) |v| v.speed else boss.speed;
        _ = ctrl.tick(raw, &boss, if (in_car) 0 else dt);

        if (ctrl.paused) {
            const keys = empire_ui.MenuKeys{
                .order_collect = edge_ord[0].pressed(raw.key_1),
                .order_rest = edge_ord[1].pressed(raw.key_2),
                .order_enforce = edge_ord[2].pressed(raw.key_3),
                .order_scout = edge_ord[3].pressed(raw.key_4),
                .order_guard = edge_ord[4].pressed(raw.key_5),
                .panel_next = edge_tab.pressed(raw.tab),
                .nav_prev = edge_q.pressed(raw.q),
                .nav_next = edge_e.pressed(raw.e),
                .primary = edge_enter.pressed(raw.enter),
                .secondary = edge_r.pressed(raw.r),
                .tertiary = edge_f.pressed(raw.f),
            };
            empire_ui.handleMenu(keys, &emp, &the_kin, &portfolio, &fleet, districts[0..], &menu, boss.x, boss.y);
            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, living.currentPeriod(clock), car_opt);
            empire_ui.draw(gfx, emp, the_kin, portfolio, fleet, &districts, menu);
        } else {
            if (car_ptr) |car| {
                if (edge_veh_e.pressed(raw.e)) {
                    if (car.occupied) action.exitVehicle(car, &boss)
                    else if (action.nearVehicle(car.*, boss, 4.0)) action.enterVehicle(car, &boss);
                }
                if (car.occupied) {
                    const st = ctrl.mapper.map(raw);
                    action.drive(car, &boss, st.move_x, st.move_y, dt);
                    world.updatePlayerDistrict(&boss);
                }
            }
            clock.tick(dt);
            economy.tick(&eco, &districts, &the_kin, dt * clock.time_scale);
            const period = living.currentPeriod(clock);
            living.spawnStreetLife(&streets, living.activityLevel(period));
            living.tickStreetLife(&streets, dt * clock.time_scale);

            if (!heat_event_done and clock.elapsed > 8.0) {
                districts[0].heat = 85;
                wanted_ui.addWanted(&boss, 3);
                heat_event_done = true;
                std.debug.print("[heat] Raid blowback — wanted raised\n", .{});
            }

            wanted_ui.tickWanted(&boss, &police, &chase, districts[0].heat, period, speed, dt, clock.elapsed);

            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, period, car_opt);
            hud.drawDistrictDebug(gfx, boss, &districts, clock, eco, period, false, police.alert_level);
            wanted_ui.drawStars(gfx, boss.wanted_level, 10, 248);
            wanted_ui.drawPoliceBanner(gfx, police, chase, 266);
        }
        gfx.endFrame();
    }
    save.saveGame(eco, the_kin, clock);
    gfx.shutdown();
    std.debug.print("\nStep 8 complete.\n", .{});
}
