const std = @import("std");
const events = @import("../game/events.zig");
const rivals = @import("../game/rivals.zig");
const era = @import("../game/era.zig");
const city = @import("../game/city.zig");
const crew = @import("../game/crew.zig");
const economy = @import("../game/economy.zig");
const player = @import("../game/player.zig");
const wanted_ui = @import("wanted_ui.zig");
const backend = @import("backend.zig");

pub const WorldSim = struct {
    event_timer: f64 = 0,
    event_interval: f64 = 25.0,
    rival_timer: f64 = 0,
    rival_interval: f64 = 18.0,
    last_event_title: []const u8 = "",
    last_event_desc: []const u8 = "",
    banner_ttl: f64 = 0,
    rival_count: u8 = 0,
    rival_list: [rivals.MAX_RIVALS]rivals.RivalOrg = undefined,
    seed: u32 = 1,
};

pub fn init(ws: *WorldSim, e: era.Era) void {
    ws.* = .{};
    ws.rival_count = rivals.getRivalsForEra(e, &ws.rival_list);
    ws.seed = 42;
}

pub fn tick(
    ws: *WorldSim,
    dt: f64,
    districts: []city.District,
    c: *crew.Crew,
    eco: *economy.Economy,
    p: *player.Player,
) void {
    if (ws.banner_ttl > 0) ws.banner_ttl -= dt;

    ws.event_timer += dt;
    if (ws.event_timer >= ws.event_interval) {
        ws.event_timer = 0;
        ws.seed +%= 1;
        const ev = events.rollEvent(ws.seed);
        applyEvent(ws, ev, districts, c, eco, p);
    }

    ws.rival_timer += dt;
    if (ws.rival_timer >= ws.rival_interval) {
        ws.rival_timer = 0;
        applyRivalPressure(ws, districts);
    }
}

fn applyEvent(
    ws: *WorldSim,
    ev: events.Event,
    districts: []city.District,
    c: *crew.Crew,
    eco: *economy.Economy,
    p: *player.Player,
) void {
    ws.last_event_title = ev.title;
    ws.last_event_desc = ev.description;
    ws.banner_ttl = 6.0;

    if (districts.len > 0) {
        if (ev.heat_change > 0) {
            districts[0].heat = @min(100, districts[0].heat + @as(u8, @intCast(ev.heat_change)));
        } else if (ev.heat_change < 0) {
            const drop: u8 = @intCast(-ev.heat_change);
            if (districts[0].heat > drop) districts[0].heat -= drop else districts[0].heat = 0;
        }
    }

    if (ev.cash_change >= 0) {
        eco.treasury += @as(u32, @intCast(ev.cash_change));
    } else {
        const loss: u32 = @intCast(-ev.cash_change);
        if (eco.treasury > loss) eco.treasury -= loss else eco.treasury = 0;
    }

    if (ev.morale_change >= 0) {
        c.morale = @min(100, c.morale + @as(u8, @intCast(ev.morale_change)));
    } else {
        const mdrop: u8 = @intCast(-ev.morale_change);
        if (c.morale > mdrop) c.morale -= mdrop else c.morale = 0;
    }

    if (ev.etype == .police_raid) {
        wanted_ui.addWanted(p, 1);
    }
}

fn applyRivalPressure(ws: *WorldSim, districts: []city.District) void {
    if (districts.len == 0 or ws.rival_count == 0) return;
    var best: u8 = 0;
    var i: u8 = 0;
    while (i < ws.rival_count) : (i += 1) {
        if (ws.rival_list[i].hostility > ws.rival_list[best].hostility) best = i;
    }
    const r = ws.rival_list[best];
    const chip: u8 = 1 + r.hostility / 40;
    if (districts[0].control > chip) {
        districts[0].control -= chip;
    } else {
        districts[0].control = 0;
    }
    ws.last_event_title = r.name;
    ws.last_event_desc = "Rival pressure - control slips";
    ws.banner_ttl = 5.0;
}

pub fn drawBanner(gfx: backend.Backend, ws: WorldSim) void {
    if (ws.banner_ttl <= 0) return;
    const col = backend.Color.rgb(255, 200, 100);
    gfx.drawText(ws.last_event_title, 280, 560, col);
    gfx.drawText(ws.last_event_desc, 280, 578, backend.Color.rgb(200, 180, 140));
}
