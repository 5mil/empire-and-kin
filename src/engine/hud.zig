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
    var y: i32 = 8;

    gfx.drawText(world.districtName(p.current_district), 10, y, backend.Color.rgb(255, 220, 120));
    y += 18;

    if (findDistrict(districts, p.current_district)) |d| {
        var buf: [48]u8 = undefined;
        const heat_line = std.fmt.bufPrint(&buf, "Heat {d}/100", .{d.heat}) catch "Heat?";
        gfx.drawText(heat_line, 10, y, heatColor(d.heat));
        y += 16;
        const ctrl_line = std.fmt.bufPrint(&buf, "Control {d}/100", .{d.control}) catch "Ctrl?";
        gfx.drawText(ctrl_line, 10, y, controlColor(d.control));
        y += 16;
        const income = city.dailyIncome(d);
        const inc_line = std.fmt.bufPrint(&buf, "Racket ${d}/day", .{income}) catch "";
        gfx.drawText(inc_line, 10, y, dim);
        y += 18;
    }

    var buf2: [64]u8 = undefined;
    const time_line = std.fmt.bufPrint(&buf2, "Day {d}  {d:0>2}:{d:0>2}  {s}", .{
        clock.day,
        clock.hour(),
        clock.minute(),
        if (paused) "PAUSED" else living.periodName(period),
    }) catch "";
    gfx.drawText(time_line, 10, y, white);
    y += 16;

    const cash_line = std.fmt.bufPrint(&buf2, "Treasury ${d}", .{eco.treasury}) catch "";
    gfx.drawText(cash_line, 10, y, backend.Color.rgb(120, 200, 120));
    y += 16;

    const want_line = std.fmt.bufPrint(&buf2, "Wanted {d}/5  Alert {d}", .{ p.wanted_level, police_alert }) catch "";
    gfx.drawText(want_line, 10, y, if (p.wanted_level >= 3) backend.Color.rgb(220, 80, 60) else dim);
    y += 16;

    const pos_line = std.fmt.bufPrint(&buf2, "({d:.0},{d:.0})  HP {d}", .{ p.x, p.y, p.health }) catch "";
    gfx.drawText(pos_line, 10, y, dim);
}
