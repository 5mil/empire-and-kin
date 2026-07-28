//! Life-sim HUD — panel cards + needs-style bars (Sims readability, not EA assets).

const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const city = @import("../game/city.zig");
const economy = @import("../game/economy.zig");
const goals = @import("../game/goals.zig");
const living = @import("../game/living.zig");
const time = @import("../game/time.zig");
const world = @import("../game/world.zig");

fn bar(gfx: backend.Backend, x: i32, y: i32, w: i32, fill: u8, max: u8, good: bool) void {
    // Text approximation of a needs bar: [####----]
    var buf: [24]u8 = undefined;
    const n = @min(@as(usize, 10), @as(usize, @intCast(if (max == 0) 0 else @as(u32, fill) * 10 / max)));
    var i: usize = 0;
    buf[i] = '[';
    i += 1;
    var k: usize = 0;
    while (k < 10) : (k += 1) {
        buf[i] = if (k < n) '#' else '-';
        i += 1;
    }
    buf[i] = ']';
    i += 1;
    const col = if (!good) backend.Color.rgb(230, 90, 80) else if (n >= 7) backend.Color.rgb(90, 210, 130) else backend.Color.rgb(230, 200, 90);
    gfx.drawText(buf[0..i], x, y, col);
    _ = w;
}

pub fn draw(
    gfx: backend.Backend,
    p: player.Player,
    d: city.District,
    eco: economy.Economy,
    goal: goals.Goal,
    clock: time.Clock,
    period: living.Period,
    prompt: []const u8,
    screen_w: i32,
    screen_h: i32,
) void {
    const white = backend.Color.rgb(250, 248, 240);
    const gold = backend.Color.rgb(255, 210, 90);
    const green = backend.Color.rgb(90, 210, 130);
    const dim = backend.Color.rgb(160, 168, 180);
    const danger = backend.Color.rgb(230, 80, 70);
    const label = backend.Color.rgb(190, 200, 220);

    var buf: [72]u8 = undefined;

    // ── Left card: identity + clock + cash ──
    gfx.drawText("EMPIRE & KIN", 20, 16, label);
    gfx.drawText(world.districtName(p.current_district), 20, 40, white);
    const clock_s = std.fmt.bufPrint(&buf, "Day {d}  {d:0>2}:{d:0>2}  {s}", .{
        clock.day, clock.hour(), clock.minute(), living.periodName(period),
    }) catch "";
    gfx.drawText(clock_s, 20, 64, dim);
    const cash_s = std.fmt.bufPrint(&buf, "${d}", .{eco.treasury}) catch "$";
    gfx.drawText(cash_s, 20, 90, gold);

    // ── Needs-style status (Health / Heat inverted / Control) ──
    gfx.drawText("NEEDS", 20, 122, label);
    gfx.drawText("Health", 20, 146, dim);
    bar(gfx, 100, 146, 120, p.health, 100, p.health >= 40);
    // Heat: high is bad — invert for bar feel
    const calm: u8 = if (d.heat >= 100) 0 else @intCast(100 - d.heat);
    gfx.drawText("Calm", 20, 170, dim);
    bar(gfx, 100, 170, 120, calm, 100, d.heat < 50);
    gfx.drawText("Control", 20, 194, dim);
    bar(gfx, 100, 194, 120, d.control, 100, d.control >= 40);
    if (p.wanted_level > 0) {
        const w_s = std.fmt.bufPrint(&buf, "Wanted {d}/5", .{p.wanted_level}) catch "!";
        gfx.drawText(w_s, 20, 218, danger);
    }

    // ── Right aspiration / goal card ──
    const gx: i32 = if (screen_w > 1000) screen_w - 320 else 920;
    gfx.drawText("ASPIRATION", gx, 16, gold);
    const tier_s = std.fmt.bufPrint(&buf, "Tier {d}", .{goal.tier}) catch "T";
    gfx.drawText(tier_s, gx, 40, white);
    const need_s = std.fmt.bufPrint(&buf, "Control >= {d}", .{goal.control_target}) catch "";
    gfx.drawText(need_s, gx, 64, dim);
    const cash_g = std.fmt.bufPrint(&buf, "Cash >= ${d}", .{goal.treasury_target}) catch "";
    gfx.drawText(cash_g, gx, 88, dim);
    const pc = goals.progressControl(goal, d);
    const pt = goals.progressCash(goal, eco);
    gfx.drawText("Progress", gx, 118, label);
    bar(gfx, gx, 142, 120, @intCast(@min(pc, 100)), 100, pc >= 50);
    const prog = std.fmt.bufPrint(&buf, "Ctrl {d}%  Cash {d}%", .{ pc, pt }) catch "";
    gfx.drawText(prog, gx, 166, green);

    // ── Bottom interaction (pie-menu substitute) ──
    if (prompt.len > 0) {
        const py = screen_h - 56;
        gfx.drawText(prompt, @divTrunc(screen_w, 2) - 120, py, backend.Color.rgb(100, 255, 190));
    }

    gfx.drawText("WASD move   E act   Esc menu   F5 save", 20, screen_h - 28, backend.Color.rgb(110, 115, 130));
}
