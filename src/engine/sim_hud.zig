//! Life-sim style HUD — few large signals, not a wall of debug text.
//! Inspired by Sims plumbob / needs panel readability (not asset parity).

const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const city = @import("../game/city.zig");
const economy = @import("../game/economy.zig");
const goals = @import("../game/goals.zig");
const living = @import("../game/living.zig");
const time = @import("../game/time.zig");
const world = @import("../game/world.zig");

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
    _ = screen_w;
    const white = backend.Color.rgb(250, 248, 240);
    const gold = backend.Color.rgb(255, 210, 90);
    const green = backend.Color.rgb(90, 210, 130);
    const dim = backend.Color.rgb(170, 175, 185);
    const danger = backend.Color.rgb(230, 80, 70);
    const panel = backend.Color.rgb(200, 210, 230);

    // ── Top bar: district + clock + cash (one line each, left) ──
    gfx.drawText(world.districtName(p.current_district), 24, 20, white);

    var buf: [64]u8 = undefined;
    const clock_s = std.fmt.bufPrint(&buf, "Day {d}  {d:0>2}:{d:0>2}  {s}", .{
        clock.day, clock.hour(), clock.minute(), living.periodName(period),
    }) catch "";
    gfx.drawText(clock_s, 24, 42, dim);

    const cash_s = std.fmt.bufPrint(&buf, "${d}", .{eco.treasury}) catch "$";
    gfx.drawText(cash_s, 24, 66, gold);

    // ── Mood / status row (Sims-like needs strip) ──
    const mood_y: i32 = 96;
    gfx.drawText("STATUS", 24, mood_y, panel);
    const hp_s = std.fmt.bufPrint(&buf, "Health {d}", .{p.health}) catch "HP";
    gfx.drawText(hp_s, 24, mood_y + 22, if (p.health < 40) danger else green);
    const heat_s = std.fmt.bufPrint(&buf, "Heat {d}", .{d.heat}) catch "Heat";
    gfx.drawText(heat_s, 24, mood_y + 44, if (d.heat >= 50) danger else dim);
    const ctrl_s = std.fmt.bufPrint(&buf, "Control {d}", .{d.control}) catch "Ctrl";
    gfx.drawText(ctrl_s, 24, mood_y + 66, if (d.control >= 50) green else dim);
    if (p.wanted_level > 0) {
        const w_s = std.fmt.bufPrint(&buf, "Wanted {d}/5", .{p.wanted_level}) catch "!";
        gfx.drawText(w_s, 24, mood_y + 88, danger);
    }

    // ── Goal card (right side, like aspiration panel) ──
    const gx: i32 = 920;
    gfx.drawText("GOAL", gx, 20, gold);
    const tier_s = std.fmt.bufPrint(&buf, "Tier {d}", .{goal.tier}) catch "T";
    gfx.drawText(tier_s, gx, 42, white);
    const need_s = std.fmt.bufPrint(&buf, "Need {d} ctrl", .{goal.control_target}) catch "";
    gfx.drawText(need_s, gx, 64, dim);
    const cash_g = std.fmt.bufPrint(&buf, "Need ${d}", .{goal.treasury_target}) catch "";
    gfx.drawText(cash_g, gx, 86, dim);
    const pc = goals.progressControl(goal, d);
    const pt = goals.progressCash(goal, eco);
    const prog = std.fmt.bufPrint(&buf, "{d}%  /  {d}%", .{ pc, pt }) catch "";
    gfx.drawText(prog, gx, 110, green);

    // ── Bottom center: interaction prompt (always visible when non-empty) ──
    if (prompt.len > 0) {
        const py = screen_h - 48;
        gfx.drawText(prompt, 400, py, backend.Color.rgb(120, 255, 200));
    }

    // ── Bottom left tip ──
    gfx.drawText("WASD move   E act   Esc menu   F5 save", 24, screen_h - 28, backend.Color.rgb(120, 125, 140));
}
