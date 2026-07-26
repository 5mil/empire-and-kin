const std = @import("std");
const backend = @import("backend.zig");
const city = @import("../game/city.zig");
const player = @import("../game/player.zig");
const world = @import("../game/world.zig");
const living = @import("../game/living.zig");
const time = @import("../game/time.zig");
const economy = @import("../game/economy.zig");
const goals = @import("../game/goals.zig");
const panel = @import("panel.zig");

pub fn findDistrict(districts: []const city.District, dtype: city.DistrictType) ?city.District {
    for (districts) |d| {
        if (d.dtype == dtype) return d;
    }
    return null;
}

pub fn heatColor(heat: u8) backend.Color {
    if (heat >= 70) return backend.Color.rgb(230, 70, 55);
    if (heat >= 40) return backend.Color.rgb(230, 170, 50);
    return backend.Color.rgb(90, 200, 110);
}

pub fn controlColor(control: u8) backend.Color {
    if (control >= 60) return backend.Color.rgb(110, 190, 255);
    if (control >= 30) return backend.Color.rgb(190, 190, 210);
    return backend.Color.rgb(150, 150, 150);
}

pub fn drawDistrictDebug(
    gfx: backend.Backend,
    p: player.Player,
    districts: []const city.District,
    clock: time.Clock,
    eco: economy.Economy,
    period: living.Period,
    paused: bool,
    police_alert: u8,
    goal: goals.Goal,
) void {
    const white = backend.Color.rgb(240, 240, 230);
    const dim = backend.Color.rgb(165, 165, 155);
    const gold = backend.Color.rgb(255, 215, 120);
    var y: i32 = 8;

    panel.drawFrame(gfx, 6, y, " DISTRICT");
    y += 32;
    gfx.drawText(world.districtName(p.current_district), 12, y, white);
    y += 18;

    if (findDistrict(districts, p.current_district)) |d| {
        var buf: [48]u8 = undefined;
        const heat_line = std.fmt.bufPrint(&buf, "Heat {d}", .{d.heat}) catch "Heat";
        gfx.drawText(heat_line, 12, y, heatColor(d.heat));
        y += 14;
        panel.drawBar(gfx, 12, y, d.heat, 100, '#', '-');
        y += 16;
        const ctrl_line = std.fmt.bufPrint(&buf, "Ctrl {d}", .{d.control}) catch "Ctrl";
        gfx.drawText(ctrl_line, 12, y, controlColor(d.control));
        y += 14;
        panel.drawBar(gfx, 12, y, d.control, 100, '=', '.');
        y += 16;
        const income = city.dailyIncome(d);
        const inc_line = std.fmt.bufPrint(&buf, "Racket ${d}/day", .{income}) catch "";
        gfx.drawText(inc_line, 12, y, dim);
        y += 18;
    }

    var buf2: [72]u8 = undefined;
    const time_line = std.fmt.bufPrint(&buf2, "Day {d} {d:0>2}:{d:0>2} {s}", .{
        clock.day, clock.hour(), clock.minute(),
        if (paused) "PAUSED" else living.periodName(period),
    }) catch "";
    gfx.drawText(time_line, 12, y, white);
    y += 15;

    const cash_line = std.fmt.bufPrint(&buf2, "Treasury ${d}", .{eco.treasury}) catch "";
    gfx.drawText(cash_line, 12, y, backend.Color.rgb(130, 220, 130));
    y += 15;

    const want_line = std.fmt.bufPrint(&buf2, "Wanted {d}/5  Alert {d}", .{ p.wanted_level, police_alert }) catch "";
    gfx.drawText(want_line, 12, y, if (p.wanted_level >= 3) backend.Color.rgb(230, 80, 60) else dim);
    y += 15;

    const pos_line = std.fmt.bufPrint(&buf2, "HP {d}", .{p.health}) catch "";
    gfx.drawText(pos_line, 12, y, dim);
    y += 18;

    panel.drawDivider(gfx, 8, y);
    y += 14;
    const gtitle = std.fmt.bufPrint(&buf2, " GOAL T{d}", .{goal.tier}) catch " GOAL";
    gfx.drawText(gtitle, 12, y, gold);
    y += 16;
    if (goal.complete and goal.tier >= 3) {
        gfx.drawText("ALL TIERS CLEAR", 12, y, backend.Color.rgb(120, 255, 160));
    } else if (findDistrict(districts, p.current_district)) |d| {
        const pc = goals.progressControl(goal, d);
        const pt = goals.progressCash(goal, eco);
        const gline = std.fmt.bufPrint(&buf2, "Ctrl {d}%  Cash {d}%", .{ pc, pt }) catch "";
        gfx.drawText(gline, 12, y, backend.Color.rgb(180, 210, 255));
        y += 14;
        const tline = std.fmt.bufPrint(&buf2, ">={d} ctrl  ${d}", .{ goal.control_target, goal.treasury_target }) catch "";
        gfx.drawText(tline, 12, y, dim);
    }
}
