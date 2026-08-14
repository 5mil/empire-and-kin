//! Column-major 4x4 math for GPU transforms.
const std = @import("std");

pub const Vec3 = struct {
    x: f32 = 0, y: f32 = 0, z: f32 = 0,
    pub fn add(a: Vec3, b: Vec3) Vec3 { return .{ .x = a.x + b.x, .y = a.y + b.y, .z = a.z + b.z }; }
    pub fn sub(a: Vec3, b: Vec3) Vec3 { return .{ .x = a.x - b.x, .y = a.y - b.y, .z = a.z - b.z }; }
    pub fn scale(a: Vec3, s: f32) Vec3 { return .{ .x = a.x * s, .y = a.y * s, .z = a.z * s }; }
    pub fn dot(a: Vec3, b: Vec3) f32 { return a.x * b.x + a.y * b.y + a.z * b.z; }
    pub fn cross(a: Vec3, b: Vec3) Vec3 {
        return .{ .x = a.y * b.z - a.z * b.y, .y = a.z * b.x - a.x * b.z, .z = a.x * b.y - a.y * b.x };
    }
    pub fn length(a: Vec3) f32 { return @sqrt(dot(a, a)); }
    pub fn normalize(a: Vec3) Vec3 {
        const len = length(a);
        if (len < 1e-8) return .{};
        return scale(a, 1.0 / len);
    }
};

pub const Mat4 = struct {
    m: [16]f32 = identity_data,
    const identity_data = [_]f32{ 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 };
    pub fn identity() Mat4 { return .{}; }
    pub fn mul(a: Mat4, b: Mat4) Mat4 {
        var r: Mat4 = .{ .m = undefined };
        var col: usize = 0;
        while (col < 4) : (col += 1) {
            var row: usize = 0;
            while (row < 4) : (row += 1) {
                var s: f32 = 0;
                var k: usize = 0;
                while (k < 4) : (k += 1) s += a.m[k * 4 + row] * b.m[col * 4 + k];
                r.m[col * 4 + row] = s;
            }
        }
        return r;
    }
    pub fn translate(t: Vec3) Mat4 {
        var r = identity();
        r.m[12] = t.x; r.m[13] = t.y; r.m[14] = t.z;
        return r;
    }
    pub fn scaleVec(s: Vec3) Mat4 {
        var r = identity();
        r.m[0] = s.x; r.m[5] = s.y; r.m[10] = s.z;
        return r;
    }
    pub fn rotateY(yaw: f32) Mat4 {
        const c = @cos(yaw); const s = @sin(yaw);
        var r = identity();
        r.m[0] = c; r.m[2] = -s; r.m[8] = s; r.m[10] = c;
        return r;
    }
    pub fn rotateX(pitch: f32) Mat4 {
        const c = @cos(pitch); const s = @sin(pitch);
        var r = identity();
        r.m[5] = c; r.m[6] = s; r.m[9] = -s; r.m[10] = c;
        return r;
    }
    pub fn lookAt(eye: Vec3, target: Vec3, up: Vec3) Mat4 {
        const f = Vec3.normalize(Vec3.sub(target, eye));
        const s = Vec3.normalize(Vec3.cross(f, up));
        const u = Vec3.cross(s, f);
        var r = identity();
        r.m[0] = s.x; r.m[4] = s.y; r.m[8] = s.z;
        r.m[1] = u.x; r.m[5] = u.y; r.m[9] = u.z;
        r.m[2] = -f.x; r.m[6] = -f.y; r.m[10] = -f.z;
        r.m[12] = -Vec3.dot(s, eye); r.m[13] = -Vec3.dot(u, eye); r.m[14] = Vec3.dot(f, eye);
        return r;
    }
    pub fn perspective(fovy: f32, aspect: f32, near: f32, far: f32) Mat4 {
        const t = @tan(fovy * 0.5);
        var r: Mat4 = .{ .m = [_]f32{0} ** 16 };
        r.m[0] = 1.0 / (aspect * t); r.m[5] = 1.0 / t;
        r.m[10] = -(far + near) / (far - near); r.m[11] = -1.0;
        r.m[14] = -(2.0 * far * near) / (far - near);
        return r;
    }
    pub fn ptr(self: *const Mat4) [*]const f32 { return @ptrCast(&self.m); }
};

pub fn degToRad(d: f32) f32 { return d * (std.math.pi / 180.0); }
