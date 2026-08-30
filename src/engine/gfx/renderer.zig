//! Frame renderer: lit meshes + ResourceManager GLB cache + HUD + fog.
//! Phase 1: texture_bank tiles as real GL textures.
//! Phase 2: building + prop GLBs on cityscape footprints.
//! Phase 3: character GLBs with facing + scale.
//! Phase 4: vehicle GLBs + spinning/steering wheels.
//! Phase 5: vehicle pitch/roll body lean.

const std = @import("std");
const gl = @import("gl.zig");
const math = @import("math.zig");
const mesh = @import("mesh.zig");
const gpu_mesh = @import("gpu_mesh.zig");
const shaders = @import("shader_select.zig").shaders;
const font = @import("font.zig");
const backend = @import("../backend.zig");
const model_registry = @import("model_registry.zig");
const texture_bank = @import("texture_bank.zig");
const texture_gpu = @import("texture_gpu.zig");

pub var g_models: ?model_registry.Registry = null;

pub const Renderer = struct {
    width: u32 = 1280,
    height: u32 = 720,
    lit_prog: gl.GLuint = 0,
    ui_prog: gl.GLuint = 0,
    box: gpu_mesh.GpuMesh = .{},
    ground: gpu_mesh.GpuMesh = .{},
    ui_vao: gl.GLuint = 0,
    ui_vbo: gl.GLuint = 0,
    cam: backend.Camera = .{},
    view_proj: math.Mat4 = .{},
    light_dir: [3]f32 = .{ 0.35, -1.0, 0.25 },
    ambient: [3]f32 = .{ 0.55, 0.55, 0.58 },
    fog_color: [3]f32 = .{ 0.45, 0.55, 0.65 },
    fog_density: f32 = 0.012,
    tex_bank: texture_gpu.GpuBank = .{},

    pub fn init(self: *Renderer, width: u32, height: u32) !void {
        self.width = if (width == 0) 1280 else width;
        self.height = if (height == 0) 720 else height;
        self.lit_prog = try compileProgram(shaders.lit_vert, shaders.lit_frag);
        self.ui_prog = try compileProgram(shaders.ui_vert, shaders.ui_frag);
        std.debug.print("[Renderer] shaders OK lit={d} ui={d}\n", .{ self.lit_prog, self.ui_prog });

        var box_v: [24]mesh.Vertex = undefined;
        var box_i: [36]u32 = undefined;
        const box_m = mesh.buildBox(1, 1, 1, .{ 1, 1, 1, 1 }, &box_v, &box_i);
        self.box = gpu_mesh.GpuMesh.create(box_m);

        var g_v: [4]mesh.Vertex = undefined;
        var g_i: [6]u32 = undefined;
        const ground_m = mesh.buildGround(1, .{ 1, 1, 1, 1 }, &g_v, &g_i);
        self.ground = gpu_mesh.GpuMesh.create(ground_m);

        self.tex_bank.init();

        gl.glGenVertexArrays(1, &self.ui_vao);
        gl.glGenBuffers(1, &self.ui_vbo);
        gl.glBindVertexArray(self.ui_vao);
        gl.glBindBuffer(gl.ARRAY_BUFFER, self.ui_vbo);
        gl.glBufferData(gl.ARRAY_BUFFER, 200 * 6 * 6 * @sizeOf(f32), null, gl.DYNAMIC_DRAW);
        const stride: gl.GLsizei = 6 * @sizeOf(f32);
        gl.glEnableVertexAttribArray(0);
        gl.glVertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(0));
        gl.glEnableVertexAttribArray(1);
        gl.glVertexAttribPointer(1, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(8));
        gl.glBindVertexArray(0);

        gl.glEnable(gl.DEPTH_TEST);
        gl.glDisable(gl.CULL_FACE);
        gl.glEnable(gl.BLEND);
        gl.glBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
        self.resize(self.width, self.height);

        if (g_models == null) {
            g_models = model_registry.Registry.init(std.heap.page_allocator);
            g_models.?.tryLoadDefaults();
        }
    }

    pub fn shutdown(self: *Renderer) void {
        if (g_models) |*reg| {
            reg.deinit();
            g_models = null;
        }
        self.tex_bank.deinit();
        self.box.destroy();
        self.ground.destroy();
        if (self.ui_vao != 0) gl.glDeleteVertexArrays(1, &self.ui_vao);
        if (self.ui_vbo != 0) gl.glDeleteBuffers(1, &self.ui_vbo);
        if (self.lit_prog != 0) gl.glDeleteProgram(self.lit_prog);
        if (self.ui_prog != 0) gl.glDeleteProgram(self.ui_prog);
        self.* = .{};
    }

    pub fn resize(self: *Renderer, w: u32, h: u32) void {
        if (w == 0 or h == 0) return;
        self.width = w;
        self.height = h;
        gl.glViewport(0, 0, @intCast(w), @intCast(h));
    }

    pub fn beginFrame(self: *Renderer, color: backend.Color) void {
        const r = @as(f32, @floatFromInt(color.r)) / 255.0;
        const g = @as(f32, @floatFromInt(color.g)) / 255.0;
        const b = @as(f32, @floatFromInt(color.b)) / 255.0;
        self.fog_color = .{ r, g, b };
        const lum = 0.2126 * r + 0.7152 * g + 0.0722 * b;
        if (lum < 0.2) {
            self.ambient = .{ 0.28, 0.30, 0.38 };
            self.light_dir = .{ 0.2, -0.7, 0.4 };
            self.fog_density = 0.018;
        } else if (lum < 0.35) {
            self.ambient = .{ 0.42, 0.38, 0.40 };
            self.light_dir = .{ 0.5, -0.85, 0.15 };
            self.fog_density = 0.014;
        } else {
            self.ambient = .{ 0.58, 0.58, 0.60 };
            self.light_dir = .{ 0.35, -1.0, 0.25 };
            self.fog_density = 0.010;
        }
        gl.glClearColor(r, g, b, 1);
        gl.glClear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    }

    pub fn setCamera(self: *Renderer, cam: backend.Camera) void {
        self.cam = cam;
        const aspect = @as(f32, @floatFromInt(self.width)) / @as(f32, @floatFromInt(@max(self.height, 1)));
        const proj = math.Mat4.perspective(math.degToRad(cam.fov_deg), aspect, 0.1, 500.0);
        const view = math.Mat4.lookAt(
            .{ .x = cam.position.x, .y = cam.position.y, .z = cam.position.z },
            .{ .x = cam.target.x, .y = cam.target.y, .z = cam.target.z },
            .{ .x = cam.up.x, .y = cam.up.y, .z = cam.up.z },
        );
        self.view_proj = math.Mat4.mul(proj, view);
    }

    pub fn drawMeshTextured(
        self: *Renderer,
        m: gpu_mesh.GpuMesh,
        model: math.Mat4,
        tint: backend.Color,
        material: ?texture_bank.MaterialId,
    ) void {
        gl.glUseProgram(self.lit_prog);
        const mvp = math.Mat4.mul(self.view_proj, model);
        const loc_mvp = gl.glGetUniformLocation(self.lit_prog, "uMVP");
        const loc_model = gl.glGetUniformLocation(self.lit_prog, "uModel");
        const loc_light = gl.glGetUniformLocation(self.lit_prog, "uLightDir");
        const loc_amb = gl.glGetUniformLocation(self.lit_prog, "uAmbient");
        const loc_tint = gl.glGetUniformLocation(self.lit_prog, "uTint");
        const loc_fog = gl.glGetUniformLocation(self.lit_prog, "uFogColor");
        const loc_dens = gl.glGetUniformLocation(self.lit_prog, "uFogDensity");
        const loc_cam = gl.glGetUniformLocation(self.lit_prog, "uCamPos");
        const loc_use = gl.glGetUniformLocation(self.lit_prog, "uUseTexture");
        const loc_scale = gl.glGetUniformLocation(self.lit_prog, "uUvScale");
        const loc_albedo = gl.glGetUniformLocation(self.lit_prog, "uAlbedo");

        if (material) |mid| {
            if (self.tex_bank.ready) {
                self.tex_bank.bind(mid, gl.TEXTURE0);
                if (loc_use >= 0) gl.glUniform1i(loc_use, 1);
                if (loc_albedo >= 0) gl.glUniform1i(loc_albedo, 0);
                if (loc_scale >= 0) gl.glUniform1f(loc_scale, texture_gpu.uvScale(mid));
            } else {
                if (loc_use >= 0) gl.glUniform1i(loc_use, 0);
            }
        } else {
            if (loc_use >= 0) gl.glUniform1i(loc_use, 0);
        }

        gl.glUniformMatrix4fv(loc_mvp, 1, gl.FALSE, mvp.ptr());
        gl.glUniformMatrix4fv(loc_model, 1, gl.FALSE, model.ptr());
        gl.glUniform3f(loc_light, self.light_dir[0], self.light_dir[1], self.light_dir[2]);
        gl.glUniform3f(loc_amb, self.ambient[0], self.ambient[1], self.ambient[2]);
        gl.glUniform4f(
            loc_tint,
            @as(f32, @floatFromInt(tint.r)) / 255.0,
            @as(f32, @floatFromInt(tint.g)) / 255.0,
            @as(f32, @floatFromInt(tint.b)) / 255.0,
            @as(f32, @floatFromInt(tint.a)) / 255.0,
        );
        gl.glUniform3f(loc_fog, self.fog_color[0], self.fog_color[1], self.fog_color[2]);
        gl.glUniform1f(loc_dens, self.fog_density);
        gl.glUniform3f(loc_cam, self.cam.position.x, self.cam.position.y, self.cam.position.z);
        m.draw();

        if (material != null) {
            texture_gpu.GpuBank.unbind(gl.TEXTURE0);
        }
    }

    pub fn drawMesh(self: *Renderer, m: gpu_mesh.GpuMesh, model: math.Mat4, tint: backend.Color) void {
        self.drawMeshTextured(m, model, tint, null);
    }

    pub fn drawGround(self: *Renderer, size: f32, color: backend.Color) void {
        const model = math.Mat4.scaleVec(.{ .x = size, .y = 1, .z = size });
        self.drawMeshTextured(self.ground, model, color, .asphalt);
    }

    pub fn drawBox(self: *Renderer, pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) void {
        const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
        const s = math.Mat4.scaleVec(.{ .x = w, .y = h, .z = d });
        const mid = materialFromColor(color);
        self.drawMeshTextured(self.box, math.Mat4.mul(t, s), color, mid);
    }

    pub fn drawBuilding(self: *Renderer, pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) bool {
        if (g_models) |*reg| {
            if (reg.building_gpu_at(pos.x, pos.z)) |m| {
                const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
                const s = math.Mat4.scaleVec(.{ .x = w, .y = h, .z = d });
                const mid = materialFromColor(color) orelse .brick;
                self.drawMeshTextured(m, math.Mat4.mul(t, s), color, mid);
                return true;
            }
        }
        return false;
    }

    pub fn drawProp(self: *Renderer, pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) bool {
        if (g_models) |*reg| {
            if (reg.prop_gpu_at(pos.x, pos.z)) |m| {
                const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
                const s = math.Mat4.scaleVec(.{ .x = w, .y = h, .z = d });
                const mid = materialFromColor(color);
                self.drawMeshTextured(m, math.Mat4.mul(t, s), color, mid);
                return true;
            }
        }
        return false;
    }

    /// Phase 3: character mesh with facing + uniform scale.
    pub fn drawCharacter(self: *Renderer, pos: backend.Vec3, facing_yaw: f32, scale: f32, color: backend.Color) bool {
        if (g_models) |*reg| {
            const mesh_opt = reg.character_gpu_at(pos.x, pos.z) orelse reg.boss_gpu();
            if (mesh_opt) |m| {
                const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
                const r = math.Mat4.rotateY(facing_yaw);
                const s = math.Mat4.scaleVec(.{ .x = scale, .y = scale, .z = scale });
                self.drawMesh(m, math.Mat4.mul(t, math.Mat4.mul(r, s)), color);
                return true;
            }
        }
        return false;
    }

    pub fn drawBossMesh(self: *Renderer, pos: backend.Vec3, scale: f32, tint: backend.Color) bool {
        if (g_models) |*reg| {
            if (reg.getBossGpu()) |m| {
                const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
                const s = math.Mat4.scaleVec(.{ .x = scale, .y = scale, .z = scale });
                self.drawMesh(m, math.Mat4.mul(t, s), tint);
                return true;
            }
        }
        return false;
    }

    pub fn drawPlayerProxy(self: *Renderer, pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void {
        if (self.drawCharacter(pos, facing_yaw, 1.0, color)) return;
        const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
        const r = math.Mat4.rotateY(facing_yaw);
        const s = math.Mat4.scaleVec(.{ .x = 0.7, .y = 1.6, .z = 0.7 });
        self.drawMesh(self.box, math.Mat4.mul(t, math.Mat4.mul(r, s)), color);
    }

    /// Phase 4+5: vehicle body mesh + wheels + pitch/roll lean.
    pub fn drawVehicle(
        self: *Renderer,
        pos: backend.Vec3,
        yaw: f32,
        pitch: f32,
        roll: f32,
        wheel_spin: f32,
        steer: f32,
        health: u8,
        color: backend.Color,
    ) bool {
        const dark = 0.35 + 0.65 * (@as(f32, @floatFromInt(health)) / 100.0);
        const tint = backend.Color{
            .r = @intFromFloat(@as(f32, @floatFromInt(color.r)) * dark),
            .g = @intFromFloat(@as(f32, @floatFromInt(color.g)) * dark),
            .b = @intFromFloat(@as(f32, @floatFromInt(color.b)) * dark),
            .a = color.a,
        };
        // T * R_yaw * R_pitch * R_roll
        const world = math.Mat4.mul(
            math.Mat4.mul(
                math.Mat4.mul(
                    math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z }),
                    math.Mat4.rotateY(yaw),
                ),
                math.Mat4.rotateX(pitch),
            ),
            math.Mat4.rotateZ(roll),
        );
        var used = false;
        if (g_models) |*reg| {
            if (reg.vehicle_gpu_at(pos.x, pos.z) orelse reg.vehicle_gpu()) |m| {
                self.drawMesh(m, math.Mat4.mul(world, math.Mat4.scaleVec(.{ .x = 1.15, .y = 1.15, .z = 1.15 })), tint);
                used = true;
            }
        }
        if (!used) {
            self.drawMesh(self.box, math.Mat4.mul(world, math.Mat4.scaleVec(.{ .x = 1.9, .y = 0.9, .z = 3.4 })), tint);
            self.drawMesh(self.box, math.Mat4.mul(world, math.Mat4.mul(math.Mat4.translate(.{ .x = 0, .y = 0.55, .z = -0.25 }), math.Mat4.scaleVec(.{ .x = 1.55, .y = 0.5, .z = 1.5 }))), backend.Color.rgb(25, 35, 50));
        }
        const wc = backend.Color.rgb(18, 18, 20);
        const offs = [_][3]f32{ .{ -0.78, 0.28, 1.05 }, .{ 0.78, 0.28, 1.05 }, .{ -0.78, 0.28, -1.05 }, .{ 0.78, 0.28, -1.05 } };
        var wi: usize = 0;
        while (wi < 4) : (wi += 1) {
            const o = offs[wi];
            const loc = math.Mat4.translate(.{ .x = o[0], .y = o[1], .z = o[2] });
            const st = if (wi < 2) math.Mat4.rotateY(steer) else math.Mat4.identity();
            const sp = math.Mat4.rotateX(wheel_spin);
            const ws = math.Mat4.scaleVec(.{ .x = 0.22, .y = 0.58, .z = 0.58 });
            self.drawMesh(self.box, math.Mat4.mul(world, math.Mat4.mul(loc, math.Mat4.mul(st, math.Mat4.mul(sp, ws)))), wc);
        }
        return used;
    }

    fn flushUi(self: *Renderer, verts: []const f32, count: usize) void {
        if (count == 0) return;
        gl.glDisable(gl.DEPTH_TEST);
        gl.glUseProgram(self.ui_prog);
        const loc = gl.glGetUniformLocation(self.ui_prog, "uScreen");
        gl.glUniform2f(loc, @as(f32, @floatFromInt(self.width)), @as(f32, @floatFromInt(self.height)));
        gl.glBindVertexArray(self.ui_vao);
        gl.glBindBuffer(gl.ARRAY_BUFFER, self.ui_vbo);
        gl.glBufferData(gl.ARRAY_BUFFER, @intCast(count * @sizeOf(f32)), verts.ptr, gl.DYNAMIC_DRAW);
        gl.glDrawArrays(gl.TRIANGLES, 0, @intCast(count / 6));
        gl.glBindVertexArray(0);
        gl.glEnable(gl.DEPTH_TEST);
    }

    fn emitQuad(verts: []f32, base: *usize, x0: f32, y0: f32, x1: f32, y1: f32, r: f32, g: f32, b: f32, a: f32) bool {
        if (base.* + 36 > verts.len) return false;
        const q = [_]f32{
            x0, y0, r, g, b, a,
            x1, y0, r, g, b, a,
            x1, y1, r, g, b, a,
            x0, y0, r, g, b, a,
            x1, y1, r, g, b, a,
            x0, y1, r, g, b, a,
        };
        @memcpy(verts[base.* .. base.* + 36], q[0..]);
        base.* += 36;
        return true;
    }

    pub fn drawText(self: *Renderer, text: []const u8, x: i32, y: i32, color: backend.Color) void {
        const scale: f32 = 2.75;
        const r = @as(f32, @floatFromInt(color.r)) / 255.0;
        const g = @as(f32, @floatFromInt(color.g)) / 255.0;
        const b = @as(f32, @floatFromInt(color.b)) / 255.0;
        const a: f32 = 1.0;

        var vert_buf: [9600]f32 = undefined;
        var vcount: usize = 0;

        const max_chars = @min(text.len, 48);
        const bg_w: f32 = @as(f32, @floatFromInt(max_chars)) * @as(f32, @floatFromInt(font.CELL_W)) * scale + 8.0;
        const bg_h: f32 = @as(f32, @floatFromInt(font.GLYPH_H)) * scale + 6.0;
        const bx: f32 = @as(f32, @floatFromInt(x)) - 3.0;
        const by: f32 = @as(f32, @floatFromInt(y)) - 3.0;
        _ = emitQuad(&vert_buf, &vcount, bx, by, bx + bg_w, by + bg_h, 0.04, 0.05, 0.08, 0.78);

        var cx: f32 = @as(f32, @floatFromInt(x));
        const cy: f32 = @as(f32, @floatFromInt(y));
        var ci: usize = 0;
        while (ci < max_chars) : (ci += 1) {
            const ch = text[ci];
            const rows = font.glyphRows(ch);
            var py: u3 = 0;
            while (true) : (py +%= 1) {
                var px: u3 = 0;
                while (true) : (px +%= 1) {
                    if (font.pixelOn(rows, px, py)) {
                        const x0 = cx + @as(f32, @floatFromInt(px)) * scale;
                        const y0 = cy + @as(f32, @floatFromInt(py)) * scale;
                        if (!emitQuad(&vert_buf, &vcount, x0, y0, x0 + scale, y0 + scale, r, g, b, a)) {
                            self.flushUi(&vert_buf, vcount);
                            vcount = 0;
                            _ = emitQuad(&vert_buf, &vcount, x0, y0, x0 + scale, y0 + scale, r, g, b, a);
                        }
                    }
                    if (px == 7) break;
                }
                if (py == 7) break;
            }
            cx += @as(f32, @floatFromInt(font.CELL_W)) * scale;
        }

        self.flushUi(&vert_buf, vcount);
    }
};

