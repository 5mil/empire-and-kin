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
const stash_mod = @import("game/stash.zig");
const lookout_mod = @import("game/lookout.zig");
const rival_mod = @import("game/rival.zig");
const news = @import("game/news.zig");
const events = @import("game/events.zig");
const respect = @import("game/respect.zig");
const weather_mod = @import("game/weather.zig");
const loan_mod = @import("game/loan.zig");
const day_cycle = @import("game/day_cycle.zig");
const crew_talk = @import("game/crew_talk.zig");
const tipjar = @import("game/tipjar.zig");
const inventory_mod = @import("game/inventory.zig");
const ambush = @import("game/ambush.zig");
const cop_car = @import("game/cop_car.zig");
const radio = @import("game/radio.zig");
const turf = @import("game/turf.zig");
const bartender = @import("game/bartender.zig");
const medkit = @import("game/medkit.zig");
const reputation_tick = @import("game/reputation_tick.zig");
const milestone = @import("game/milestone.zig");
const death = @import("game/death.zig");
const heat_spike = @import("game/heat_spike.zig");
const payday = @import("game/payday.zig");
const intimidate = @import("game/intimidate.zig");
const scene = @import("engine/scene.zig");
const input = @import("engine/input.zig");
const controller = @import("engine/controller.zig");
const empire_ui = @import("engine/empire_ui.zig");
const wanted_ui = @import("engine/wanted_ui.zig");
const mission_ui = @import("engine/mission_ui.zig");
const boot_mod = @import("engine/boot.zig");
const world_sim = @import("engine/world_sim.zig");
const hints = @import("engine/hints.zig");
const combat_ui = @import("engine/combat_ui.zig");
const toast_mod = @import("engine/toast.zig");
const camera = @import("engine/camera.zig");
const choice_mod = @import("engine/choice.zig");
const feed_mod = @import("engine/feed.zig");
const interact = @import("engine/interact.zig");
const gameover = @import("engine/gameover.zig");
const play_draw = @import("engine/play_draw.zig");

