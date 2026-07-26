const std = @import("std");
const build_options = @import("build_options");
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
const era_mod = @import("game/era.zig");
const balance = @import("game/balance.zig");
const scene = @import("engine/scene.zig");
const input = @import("engine/input.zig");
const controller = @import("engine/controller.zig");
const hud = @import("engine/hud.zig");
const empire_ui = @import("engine/empire_ui.zig");
const wanted_ui = @import("engine/wanted_ui.zig");
const mission_ui = @import("engine/mission_ui.zig");
const boot_mod = @import("engine/boot.zig");
const world_sim = @import("engine/world_sim.zig");
const hints = @import("engine/hints.zig");
const combat_ui = @import("engine/combat_ui.zig");
const toast_mod = @import("engine/toast.zig");
const camera = @import("engine/camera.zig");
const minimap = @import("engine/minimap.zig");

const gfx_mod = if (build_options.enable_gpu)
    @import("engine/gl_backend.zig")
else
    @import("engine/null_backend.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;

    std.debug.print("Empire & Kin - ALPHA\n", .{});
    const gfx = gfx_mod.getBackend();
    try gfx.init("Empire & Kin", 1280, 720);

    var boot: boot_mod.BootState = .{};
    boot.has_save = (save.readFromDisk(io) catch null) != null;

    var clock = time.Clock{ .time_scale = balance.TIME_SCALE_DEMO };
    var the_kin = crew.createStarterCrew();
    var eco = economy.init();
    eco.treasury = balance.STARTING_TREASURY;
    var boss = player.create("Vinnie \"The Chin\"");
    boss.x = 10;
    boss.y = 20;

    var emp: empire_mod.Empire = .{};
    _ = empire_mod.addRacket(&emp, .speakeasy, .little_italy);
    _ = empire_mod.addRacket(&emp, .protection, .hells_kitchen);
    _ = empire_mod.assignCrewToRacket(&emp, 0, 1);

    var portfolio = properties.createStarterPortfolio();
    var fleet = garage.createStarterFleet();
    _ = garage.setActive(&fleet, 0);

    var districts = [_]city.District{
        city.createDistrict(.little_italy),
        city.createDistrict(.hells_kitchen),
        city.createDistrict(.brooklyn_waterfront),
    };

    var jobs = [_]mission_ui.ActiveJob{
        mission_ui.spawnJob(401, .bootlegging, 16.0, 22.0),
        mission_ui.spawnJob(402, .protection, 8.0, 28.0),
        mission_ui.spawnJob(403, .smuggling, 22.0, 12.0),
    };
    jobs[0].duration = balance.BOOTLEG_DURATION;
    jobs[1].duration = balance.PROTECTION_DURATION;
    jobs[2].duration = balance.SMUGGLING_DURATION;

    var streets: living.StreetLife = .{};
    var police: living.PoliceState = .{};
    var chase: action.ChaseState = .{};
    var ctrl: controller.Controller = .{};
    var menu: empire_ui.EmpireMenu = .{};
    var ws: world_sim.WorldSim = .{};
    var tip: hints.Hints = .{};
    var cui: combat_ui.CombatUI = .{};
    var toast: toast_mod.Toast = .{};
    var follow: camera.FollowCam = .{};
    var selected_era: era_mod.Era = .nyc_1930s;
    var world_ready = false;
    var heal_accum: f32 = 0;

    var edge_ord: [5]input.ButtonEdge = .{ .{}, .{}, .{}, .{}, .{} };
    var edge_tab: input.ButtonEdge = .{};
    var edge_q: input.ButtonEdge = .{};
    var edge_nav_e: input.ButtonEdge = .{};
    var edge_enter: input.ButtonEdge = .{};
    var edge_r: input.ButtonEdge = .{};
    var edge_f: input.ButtonEdge = .{};
    var edge_interact: input.ButtonEdge = .{};
    var edge_f5: input.ButtonEdge = .{};
    var edge_f9: input.ButtonEdge = .{};
    var edge_1: input.ButtonEdge = .{};
    var edge_2: input.ButtonEdge = .{};
    var edge_h: input.ButtonEdge = .{};
    var edge_x: input.ButtonEdge = .{};
    var frame_seed: u32 = 0;

    while (!gfx.shouldClose()) {
        gfx.beginFrame();
        const dt = gfx.deltaTime();
        const raw = gfx_mod.pollRawKeys();
        frame_seed +%= 1;
        toast.tick(dt);

        if (boot.phase != .playing) {
            boot_mod.handle(&boot, raw, &edge_1, &edge_2, &edge_enter);
            boot_mod.draw(gfx, boot);
            gfx.endFrame();
            if (boot.phase == .playing and !world_ready) {
                selected_era = boot.selected_era;
                world_sim.init(&ws, selected_era);
                ws.event_interval = balance.EVENT_INTERVAL;
                ws.rival_interval = balance.RIVAL_INTERVAL;
                if (boot.load_on_start) {
                    if (save.readFromDisk(io) catch null) |data| {
                        save.applyTo(data, &eco, &the_kin, &clock, &boss, districts[0..]);
                    }
                }
                std.debug.print("[alpha] Era: {s}\n", .{era_mod.name(selected_era)});
                world_ready = true;
            }
            continue;
        }

        if (edge_f5.pressed(raw.f5)) {
            const snap = save.capture(eco, the_kin, clock, boss, &districts);
            save.writeToDisk(io, snap) catch {};
            toast.show("Saved.", balance.TOAST_SAVE_SEC);
        }
        if (edge_f9.pressed(raw.f9)) {
            if (save.readFromDisk(io) catch null) |data| {
                save.applyTo(data, &eco, &the_kin, &clock, &boss, districts[0..]);
                toast.show("Loaded.", balance.TOAST_SAVE_SEC);
            }
        }

        hints.handle(&tip, raw, &edge_h, &edge_x);

        const car_ptr = garage.activeVehicle(&fleet);
        const in_car = if (car_ptr) |v| v.occupied else false;
        const speed: f32 = if (car_ptr) |v| v.speed else boss.speed;
        _ = ctrl.tick(raw, &boss, if (in_car) 0 else dt);

        const near_any = mission_ui.anyNear(&jobs, boss);
        const cam = follow.update(boss, in_car, dt);

        if (ctrl.paused) {
            const keys = empire_ui.MenuKeys{
                .order_collect = edge_ord[0].pressed(raw.key_1),
                .order_rest = edge_ord[1].pressed(raw.key_2),
                .order_enforce = edge_ord[2].pressed(raw.key_3),
                .order_scout = edge_ord[3].pressed(raw.key_4),
                .order_guard = edge_ord[4].pressed(raw.key_5),
                .panel_next = edge_tab.pressed(raw.tab),
                .nav_prev = edge_q.pressed(raw.q),
                .nav_next = edge_nav_e.pressed(raw.e),
                .primary = edge_enter.pressed(raw.enter),
                .secondary = edge_r.pressed(raw.r),
                .tertiary = edge_f.pressed(raw.f),
            };
            empire_ui.handleMenu(keys, &emp, &the_kin, &portfolio, &fleet, districts[0..], &menu, boss.x, boss.y);
            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, living.currentPeriod(clock), car_opt, cam, selected_era, near_any);
            empire_ui.draw(gfx, emp, the_kin, portfolio, fleet, &districts, menu);
        } else {
            if (edge_interact.pressed(raw.e)) {
                var used = false;
                for (&jobs) |*j| {
                    if (mission_ui.nearMarker(j.*, boss) and j.state == .available) {
                        if (mission_ui.tryStart(j, boss)) {
                            used = true;
                            toast.show("Job started", 1.5);
                            break;
                        }
                    }
                }
                if (!used) {
                    if (car_ptr) |car| {
                        if (car.occupied) {
                            action.exitVehicle(car, &boss);
                            toast.show("Left vehicle", 1.2);
                        } else if (action.nearVehicle(car.*, boss, 4.0)) {
                            action.enterVehicle(car, &boss);
                            toast.show("Entered vehicle", 1.2);
                        }
                    }
                }
            }
            if (car_ptr) |car| {
                if (car.occupied) {
                    const st = ctrl.mapper.map(raw);
                    action.drive(car, &boss, st.move_x, st.move_y, dt);
                    world.updatePlayerDistrict(&boss);
                }
            }
            clock.tick(dt);
            const sim_dt = dt * clock.time_scale;
            economy.tick(&eco, &districts, &the_kin, sim_dt);
            const period = living.currentPeriod(clock);
            living.spawnStreetLife(&streets, living.activityLevel(period));
            living.tickStreetLife(&streets, sim_dt);
            world_sim.tick(&ws, sim_dt, districts[0..], &the_kin, &eco, &boss);

            for (&jobs) |*j| {
                const pay = mission_ui.tickJob(j, &boss, &eco, &districts[0], dt);
                if (pay > 0) {
                    var buf: [48]u8 = undefined;
                    const line = std.fmt.bufPrint(&buf, "Job done +${d}", .{pay}) catch "Job done";
                    toast.show(line, balance.TOAST_JOB_SEC);
                }
            }

            // design 18: passive heal when calm
            if (districts[0].heat < balance.HEAL_MAX_HEAT and !cui.encounter.active and boss.health < 100) {
                heal_accum += balance.HEAL_PER_SEC * @as(f32, @floatCast(dt));
                if (heal_accum >= 1.0) {
                    const amt: u8 = @intFromFloat(@min(heal_accum, 5.0));
                    player.heal(&boss, amt);
                    heal_accum -= @as(f32, @floatFromInt(amt));
                }
            }

            combat_ui.maybeSpawn(&cui, boss, districts[0].heat, frame_seed);
            combat_ui.tick(&cui, &boss, dt, edge_f.pressed(raw.f) and cui.encounter.active);
            wanted_ui.tickWanted(&boss, &police, &chase, districts[0].heat, period, speed, dt, clock.elapsed);

            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, period, car_opt, cam, selected_era, near_any);
            hud.drawDistrictDebug(gfx, boss, &districts, clock, eco, period, false, police.alert_level);
            wanted_ui.drawStars(gfx, boss.wanted_level, 10, 140);
            wanted_ui.drawPoliceBanner(gfx, police, chase, 158);
            for (jobs) |j| mission_ui.drawMarker(gfx, j, boss);
            mission_ui.drawMinimapHint(gfx, &jobs, boss);
            minimap.draw(gfx, boss, &jobs);
            world_sim.drawBanner(gfx, ws);
            hints.draw(gfx, tip);
            combat_ui.draw(gfx, cui);
            toast.draw(gfx);
        }
        gfx.endFrame();
    }

    const final_snap = save.capture(eco, the_kin, clock, boss, &districts);
    save.writeToDisk(io, final_snap) catch {};
    gfx.shutdown();
    std.debug.print("=== EXIT === Saved | ${d} | {s}\n", .{ eco.treasury, era_mod.name(selected_era) });
}
