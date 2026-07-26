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
const goals = @import("game/goals.zig");
const heat = @import("game/heat.zig");
const peds = @import("game/peds.zig");
const traffic = @import("game/traffic.zig");
const fence = @import("game/fence.zig");
const stash_mod = @import("game/stash.zig");
const lookout_mod = @import("game/lookout.zig");
const rival_mod = @import("game/rival.zig");
const news = @import("game/news.zig");
const events = @import("game/events.zig");
const respect = @import("game/respect.zig");
const doc = @import("game/doc.zig");
const numbers = @import("game/numbers.zig");
const weather_mod = @import("game/weather.zig");
const loan_mod = @import("game/loan.zig");
const day_cycle = @import("game/day_cycle.zig");
const crew_talk = @import("game/crew_talk.zig");
const tipjar = @import("game/tipjar.zig");
const inventory_mod = @import("game/inventory.zig");
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
const choice_mod = @import("engine/choice.zig");
const feed_mod = @import("engine/feed.zig");
const compass = @import("engine/compass.zig");
const legend = @import("engine/legend.zig");
const vignette = @import("engine/vignette.zig");
const prompt = @import("engine/prompt.zig");
const scoreboard = @import("engine/scoreboard.zig");
const weather_ui = @import("engine/weather_ui.zig");
const hp_bar = @import("engine/hp_bar.zig");
const backend = @import("engine/backend.zig");

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
        mission_ui.spawnJob(404, .protection, 12.0, 16.0),
    };
    jobs[0].duration = balance.BOOTLEG_DURATION;
    jobs[1].duration = balance.PROTECTION_DURATION;
    jobs[2].duration = balance.SMUGGLING_DURATION;
    jobs[3].duration = balance.PROTECTION_DURATION;

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
    var choice: choice_mod.Choice = .{};
    var goal: goals.Goal = .{};
    var feed: feed_mod.Feed = .{};
    var street_peds: peds.StreetPeds = .{};
    street_peds.init();
    var cars: traffic.Traffic = .{};
    var stash: stash_mod.Stash = .{};
    var lookout: lookout_mod.Lookout = .{};
    var rival: rival_mod.Rival = .{};
    var loan: loan_mod.Loan = .{};
    var dayw: day_cycle.DayWatch = .{};
    var inv: inventory_mod.Inventory = .{};
    _ = inv.add(.medkit);
    var weather = weather_mod.Weather.clear;
    var selected_era: era_mod.Era = .nyc_1930s;
    var world_ready = false;
    var heal_accum: f32 = 0;
    var heat_accum: f32 = 0;
    var safehouse_cd: f64 = 0;
    var street_event_cd: f64 = balance.STREET_EVENT_INTERVAL;
    var news_cd: f64 = 60.0;
    var banter_cd: f64 = 40.0;
    var weather_cd: f64 = 90.0;

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

    feed.push("Welcome to Little Italy");

    while (!gfx.shouldClose()) {
        gfx.beginFrame();
        const dt = gfx.deltaTime();
        const raw = gfx_mod.pollRawKeys();
        frame_seed +%= 1;
        toast.tick(dt);
        lookout_mod.tick(&lookout, dt);
        if (menu.collect_cooldown > 0) menu.collect_cooldown -= dt;
        if (safehouse_cd > 0) safehouse_cd -= dt;
        if (street_event_cd > 0) street_event_cd -= dt;
        if (news_cd > 0) news_cd -= dt;
        if (banter_cd > 0) banter_cd -= dt;
        if (weather_cd > 0) weather_cd -= dt;

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
                        save.applyFull(data, &eco, &the_kin, &clock, &boss, districts[0..], &goal, &stash, &emp);
                    }
                }
                std.debug.print("[alpha] Era: {s}\n", .{era_mod.name(selected_era)});
                feed.push(era_mod.name(selected_era));
                world_ready = true;
            }
            continue;
        }

        if (choice.active) {
            if (choice_mod.handle(&choice, raw, &edge_1, &edge_2, &eco, &the_kin, &districts[0])) |msg| {
                toast.show(msg, 2.5);
                feed.push(msg);
                respect.earnStreet(&emp, 1);
                if (goals.check(&goal, districts[0], eco)) {
                    toast.show("GOAL TIER UP", 3.5);
                    feed.push("Goal tier advanced");
                }
            }
            const car_ptr0 = garage.activeVehicle(&fleet);
            const car_opt0: ?action.Vehicle = if (car_ptr0) |v| v.* else null;
            const cam0 = follow.update(boss, false, dt);
            scene.drawMinimalScene(gfx, boss, living.currentPeriod(clock), car_opt0, cam0, selected_era, false);
            street_peds.draw(gfx);
            cars.draw(gfx);
            choice_mod.draw(gfx, choice);
            toast.draw(gfx);
            gfx.endFrame();
            continue;
        }

        if (edge_f5.pressed(raw.f5)) {
            const snap = save.captureFull(eco, the_kin, clock, boss, &districts, goal, stash, emp);
            save.writeToDisk(io, snap) catch {};
            toast.show("Saved.", balance.TOAST_SAVE_SEC);
            feed.push("Quick-saved");
        }
        if (edge_f9.pressed(raw.f9)) {
            if (save.readFromDisk(io) catch null) |data| {
                save.applyFull(data, &eco, &the_kin, &clock, &boss, districts[0..], &goal, &stash, &emp);
                toast.show("Loaded.", balance.TOAST_SAVE_SEC);
                feed.push("Loaded save");
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
            if (keys.order_guard and lookout_mod.post(&lookout, &the_kin)) {
                toast.show("Lookout posted 20s", 2.0);
                feed.push("Lookout on the corner");
            }
            // Tip crew with 1 on rackets? Use order_rest secondary path: key_2 while rackets = tip
            if (keys.order_rest and menu.panel == .crew) {
                if (tipjar.tip(&eco, &the_kin, 100)) {
                    toast.show("Tipped the boys $100", 2.0);
                    feed.push("Crew tipped");
                }
            }
            if (keys.order_collect and menu.panel == .crew) {
                if (loan_mod.borrow(&loan, &eco, 1000)) {
                    toast.show("Borrowed $1000", 2.0);
                    feed.push("Loan taken");
                } else if (loan_mod.repay(&loan, &eco)) {
                    toast.show("Loan repaid", 2.0);
                    feed.push("Debt cleared");
                }
            }
            empire_ui.handleMenu(keys, &emp, &the_kin, &portfolio, &fleet, districts[0..], &menu, boss.x, boss.y, &eco);
            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, living.currentPeriod(clock), car_opt, cam, selected_era, near_any);
            empire_ui.draw(gfx, emp, the_kin, portfolio, fleet, &districts, menu);
        } else {
            var action_prompt: []const u8 = "";
            if (edge_interact.pressed(raw.e)) {
                var used = false;
                for (&jobs) |*j| {
                    if (mission_ui.nearMarker(j.*, boss) and j.state == .available) {
                        if (mission_ui.tryStart(j, boss)) {
                            used = true;
                            toast.show("Job started", 1.5);
                            feed.push("Job started");
                            break;
                        }
                    }
                }
                if (!used and scene.nearSafehouse(boss) and safehouse_cd <= 0) {
                    player.heal(&boss, 25);
                    if (districts[0].heat > 12) districts[0].heat -= 12 else districts[0].heat = 0;
                    if (boss.wanted_level > 0) boss.wanted_level -= 1;
                    safehouse_cd = 30.0;
                    toast.show("Safehouse: healed", 2.5);
                    feed.push("Used safehouse");
                    used = true;
                }
                if (!used and fence.near(boss)) {
                    if (fence.coolHeat(&eco, &districts[0])) {
                        toast.show("Fence cooled heat", 2.0);
                        feed.push("Fence: heat down");
                        used = true;
                    } else if (fence.clearStar(&eco, &boss)) {
                        toast.show("Fence cleared a star", 2.0);
                        feed.push("Fence: star gone");
                        used = true;
                    } else {
                        toast.show("Fence wants cash", 1.5);
                        used = true;
                    }
                }
                if (!used and stash_mod.near(boss)) {
                    if (stash_mod.deposit(&stash, &eco, balance.STASH_CHUNK)) {
                        toast.show("Stashed $250", 1.5);
                        feed.push("Cash in the stash");
                    } else if (stash_mod.withdraw(&stash, &eco, balance.STASH_CHUNK)) {
                        toast.show("Withdrew $250", 1.5);
                        feed.push("Took from stash");
                    } else {
                        toast.show("Stash empty / no cash", 1.5);
                    }
                    used = true;
                }
                if (!used and doc.near(boss)) {
                    if (doc.heal(&boss, &eco)) {
                        toast.show("Doc patched you up", 2.0);
                        feed.push("Saw the Doc");
                    } else {
                        toast.show("Doc: $300 or already full", 1.5);
                    }
                    used = true;
                }
                if (!used and numbers.near(boss)) {
                    const delta = numbers.play(&eco, frame_seed);
                    if (delta > 0) {
                        toast.show("Numbers hit!", 2.0);
                        feed.push("Numbers win");
                    } else if (delta < 0) {
                        toast.show("Numbers miss", 1.5);
                        feed.push("Numbers loss");
                    } else {
                        toast.show("Need $100 to play", 1.5);
                    }
                    used = true;
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
            if (edge_r.pressed(raw.r) and scene.nearSafehouse(boss)) {
                if (eco.treasury >= balance.BRIBE_COST and boss.wanted_level > 0) {
                    eco.treasury -= balance.BRIBE_COST;
                    boss.wanted_level = 0;
                    toast.show("Bribed cops", 2.5);
                    feed.push("Bribe paid");
                }
            }

            if (fence.near(boss)) action_prompt = "[E] Fence - heat/star for cash";
            else if (stash_mod.near(boss)) action_prompt = "[E] Stash $250";
            else if (doc.near(boss)) action_prompt = "[E] Doc - full heal $300";
            else if (numbers.near(boss)) action_prompt = "[E] Numbers - bet $100";
            else if (scene.nearSafehouse(boss)) action_prompt = "[E] heal  [R] bribe";

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
            heat.applyDecayAccum(&districts[0], &heat_accum, dt);
            street_peds.tick(dt);
            cars.tick(dt);
            rival_mod.tick(&rival, &districts[0], clock.elapsed);
            lookout_mod.suppressAlert(lookout, &police);

            if (day_cycle.crossed(&dayw, clock)) {
                loan_mod.tickDay(&loan, &eco);
                feed.push("A new day");
                if (loan.due > 0) feed.push("Loan still due");
            }

            if (street_event_cd <= 0) {
                street_event_cd = balance.STREET_EVENT_INTERVAL;
                const ev = events.rollEvent(frame_seed);
                events.applyEvent(ev, districts[0..], &the_kin, &eco.treasury);
                toast.show(ev.title, 3.0);
                feed.push(ev.title);
            }
            if (news_cd <= 0) {
                news_cd = 75.0;
                feed.push(news.lineForSeed(frame_seed));
            }
            if (banter_cd <= 0) {
                banter_cd = 50.0;
                feed.push(crew_talk.line(frame_seed));
            }
            if (weather_cd <= 0) {
                weather_cd = 120.0;
                weather = weather_mod.fromSeed(frame_seed);
                feed.push(weather_mod.name(weather));
            }

            for (&jobs) |*j| {
                const pay = mission_ui.tickJob(j, &boss, &eco, &districts[0], emp, dt);
                if (pay > 0) {
                    choice_mod.open(&choice, pay);
                    feed.push("Job finished - choose");
                    rival_mod.pushBack(&rival);
                }
            }

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
            if (goals.check(&goal, districts[0], eco)) {
                toast.show("GOAL TIER UP", 3.5);
                feed.push("Goal tier up");
            }

            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, period, car_opt, cam, selected_era, near_any);
            gfx.drawBox(.{ .x = fence.FENCE_X, .y = 0.8, .z = fence.FENCE_Z }, 1.2, 1.6, 1.2, backend.Color.rgb(120, 90, 40));
            gfx.drawBox(.{ .x = stash_mod.STASH_X, .y = 0.4, .z = stash_mod.STASH_Z }, 1.0, 0.8, 1.0, backend.Color.rgb(60, 50, 40));
            gfx.drawBox(.{ .x = doc.DOC_X, .y = 0.9, .z = doc.DOC_Z }, 1.4, 1.8, 1.4, backend.Color.rgb(200, 200, 210));
            gfx.drawBox(.{ .x = numbers.BANK_X, .y = 0.7, .z = numbers.BANK_Z }, 1.5, 1.4, 1.5, backend.Color.rgb(90, 70, 110));
            street_peds.draw(gfx);
            cars.draw(gfx);
            hud.drawDistrictDebug(gfx, boss, &districts, clock, eco, period, false, police.alert_level, goal);
            hp_bar.draw(gfx, boss.health, 10, 300);
            wanted_ui.drawStars(gfx, boss.wanted_level, 10, 250);
            wanted_ui.drawPoliceBanner(gfx, police, chase, 268);
            for (jobs) |j| mission_ui.drawMarker(gfx, j, boss);
            mission_ui.drawMinimapHint(gfx, &jobs, boss);
            compass.draw(gfx, boss, &jobs);
            legend.draw(gfx);
            vignette.draw(gfx, period);
            weather_ui.draw(gfx, weather);
            scoreboard.draw(gfx, eco, districts[0], emp);
            prompt.draw(gfx, action_prompt);
            minimap.draw(gfx, boss, &jobs);
            world_sim.drawBanner(gfx, ws);
            feed.draw(gfx);
            hints.draw(gfx, tip);
            combat_ui.draw(gfx, cui);
            toast.draw(gfx);
        }
        gfx.endFrame();
    }

    const final_snap = save.captureFull(eco, the_kin, clock, boss, &districts, goal, stash, emp);
    save.writeToDisk(io, final_snap) catch {};
    gfx.shutdown();
    std.debug.print("=== EXIT === Saved | ${d} | {s}\n", .{ eco.treasury, era_mod.name(selected_era) });
}