const gfx_mod = @import("engine/gfx_select.zig").BackendMod;

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
        mission_ui.spawnJob(405, .hit, 26.0, 18.0),
    };
    jobs[0].duration = balance.BOOTLEG_DURATION;
    jobs[1].duration = balance.PROTECTION_DURATION;
    jobs[2].duration = balance.SMUGGLING_DURATION;
    jobs[3].duration = balance.PROTECTION_DURATION;
    jobs[4].duration = 5.0;

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
    var patrol_car: cop_car.CopCar = .{};
    var marks: milestone.Flags = .{};
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
    var ambush_cd: f64 = balance.AMBUSH_CHECK_INTERVAL;
    var radio_cd: f64 = 55.0;
    var turf_cd: f64 = 90.0;
    var day_count: u32 = 0;

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
        if (ambush_cd > 0) ambush_cd -= dt;
        if (radio_cd > 0) radio_cd -= dt;
        if (turf_cd > 0) turf_cd -= dt;

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
                if (milestone.markJob(&marks)) |m| feed.push(m);
                if (goals.check(&goal, districts[0], eco)) {
                    toast.show("GOAL TIER UP", 3.5);
                    feed.push("Goal tier advanced");
                    if (milestone.markGoal(&marks)) |m| feed.push(m);
                }
            }
            const car_ptr0 = garage.activeVehicle(&fleet);
            const car_opt0: ?action.Vehicle = if (car_ptr0) |v| v.* else null;
            const cam0 = follow.update(boss, false, dt);
            play_draw.drawChoice(gfx, boss, living.currentPeriod(clock), car_opt0, cam0, selected_era, &street_peds, &cars, choice, &toast);
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
        const downed = death.isDown(boss);
        if (!downed) _ = ctrl.tick(raw, &boss, if (in_car) 0 else dt);

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
            if (keys.order_enforce and menu.panel == .crew) {
                if (intimidate.press(&the_kin, &districts[0], &emp)) {
                    toast.show("Enforcers on the street", 2.5);
                    feed.push("Intimidation");
                } else {
                    const msg = turf.resolve(&districts[0], &emp, &the_kin, frame_seed);
                    toast.show(msg, 2.5);
                    feed.push(msg);
                }
            }
            empire_ui.handleMenu(keys, &emp, &the_kin, &portfolio, &fleet, districts[0..], &menu, boss.x, boss.y, &eco);
            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, living.currentPeriod(clock), car_opt, cam, selected_era, near_any);
            empire_ui.draw(gfx, emp, the_kin, portfolio, fleet, &districts, menu);
        } else if (downed) {
            if (edge_interact.pressed(raw.e)) {
                death.hospital(&boss, &eco);
                toast.show("Hospital $400", 2.5);
                feed.push("Woke in hospital");
            }
            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            scene.drawMinimalScene(gfx, boss, living.currentPeriod(clock), car_opt, cam, selected_era, false);
            gameover.draw(gfx, true);
            toast.draw(gfx);
        } else {
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
                if (!used) {
                    const res = interact.tryE(&boss, &eco, &districts[0], &inv, &stash, &rival, &emp, &the_kin, frame_seed, &safehouse_cd);
                    if (res.handled) {
                        toast.show(res.msg, 2.0);
                        feed.push(res.msg);
                        used = true;
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
            if (edge_r.pressed(raw.r)) {
                if (scene.nearSafehouse(boss)) {
                    if (eco.treasury >= balance.BRIBE_COST and boss.wanted_level > 0) {
                        eco.treasury -= balance.BRIBE_COST;
                        boss.wanted_level = 0;
                        toast.show("Bribed cops", 2.5);
                        feed.push("Bribe paid");
                        if (milestone.markBribe(&marks)) |m| feed.push(m);
                    }
                } else if (bartender.near(boss)) {
                    if (bartender.buyTip(&eco, &districts[0])) {
                        toast.show("Bartender tip", 2.0);
                        feed.push("Bought street tip");
                    }
                } else if (medkit.use(&inv, &boss)) {
                    toast.show("Used medkit", 1.5);
                    feed.push("Medkit used");
                }
            }
            if (edge_f.pressed(raw.f) and !cui.encounter.active) {
                const res = interact.tryEmptyStash(boss, &stash, &eco);
                if (res.handled) {
                    toast.show(res.msg, 2.0);
                    feed.push(res.msg);
                }
            }

            const action_prompt = interact.promptNear(boss);

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
            patrol_car.tick(dt);
            rival_mod.tick(&rival, &districts[0], clock.elapsed);
            lookout_mod.suppressAlert(lookout, &police);

            if (day_cycle.crossed(&dayw, clock)) {
                loan_mod.tickDay(&loan, &eco);
                reputation_tick.daily(&emp, districts[0]);
                day_count += 1;
                if (day_count % 7 == 0) {
                    payday.weekly(&the_kin, &eco);
                    feed.push("Crew payday");
                }
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
            if (ambush_cd <= 0) {
                ambush_cd = balance.AMBUSH_CHECK_INTERVAL;
                if (ambush.roll(frame_seed, districts[0].heat, boss.wanted_level)) {
                    ambush.apply(&boss, &districts[0]);
                    toast.showUrgent("AMBUSH!", 2.5);
                    feed.push("Ambushed");
                }
            }
            if (radio_cd <= 0) {
                radio_cd = 60.0;
                if (districts[0].heat > 30) feed.push(radio.chatter(frame_seed));
            }
            if (turf_cd <= 0) {
                turf_cd = 120.0;
                if (rival.pressure > 40) {
                    const msg = turf.resolve(&districts[0], &emp, &the_kin, frame_seed);
                    feed.push(msg);
                }
            }
            if (heat_spike.maybe(&districts[0], boss, frame_seed)) {
                toast.showUrgent("Heat spike!", 2.0);
                feed.push("Police heat spike");
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
                if (milestone.markGoal(&marks)) |m| feed.push(m);
            }

            const car_opt: ?action.Vehicle = if (car_ptr) |v| v.* else null;
            play_draw.drawPlay(
                gfx,
                boss,
                period,
                car_opt,
                cam,
                selected_era,
                near_any,
                districts[0],
                eco,
                goal,
                clock,
                action_prompt,
                &jobs,
                &street_peds,
                &cars,
                &patrol_car,
                &toast,
                &feed,
                cui,
            );
        }
        gfx.endFrame();
    }

    const final_snap = save.captureFull(eco, the_kin, clock, boss, &districts, goal, stash, emp);
    save.writeToDisk(io, final_snap) catch {};
    gfx.shutdown();
    std.debug.print("=== EXIT === Saved | ${d} | {s}\n", .{ eco.treasury, era_mod.name(selected_era) });
}
