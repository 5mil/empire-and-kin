const std = @import("std");
const backend = @import("backend.zig");
const empire = @import("../game/empire.zig");
const crew = @import("../game/crew.zig");
const city = @import("../game/city.zig");
const world = @import("../game/world.zig");
const properties = @import("../game/properties.zig");
const garage = @import("../game/garage.zig");
const action = @import("../game/action.zig");

pub const Panel = enum { rackets, crew, properties, vehicles };

pub const EmpireMenu = struct {
    panel: Panel = .rackets,
    selected_racket: u8 = 0,
    selected_member: u8 = 1,
    selected_property: u8 = 0,
    selected_vehicle: u8 = 0,
    last_msg: []const u8 = "",
    slow_world_tick: bool = true,
};

pub const MenuKeys = struct {
    order_collect: bool = false,
    order_rest: bool = false,
    order_enforce: bool = false,
    order_scout: bool = false,
    order_guard: bool = false,
    panel_next: bool = false,
    panel_prev: bool = false,
    nav_prev: bool = false,
    nav_next: bool = false,
    primary: bool = false,
    secondary: bool = false,
    tertiary: bool = false,
};

pub fn panelName(p: Panel) []const u8 {
    return switch (p) {
        .rackets => "Rackets",
        .crew => "Crew",
        .properties => "Properties",
        .vehicles => "Vehicles",
    };
}

pub fn draw(
    gfx: backend.Backend,
    emp: empire.Empire,
    c: crew.Crew,
    pf: properties.Portfolio,
    fleet: garage.Fleet,
    districts: []const city.District,
    menu: EmpireMenu,
) void {
    const title = backend.Color.rgb(255, 210, 120);
    const white = backend.Color.rgb(230, 230, 220);
    const dim = backend.Color.rgb(150, 150, 145);
    const accent = backend.Color.rgb(120, 200, 160);
    const focus_col = backend.Color.rgb(255, 180, 80);
    const danger = backend.Color.rgb(220, 90, 70);
    var buf: [128]u8 = undefined;
    var y: i32 = 12;

    gfx.drawText("PAUSED - EMPIRE", 280, y, title);
    y += 20;
    const tabs = std.fmt.bufPrint(&buf, "[{s}]  Tab=next panel", .{panelName(menu.panel)}) catch "";
    gfx.drawText(tabs, 280, y, focus_col);
    y += 18;
    const hdr = std.fmt.bufPrint(&buf, "Inf {d}  Rep {d}  Take ${d}/d  Upkeep ${d}", .{
        emp.influence, emp.reputation, empire.totalRacketIncome(emp), properties.totalUpkeep(pf),
    }) catch "";
    gfx.drawText(hdr, 280, y, accent);
    y += 22;

    switch (menu.panel) {
        .rackets => y = drawRackets(gfx, emp, c, menu, y, white, dim, title),
        .crew => y = drawCrew(gfx, c, menu, y, white, dim, title),
        .properties => y = drawProperties(gfx, pf, menu, y, white, dim, title, danger),
        .vehicles => y = drawVehicles(gfx, fleet, menu, y, white, dim, title, danger, accent),
    }
    y += 12;
    gfx.drawText(helpForPanel(menu.panel), 280, y, dim);
    y += 16;
    if (menu.last_msg.len > 0) gfx.drawText(menu.last_msg, 280, y, white);
    _ = districts;
}

fn helpForPanel(p: Panel) []const u8 {
    return switch (p) {
        .rackets => "Q/E select  Enter assign  1-5 orders",
        .crew => "Q/E select  1 Collect 2 Rest 3 Enforce 4 Scout 5 Guard",
        .properties => "Q/E select  Enter upgrade  R repair",
        .vehicles => "Q/E select  Enter deploy  R repair  F store",
    };
}

