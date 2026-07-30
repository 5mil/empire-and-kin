//! Upload texture_bank procedural tiles as GL textures.
//! Phase 1: real sampler2D albedo on ground/buildings (no external PNG required).

const std = @import("std");
const gl = @import("gl.zig");
const texture_bank = @import("texture_bank.zig");

pub const GpuBank = struct {
    ids: [texture_bank.materials.len]gl.GLuint = [_]gl.GLuint{0} ** texture_bank.materials.len,
    ready: bool = false,

    pub fn init(self: *GpuBank) void {
        if (self.ready) return;
        var pixels: texture_bank.TilePixels = undefined;
        var i: usize = 0;
        while (i < texture_bank.materials.len) : (i += 1) {
            const mid: texture_bank.MaterialId = @enumFromInt(i);
            texture_bank.generateTile(mid, &pixels);
            var tex: gl.GLuint = 0;
            gl.glGenTextures(1, &tex);
            gl.glBindTexture(gl.TEXTURE_2D, tex);
            gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, @intCast(gl.LINEAR_MIPMAP_LINEAR));
            gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, @intCast(gl.LINEAR));
            gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, @intCast(gl.REPEAT));
            gl.glTexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, @intCast(gl.REPEAT));
            gl.glTexImage2D(
                gl.TEXTURE_2D,
                0,
                gl.RGBA,
                texture_bank.TILE,
                texture_bank.TILE,
                0,
                gl.RGBA,
                gl.UNSIGNED_BYTE,
                &pixels,
            );
            gl.glGenerateMipmap(gl.TEXTURE_2D);
            self.ids[i] = tex;
        }
        gl.glBindTexture(gl.TEXTURE_2D, 0);
        self.ready = true;
        std.debug.print("[texture_gpu] uploaded {d} material tiles ({d}x{d})\n", .{
            texture_bank.materials.len,
            texture_bank.TILE,
            texture_bank.TILE,
        });
    }

    pub fn deinit(self: *GpuBank) void {
        var i: usize = 0;
        while (i < self.ids.len) : (i += 1) {
            if (self.ids[i] != 0) {
                gl.glDeleteTextures(1, &self.ids[i]);
                self.ids[i] = 0;
            }
        }
        self.ready = false;
    }

    pub fn bind(self: *const GpuBank, id: texture_bank.MaterialId, unit: gl.GLenum) void {
        if (!self.ready) return;
        const i: usize = @intFromEnum(id);
        if (i >= self.ids.len) return;
        gl.glActiveTexture(unit);
        gl.glBindTexture(gl.TEXTURE_2D, self.ids[i]);
    }

    pub fn unbind(unit: gl.GLenum) void {
        gl.glActiveTexture(unit);
        gl.glBindTexture(gl.TEXTURE_2D, 0);
    }
};

pub fn uvScale(id: texture_bank.MaterialId) f32 {
    return switch (id) {
        .asphalt, .wet_asphalt => 0.35,
        .sidewalk, .concrete => 0.45,
        .cobble, .dirt_alley => 0.55,
        .brick, .brick_dark, .stucco => 0.25,
        .painted_line => 1.0,
        else => 0.4,
    };
}