fn materialFromColor(c: backend.Color) ?texture_bank.MaterialId {
    inline for (texture_bank.materials) |m| {
        if (c.r == m.tint_r and c.g == m.tint_g and c.b == m.tint_b) {
            return m.id;
        }
    }

    const rf: f32 = @as(f32, @floatFromInt(c.r));
    const gf: f32 = @as(f32, @floatFromInt(c.g));
    const bf: f32 = @as(f32, @floatFromInt(c.b));
    const lum = (rf + gf + bf) / 3.0;

    if (rf > gf + 8 and rf > bf + 8 and lum > 45 and lum < 120 and rf < 160) {
        if (lum < 70) return .brick_dark;
        return .brick;
    }
    if (@abs(rf - gf) < 12 and @abs(gf - bf) < 18 and lum > 35 and lum < 100) {
        if (lum < 55) return .metal;
        return .concrete;
    }
    if (lum > 95 and lum < 145 and @abs(rf - gf) < 15 and @abs(gf - bf) < 20) {
        return .sidewalk;
    }
    if (lum < 45 and @abs(rf - gf) < 10 and @abs(gf - bf) < 12) {
        return .asphalt;
    }
    if (gf > rf + 15 and gf > bf + 10 and lum > 30 and lum < 120) {
        return .foliage;
    }
    if (rf > 150 and gf > 130 and bf < 100) {
        return .painted_line;
    }
    if (rf > gf and gf > bf and lum > 40 and lum < 90 and rf < 100) {
        return .dirt_alley;
    }
    if (lum > 40 and lum < 130) return .brick;
    return null;
}