fn drawRackets(gfx: backend.Backend, emp: empire.Empire, c: crew.Crew, menu: EmpireMenu, y0: i32, white: backend.Color, dim: backend.Color, title: backend.Color) i32 {
    var y = y0;
    var buf: [112]u8 = undefined;
    gfx.drawText("-- Rackets --", 280, y, title);
    y += 16;
    var i: u8 = 0;
    while (i < emp.racket_count) : (i += 1) {
        const r = emp.rackets[i];
        const who = if (r.assigned_member) |m| c.members[m].name else "unassigned";
        const line = std.fmt.bufPrint(&buf, "{s}{d} {s} Lv{d} +h{d} {s}", .{ if (i == menu.selected_racket) ">" else " ", i, empire.racketName(r.rtype), r.level, r.heat_gen, who }) catch "";
        gfx.drawText(line, 280, y, if (i == menu.selected_racket) white else dim);
        y += 15;
    }
    return y;
}

fn drawCrew(gfx: backend.Backend, c: crew.Crew, menu: EmpireMenu, y0: i32, white: backend.Color, dim: backend.Color, title: backend.Color) i32 {
    var y = y0;
    var buf: [112]u8 = undefined;
    gfx.drawText("-- Crew --", 280, y, title);
    y += 16;
    var i: u8 = 0;
    while (i < c.count) : (i += 1) {
        const m = c.members[i];
        const line = std.fmt.bufPrint(&buf, "{s}{d} {s} loy{d} fat{d}", .{ if (i == menu.selected_member) ">" else " ", i, m.name, m.loyalty, m.fatigue }) catch "";
        gfx.drawText(line, 280, y, if (i == menu.selected_member) white else dim);
        y += 15;
    }
    return y;
}

fn drawProperties(gfx: backend.Backend, pf: properties.Portfolio, menu: EmpireMenu, y0: i32, white: backend.Color, dim: backend.Color, title: backend.Color, danger: backend.Color) i32 {
    var y = y0;
    var buf: [128]u8 = undefined;
    gfx.drawText("-- Properties --", 280, y, title);
    y += 16;
    var i: u8 = 0;
    while (i < pf.count) : (i += 1) {
        const p = pf.items[i];
        const line = std.fmt.bufPrint(&buf, "{s}{d} {s} Lv{d} cond{d} ${d}", .{ if (i == menu.selected_property) ">" else " ", i, p.name, p.level, p.condition, p.monthly_upkeep }) catch "";
        gfx.drawText(line, 280, y, if (i == menu.selected_property) white else if (p.condition < 40) danger else dim);
        y += 15;
        if (i == menu.selected_property) {
            const det = std.fmt.bufPrint(&buf, "  {s} cap {d}", .{ world.districtName(p.district), p.capacity }) catch "";
            gfx.drawText(det, 280, y, dim);
            y += 14;
        }
    }
    return y;
}

fn drawVehicles(gfx: backend.Backend, fleet: garage.Fleet, menu: EmpireMenu, y0: i32, white: backend.Color, dim: backend.Color, title: backend.Color, danger: backend.Color, accent: backend.Color) i32 {
    var y = y0;
    var buf: [128]u8 = undefined;
    gfx.drawText("-- Vehicles --", 280, y, title);
    y += 16;
    var i: u8 = 0;
    while (i < fleet.count) : (i += 1) {
        const ov = fleet.slots[i];
        const active = if (fleet.active_idx) |a| a == i else false;
        const line = std.fmt.bufPrint(&buf, "{s}{d} {s} HP{d}{s}{s}", .{ if (i == menu.selected_vehicle) ">" else " ", i, ov.label, ov.vehicle.health, if (ov.stored) " STORED" else "", if (active) " ACTIVE" else "" }) catch "";
        gfx.drawText(line, 280, y, if (i == menu.selected_vehicle) white else if (ov.vehicle.health < 40) danger else if (active) accent else dim);
        y += 15;
    }
    return y;
}

