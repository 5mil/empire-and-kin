const std = @import("std");
const backend = @import("backend.zig");
const city = @import("../game/city.zig");
const player = @import("../game/player.zig");
const world = @import("../game/world.zig");
const living = @import("../game/living.zig");
const time = @import("../game/time.zig");
const economy = @import("../game/economy.zig");

pub fn findDistrict(districts: []const city.District, dtype: city.DistrictType) ?city.District {
    for (districts) |d| {
        if (d.dtype == dtype) return d;
    }
    return null;
}

pub fn heatColor(heat: u8) backend.Color {
    if (heat >= 70) return backend.Color.rgb(220, 60, 50);
    if (heat >= 40) return backend.Color.rgb(220, 160, 40);
    return backend.Color.rgb(80, 180, 100);
}

pub fn controlColor(control: u8) backend.Color {
    if (control >= 60) return backend.Color.rgb(100, 180, 255);
    if (control >= 30) return backend.Color.rgb(180, 180, 200);
    return backend.Color.rgb(140, 140, 140);
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
) void {
    const white = backend.Color.rgb(230, 230, 220);
    const dim = backend.Color.rgb(160, 160, 150);

    gfx.drawText("=== DISTRICT ===", 10, 10, white);
    gfx.drawText(world.districtName(p.current_district), 10, 28, backend.Color.rgb(255, 220, 120));

    if (findDistrict(districts, p.current_district)) |d| {
        var buf: [64]u8 = undefined;

        const heat_line = std.fmt.bufPrint(&buf, "Heat     {d}/100", .{d.heat}) catch "Heat ?";
        gfx.drawText(heat_line, 10, 48, heatColor(d.heat));

        var heat_bar: [22]u8 = undefined;
        heat_bar[0] = '[';
        const heat_fill = @min(20, d.heat / 5);
        var i: usize = 0;
        while (i < 20) : (i += 1) {
            heat_bar[i + 1] = if (i < heat_fill) '#' else '-';
        }
        heat_bar[21] = ']';
        gfx.drawText(heat_bar[0..], 10, 64, heatColor(d.heat));

        const ctrl_line = std.fmt.bufPrint(&buf, "Control  {d}/100", .{d.control}) catch "Control ?";
        gfx.drawText(ctrl_line, 10, 84, controlColor(d.control));

        var ctrl_bar: [22]u8 = undefined;
        ctrl_bar[0] = '[';
        const ctrl_fill = @min(20, d.control / 5);
        i = 0;
        while (i < 20) : (i += 1) {
            ctrl_bar[i + 1] = if (i < ctrl_fill) '=' else '-';
        }
        ctrl_bar[21] = ']';
        gfx.drawText(ctrl_bar[0..], 10, 100, controlColor(d.control));

        const income = city.dailyIncome(d);
        const inc_line = std.fmt.bufPrint(&buf, "Racket $/day  {d}", .{income}) catch "";
        gfx.drawText(inc_line, 10, 120, dim);
    } else {
        gfx.drawText("(no district data)", 10, 48, dim);
    }

    var buf2: [80]u8 = undefined;
    const time_line = std.fmt.bufPrint(&buf2, "Day {d}  {d:0>2}:{d:0>2}  {s}", .{
        clock.day,
        clock.hour(),
        clock.minute(),
        if (paused) "PAUSED" else living.periodName(period),
    }) catch "";
    gfx.drawText(time_line, 10, 150, white);

    const cash_line = std.fmt.bufPrint(&buf2, "Treasury ${d}", .{eco.treasury}) catch "";
    gfx.drawText(cash_line, 10, 168, backend.Color.rgb(120, 200, 120));

    const want_line = std.fmt.bufPrint(&buf2, "Wanted {d}/5   Police alert {d}", .{ p.wanted_level, police_alert }) catch "";
    gfx.drawText(want_line, 10, 186, if (p.wanted_level >= 3) backend.Color.rgb(220, 80, 60) else dim);

    const pos_line = std.fmt.bufPrint(&buf2, "Pos ({d:.0}, {d:.0})  HP {d}", .{ p.x, p.y, p.health }) catch "";
    gfx.drawText(pos_line, 10, 204, dim);
}
