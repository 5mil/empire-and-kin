//! Default play-mode presentation — life-sim readable, not debug soup.
const backend = @import("backend.zig");
const scene = @import("scene.zig");
const sim_hud = @import("sim_hud.zig");
const vehicle_hud = @import("vehicle_hud.zig");
const interact = @import("interact.zig");
const mission_ui = @import("mission_ui.zig");
const toast_mod = @import("toast.zig");
const choice_mod = @import("choice.zig");
const combat_ui = @import("combat_ui.zig");
const feed_mod = @import("feed.zig");
const player = @import("../game/player.zig");
const living = @import("../game/living.zig");
const action = @import("../game/action.zig");
const era_mod = @import("../game/era.zig");
const city = @import("../game/city.zig");
const economy = @import("../game/economy.zig");
const goals = @import("../game/goals.zig");
const time = @import("../game/time.zig");
const peds = @import("../game/peds.zig");
const traffic = @import("../game/traffic.zig");
const cop_car = @import("../game/cop_car.zig");

pub fn drawPlay(
    gfx: backend.Backend,
    boss: player.Player,
    period: living.Period,
    car_opt: ?action.Vehicle,
    cam: backend.Camera,
    era: era_mod.Era,
    near_job: bool,
    district: city.District,
    eco: economy.Economy,
    goal: goals.Goal,
    clock: time.Clock,
    action_prompt: []const u8,
    jobs: []const mission_ui.ActiveJob,
    street_peds: *peds.StreetPeds,
    cars: *traffic.Traffic,
    patrol: *cop_car.CopCar,
    toast: *toast_mod.Toast,
    feed: *feed_mod.Feed,
    cui: combat_ui.CombatUI,
) void {
    scene.drawMinimalScene(gfx, boss, period, car_opt, cam, era, near_job);
    interact.drawMarkers(gfx);
    street_peds.draw(gfx);
    cars.draw(gfx);
    patrol.draw(gfx);
    for (jobs) |j| mission_ui.drawMarker(gfx, j, boss);

    const driving = if (car_opt) |c| c.occupied else false;
    if (driving) {
        vehicle_hud.draw(gfx, car_opt.?, 1280, 720);
    } else {
        sim_hud.draw(gfx, boss, district, eco, goal, clock, period, action_prompt, 1280, 720);
    }
    feed.draw(gfx);
    combat_ui.draw(gfx, cui);
    toast.draw(gfx);
}

pub fn drawChoice(
    gfx: backend.Backend,
    boss: player.Player,
    period: living.Period,
    car_opt: ?action.Vehicle,
    cam: backend.Camera,
    era: era_mod.Era,
    street_peds: *peds.StreetPeds,
    cars: *traffic.Traffic,
    choice: choice_mod.Choice,
    toast: *toast_mod.Toast,
) void {
    scene.drawMinimalScene(gfx, boss, period, car_opt, cam, era, false);
    interact.drawMarkers(gfx);
    street_peds.draw(gfx);
    cars.draw(gfx);
    choice_mod.draw(gfx, choice);
    toast.draw(gfx);
}