pub fn handleMenu(keys: MenuKeys, emp: *empire.Empire, c: *crew.Crew, pf: *properties.Portfolio, fleet: *garage.Fleet, districts: []city.District, menu: *EmpireMenu, player_x: f32, player_y: f32) void {
    if (keys.panel_next) {
        menu.panel = switch (menu.panel) { .rackets => .crew, .crew => .properties, .properties => .vehicles, .vehicles => .rackets };
        menu.last_msg = panelName(menu.panel);
    }
    if (keys.panel_prev) {
        menu.panel = switch (menu.panel) { .rackets => .vehicles, .crew => .rackets, .properties => .crew, .vehicles => .properties };
        menu.last_msg = panelName(menu.panel);
    }
    if (keys.nav_prev or keys.nav_next) {
        const dir: i32 = if (keys.nav_next) 1 else -1;
        switch (menu.panel) {
            .rackets => menu.selected_racket = wrap(menu.selected_racket, emp.racket_count, dir),
            .crew => menu.selected_member = wrap(menu.selected_member, c.count, dir),
            .properties => menu.selected_property = wrap(menu.selected_property, pf.count, dir),
            .vehicles => menu.selected_vehicle = wrap(menu.selected_vehicle, fleet.count, dir),
        }
    }
    switch (menu.panel) {
        .rackets => {
            if (keys.primary) {
                menu.last_msg = if (empire.assignCrewToRacket(emp, menu.selected_racket, menu.selected_member)) "Crew assigned" else "Assign failed";
            }
        },
        .crew => {
            if (districts.len > 0) {
                const d = &districts[0];
                const mid = menu.selected_member;
                if (keys.order_collect) { _ = empire.issueOrder(c, mid, .collect, emp, d); menu.last_msg = "Order: Collect"; }
                else if (keys.order_rest) { _ = empire.issueOrder(c, mid, .rest, emp, d); menu.last_msg = "Order: Rest"; }
                else if (keys.order_enforce) { _ = empire.issueOrder(c, mid, .enforce, emp, d); menu.last_msg = "Order: Enforce"; }
                else if (keys.order_scout) { _ = empire.issueOrder(c, mid, .scout, emp, d); menu.last_msg = "Order: Scout"; }
                else if (keys.order_guard) { _ = empire.issueOrder(c, mid, .guard, emp, d); menu.last_msg = "Order: Guard"; }
            }
        },
        .properties => {
            if (keys.primary) menu.last_msg = if (properties.upgradeProperty(pf, menu.selected_property)) "Property upgraded" else "Cannot upgrade";
            if (keys.secondary) menu.last_msg = if (properties.repairProperty(pf, menu.selected_property)) "Property repaired" else "Already full";
        },
        .vehicles => {
            if (keys.primary) {
                if (garage.deployVehicle(fleet, menu.selected_vehicle, player_x + 2, player_y)) {
                    _ = garage.setActive(fleet, menu.selected_vehicle);
                    menu.last_msg = "Deployed & active";
                } else menu.last_msg = "Deploy failed";
            }
            if (keys.secondary) menu.last_msg = if (garage.repairVehicle(fleet, menu.selected_vehicle)) "Vehicle repaired" else "Already full HP";
            if (keys.tertiary) {
                const idx = menu.selected_vehicle;
                if (idx < fleet.count) {
                    if (fleet.slots[idx].stored) {
                        _ = garage.deployVehicle(fleet, idx, player_x + 2, player_y);
                        menu.last_msg = "Retrieved";
                    } else if (garage.storeVehicle(fleet, idx)) menu.last_msg = "Stored" else menu.last_msg = "Cannot store";
                }
            }
        },
    }
}

fn wrap(cur: u8, count: u8, dir: i32) u8 {
    if (count == 0) return 0;
    var next: i32 = @as(i32, @intCast(cur)) + dir;
    if (next < 0) next = count - 1;
    if (next >= count) next = 0;
    return @intCast(next);
}
