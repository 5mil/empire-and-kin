//! Character map panel — C to toggle. Full multi-dimension sheet.
const std = @import("std");
const backend = @import("backend.zig");
const character_map = @import("../game/character_map.zig");
const input = @import("input.zig");

pub const CharUI = struct {
    open: bool = false,
};

pub fn handle(ui: *CharUI, raw: input.RawKeys, edge_c: *input.ButtonEdge) void {
    if (edge_c.pressed(raw.c)) ui.open = !ui.open;
}

pub fn draw(gfx: backend.Backend, ui: CharUI, cm: character_map.CharacterMap) void {
    if (!ui.open) return;

    gfx.drawText("======== CHARACTER MAP ========", 40, 70, backend.Color.rgb(220, 200, 140));
    var line: i32 = 90;

    var buf: [112]u8 = undefined;

    const id = std.fmt.bufPrint(&buf, "{s}  \"{s}\"  age {d}  (b.{d})", .{ cm.legal_name, cm.street_name, cm.age, cm.era_born }) catch "?";
    gfx.drawText(id, 40, line, backend.Color.rgb(230, 230, 220));
    line += 18;

    const app = std.fmt.bufPrint(&buf, "body {s}  hair {s}  face {s}  suit {s}", .{
        @tagName(cm.body),
        @tagName(cm.hair),
        @tagName(cm.facial),
        @tagName(cm.suit),
    }) catch "?";
    gfx.drawText(app, 40, line, backend.Color.rgb(180, 180, 170));
    line += 16;

    const app2 = std.fmt.bufPrint(&buf, "hat {s}  tone {s}  scar {}  jewelry {}  trait {s}", .{
        @tagName(cm.hat),
        @tagName(cm.tone),
        cm.scar_cheek,
        cm.jewelry,
        @tagName(cm.trait),
    }) catch "?";
    gfx.drawText(app2, 40, line, backend.Color.rgb(170, 165, 155));
    line += 22;

    gfx.drawText("-- skills --", 40, line, backend.Color.rgb(160, 150, 120));
    line += 16;
    drawBar(gfx, "muscle", cm.muscle, 40, line);
    line += 15;
    drawBar(gfx, "street", cm.street_smarts, 40, line);
    line += 15;
    drawBar(gfx, "charm", cm.charm, 40, line);
    line += 15;
    drawBar(gfx, "stealth", cm.stealth, 40, line);
    line += 15;
    drawBar(gfx, "driving", cm.driving, 40, line);
    line += 15;
    drawBar(gfx, "business", cm.business, 40, line);
    line += 15;
    drawBar(gfx, "marksman", cm.marksmanship, 40, line);
    line += 15;
    drawBar(gfx, "intimidate", cm.intimidation, 40, line);
    line += 20;

    gfx.drawText("-- needs --", 40, line, backend.Color.rgb(160, 150, 120));
    line += 16;
    drawBar(gfx, "energy", cm.energy, 40, line);
    line += 15;
    drawBar(gfx, "stress", cm.stress, 40, line);
    line += 15;
    drawBar(gfx, "hunger", cm.hunger, 40, line);
    line += 15;
    drawBar(gfx, "hygiene", cm.hygiene, 40, line);
    line += 15;
    drawBar(gfx, "morale", cm.morale, 40, line);
    line += 15;
    drawBar(gfx, "vice", cm.addiction, 40, line);
    line += 20;

    const rep = std.fmt.bufPrint(&buf, "family {d}  civilian {d}  underworld {d}  heat bias {d}", .{
        cm.family_standing,
        cm.civilian_rep,
        cm.underworld_rep,
        cm.police_heat_bias,
    }) catch "?";
    gfx.drawText(rep, 40, line, backend.Color.rgb(180, 170, 160));
    line += 18;

    const mul = std.fmt.bufPrint(&buf, "speed x{d:.2}  combat x{d:.2}  stealth x{d:.2}", .{
        cm.moveSpeedMul(),
        cm.combatMul(),
        cm.stealthMul(),
    }) catch "?";
    gfx.drawText(mul, 40, line, backend.Color.rgb(140, 190, 150));
    line += 22;
    gfx.drawText("[C] close character map", 40, line, backend.Color.rgb(120, 120, 110));
}

fn drawBar(gfx: backend.Backend, label: []const u8, value: u8, x: i32, y: i32) void {
    var buf: [48]u8 = undefined;
    const n = @min(value / 5, 20);
    var bar: [20]u8 = undefined;
    var i: usize = 0;
    while (i < 20) : (i += 1) bar[i] = if (i < n) '#' else '-';
    const txt = std.fmt.bufPrint(&buf, "{s: <10} {s} {d}", .{ label, bar[0..], value }) catch label;
    gfx.drawText(txt, x, y, backend.Color.rgb(200, 200, 190));
}
