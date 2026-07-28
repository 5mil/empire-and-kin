const std = @import("std");
const backend = @import("backend.zig");
const era = @import("../game/era.zig");
const input = @import("input.zig");

pub const BootPhase = enum {
    title,
    era_select,
    playing,
};

pub const BootState = struct {
    phase: BootPhase = .title,
    selected_era: era.Era = .nyc_1930s,
    has_save: bool = false,
    load_on_start: bool = false,
    message: []const u8 = "",
};

pub fn draw(gfx: backend.Backend, boot: BootState) void {
    const title_c = backend.Color.rgb(255, 220, 130);
    const white = backend.Color.rgb(245, 245, 240);
    const dim = backend.Color.rgb(160, 165, 175);
    const accent = backend.Color.rgb(90, 220, 160);

    gfx.clear(backend.Color.rgb(14, 16, 28));

    switch (boot.phase) {
        .title => {
            gfx.drawText("EMPIRE & KIN", 420, 160, title_c);
            gfx.drawText("Build a family. Own the block.", 380, 200, dim);
            gfx.drawText("[1]  New Game", 460, 280, white);
            if (boot.has_save) {
                gfx.drawText("[2]  Continue", 460, 320, accent);
            } else {
                gfx.drawText("[2]  Continue (no save)", 420, 320, dim);
            }
            gfx.drawText("WASD move · E interact · Esc empire menu", 360, 420, dim);
            gfx.drawText("F5 save · F9 load · R bribe at safehouse", 370, 450, dim);
        },
        .era_select => {
            gfx.drawText("CHOOSE YOUR ERA", 420, 140, title_c);
            if (boot.selected_era == .nyc_1930s) {
                gfx.drawText("> 1930s New York   [1]", 420, 220, accent);
            } else {
                gfx.drawText("  1930s New York   [1]", 420, 220, white);
            }
            gfx.drawText("Families, rackets, Prohibition fade", 420, 250, dim);
            if (boot.selected_era == .nyc_1980s) {
                gfx.drawText("> 1980s New York   [2]", 420, 310, accent);
            } else {
                gfx.drawText("  1980s New York   [2]", 420, 310, white);
            }
            gfx.drawText("Neon, new crews, harder heat", 420, 340, dim);
            gfx.drawText("[Enter]  Hit the street", 420, 420, white);
        },
        .playing => {},
    }
    if (boot.message.len > 0) {
        gfx.drawText(boot.message, 420, 500, accent);
    }
}

pub fn handle(
    boot: *BootState,
    raw: input.RawKeys,
    edge_1: *input.ButtonEdge,
    edge_2: *input.ButtonEdge,
    edge_enter: *input.ButtonEdge,
) void {
    switch (boot.phase) {
        .title => {
            if (edge_1.pressed(raw.key_1)) {
                boot.phase = .era_select;
                boot.message = "Pick an era";
            }
            if (edge_2.pressed(raw.key_2)) {
                if (boot.has_save) {
                    boot.load_on_start = true;
                    boot.phase = .playing;
                    boot.message = "Loading save...";
                } else {
                    boot.message = "No save - start New Game";
                }
            }
        },
        .era_select => {
            if (edge_1.pressed(raw.key_1)) boot.selected_era = .nyc_1930s;
            if (edge_2.pressed(raw.key_2)) boot.selected_era = .nyc_1980s;
            if (edge_enter.pressed(raw.enter)) {
                boot.phase = .playing;
                boot.message = era.name(boot.selected_era);
            }
        },
        .playing => {},
    }
}
