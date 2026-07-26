//! Frame renderer: camera, ground/box/player/vehicle, UI rect proxies.

const std = @import("std");
const gl = @import("gl.zig");
const math = @import("math.zig");
const mesh = @import("mesh.zig");
const gpu_mesh = @import("gpu_mesh.zig");
const shaders = @import("shaders.zig");
const backend = @import("../backend.zig");

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

        gl.glGenVertexArrays(1, &self.ui_vao);
        gl.glGenBuffers(1, &self.ui_vbo);
        gl.glBindVertexArray(self.ui_vao);
        gl.glBindBuffer(gl.ARRAY_BUFFER, self.ui_vbo);
        gl.glBufferData(gl.ARRAY_BUFFER, 6 * 6 * @sizeOf(f32), null, gl.DYNAMIC_DRAW);
        const stride: gl.GLsizei = 6 * @sizeOf(f32);
        gl.glEnableVertexAttribArray(0);
        gl.glVertexAttribPointer(0, 2, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(0));
        gl.glEnableVertexAttribArray(1);
        gl.glVertexAttribPointer(1, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(8));
        gl.glBindVertexArray(0);

        gl.glEnable(gl.DEPTH_TEST);
        // Cull off until winding is verified on all primitives
        gl.glDisable(gl.CULL_FACE);
        gl.glEnable(gl.BLEND);
        gl.glBlendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
        self.resize(self.width, self.height);

        // Sanity clear so first frame is never undefined black
        gl.glClearColor(0.15, 0.18, 0.28, 1);
        gl.glClear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    }

    pub fn shutdown(self: *Renderer) void {
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
        _ = self;
        const r = @as(f32, @floatFromInt(color.r)) / 255.0;
        const g = @as(f32, @floatFromInt(color.g)) / 255.0;
        const b = @as(f32, @floatFromInt(color.b)) / 255.0;
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

    fn drawMesh(self: *Renderer, m: gpu_mesh.GpuMesh, model: math.Mat4, tint: backend.Color) void {
        gl.glUseProgram(self.lit_prog);
        const mvp = math.Mat4.mul(self.view_proj, model);
        const loc_mvp = gl.glGetUniformLocation(self.lit_prog, "uMVP");
        const loc_model = gl.glGetUniformLocation(self.lit_prog, "uModel");
        const loc_light = gl.glGetUniformLocation(self.lit_prog, "uLightDir");
        const loc_amb = gl.glGetUniformLocation(self.lit_prog, "uAmbient");
        const loc_tint = gl.glGetUniformLocation(self.lit_prog, "uTint");
        gl.glUniformMatrix4fv(loc_mvp, 1, gl.FALSE, mvp.ptr());
        gl.glUniformMatrix4fv(loc_model, 1, gl.FALSE, model.ptr());
        gl.glUniform3f(loc_light, 0.35, -1.0, 0.25);
        // Strong ambient so lit geometry is never pure black
        gl.glUniform3f(loc_amb, 0.55, 0.55, 0.58);
        gl.glUniform4f(
            loc_tint,
            @as(f32, @floatFromInt(tint.r)) / 255.0,
            @as(f32, @floatFromInt(tint.g)) / 255.0,
            @as(f32, @floatFromInt(tint.b)) / 255.0,
            @as(f32, @floatFromInt(tint.a)) / 255.0,
        );
        m.draw();
    }

    pub fn drawGround(self: *Renderer, size: f32, color: backend.Color) void {
        const model = math.Mat4.scaleVec(.{ .x = size, .y = 1, .z = size });
        self.drawMesh(self.ground, model, color);
    }

    pub fn drawBox(self: *Renderer, pos: backend.Vec3, w: f32, h: f32, d: f32, color: backend.Color) void {
        const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
        const s = math.Mat4.scaleVec(.{ .x = w, .y = h, .z = d });
        self.drawMesh(self.box, math.Mat4.mul(t, s), color);
    }

    pub fn drawPlayerProxy(self: *Renderer, pos: backend.Vec3, facing_yaw: f32, color: backend.Color) void {
        const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
        const r = math.Mat4.rotateY(facing_yaw);
        const s = math.Mat4.scaleVec(.{ .x = 0.8, .y = 1.8, .z = 0.8 });
        self.drawMesh(self.box, math.Mat4.mul(t, math.Mat4.mul(r, s)), color);
    }

    pub fn drawVehicle(self: *Renderer, pos: backend.Vec3, yaw: f32, occupied: bool, color: backend.Color) void {
        _ = occupied;
        const t = math.Mat4.translate(.{ .x = pos.x, .y = pos.y, .z = pos.z });
        const r = math.Mat4.rotateY(yaw);
        const s = math.Mat4.scaleVec(.{ .x = 2.2, .y = 1.2, .z = 4.0 });
        self.drawMesh(self.box, math.Mat4.mul(t, math.Mat4.mul(r, s)), color);
    }

    /// Thick colored bars for HUD text (bitmap font = B1).
    pub fn drawTextProxy(self: *Renderer, x: i32, y: i32, len: usize, color: backend.Color) void {
        const w: f32 = @floatFromInt(@max(@min(len, 48) * 8, 24));
        const h: f32 = 16;
        const x0: f32 = @floatFromInt(x);
        const y0: f32 = @floatFromInt(y);
        const r = @as(f32, @floatFromInt(color.r)) / 255.0;
        const g = @as(f32, @floatFromInt(color.g)) / 255.0;
        const b = @as(f32, @floatFromInt(color.b)) / 255.0;
        const a: f32 = 1.0;
        var verts = [_]f32{
            x0,     y0,     r, g, b, a,
            x0 + w, y0,     r, g, b, a,
            x0 + w, y0 + h, r, g, b, a,
            x0,     y0,     r, g, b, a,
            x0 + w, y0 + h, r, g, b, a,
            x0,     y0 + h, r, g, b, a,
        };
        gl.glDisable(gl.DEPTH_TEST);
        gl.glUseProgram(self.ui_prog);
        const loc = gl.glGetUniformLocation(self.ui_prog, "uScreen");
        gl.glUniform2f(loc, @floatFromInt(self.width), @floatFromInt(self.height));
        gl.glBindVertexArray(self.ui_vao);
        gl.glBindBuffer(gl.ARRAY_BUFFER, self.ui_vbo);
        gl.glBufferData(gl.ARRAY_BUFFER, @intCast(verts.len * @sizeOf(f32)), &verts, gl.DYNAMIC_DRAW);
        gl.glDrawArrays(gl.TRIANGLES, 0, 6);
        gl.glBindVertexArray(0);
        gl.glEnable(gl.DEPTH_TEST);
    }
};

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
        const n = @min(@as(usize, @intCast(log_len)), buf.len);
        gl.glGetProgramInfoLog(prog, @intCast(n), null, &buf);
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
        const n = @min(@as(usize, @intCast(log_len)), buf.len);
        gl.glGetShaderInfoLog(sh, @intCast(n), null, &buf);
        std.debug.print("[GL] compile error: {s}\n", .{buf[0..n]});
        return error.ShaderCompileFailed;
    }
    return sh;
}