fn compileProgram(vs_src: []const u8, fs_src: []const u8) !gl.GLuint {
    const vs = try compileShader(gl.VERTEX_SHADER, vs_src);
    defer gl.glDeleteShader(vs);
    const fs = try compileShader(gl.FRAGMENT_SHADER, fs_src);
    defer gl.glDeleteShader(fs);
    const prog = gl.glCreateProgram();
    gl.glAttachShader(prog, vs);
    gl.glAttachShader(prog, fs);
    gl.glLinkProgram(prog);
    var ok: gl.GLint = 0;
    gl.glGetProgramiv(prog, gl.LINK_STATUS, &ok);
    if (ok == 0) {
        var log_len: gl.GLint = 0;
        gl.glGetProgramiv(prog, gl.INFO_LOG_LENGTH, &log_len);
        var buf: [512]u8 = undefined;
        const n = if (log_len > 0) @min(@as(usize, @intCast(log_len)), buf.len) else 0;
        if (n > 0) gl.glGetProgramInfoLog(prog, @intCast(n), null, &buf);
        std.debug.print("[GL] link error: {s}\n", .{buf[0..n]});
        return error.ShaderLinkFailed;
    }
    return prog;
}

fn compileShader(kind: gl.GLenum, src: []const u8) !gl.GLuint {
    const sh = gl.glCreateShader(kind);
    const ptr: [*]const gl.GLchar = @ptrCast(src.ptr);
    const len: gl.GLint = @intCast(src.len);
    gl.glShaderSource(sh, 1, @ptrCast(&ptr), &len);
    gl.glCompileShader(sh);
    var ok: gl.GLint = 0;
    gl.glGetShaderiv(sh, gl.COMPILE_STATUS, &ok);
    if (ok == 0) {
        var log_len: gl.GLint = 0;
        gl.glGetShaderiv(sh, gl.INFO_LOG_LENGTH, &log_len);
        var buf: [512]u8 = undefined;
        const n = if (log_len > 0) @min(@as(usize, @intCast(log_len)), buf.len) else 0;
        if (n > 0) gl.glGetShaderInfoLog(sh, @intCast(n), null, &buf);
        std.debug.print("[GL] compile error: {s}\n", .{buf[0..n]});
        return error.ShaderCompileFailed;
    }
    return sh;
}
