//! CPU skinning — apply joint matrices to skinned mesh (works on PC GL + GLES path).
//! GPU skinning shader is a later optimization; this is the operational baseline.

const std = @import("std");
const mesh = @import("mesh.zig");
const math = @import("math.zig");

pub const MAX_JOINTS: usize = 64;

/// joint_mats: length joint_count * 16, column-major (glTF style).
pub fn skinVertices(
    src: []const mesh.Vertex,
    influences: []const mesh.SkinInfluence,
    inverse_binds: []const f32,
    joint_mats: []const f32,
    joint_count: u32,
    out: []mesh.Vertex,
) void {
    const jc = @min(joint_count, MAX_JOINTS);
    var i: usize = 0;
    while (i < src.len and i < out.len and i < influences.len) : (i += 1) {
        const v = src[i];
        const inf = influences[i];
        var px: f32 = 0;
        var py: f32 = 0;
        var pz: f32 = 0;
        var nx: f32 = 0;
        var ny: f32 = 0;
        var nz: f32 = 0;
        var wsum: f32 = 0;
        var k: usize = 0;
        while (k < 4) : (k += 1) {
            const w = inf.weights[k];
            if (w <= 0.0001) continue;
            const j: usize = @min(@as(usize, inf.joints[k]), jc -| 1);
            // skin matrix = joint * inverseBind
            var sm: [16]f32 = undefined;
            mulMat4(joint_mats[j * 16 ..][0..16], inverse_binds[j * 16 ..][0..16], &sm);
            const p = transformPoint(sm, v.px, v.py, v.pz);
            const n = transformDir(sm, v.nx, v.ny, v.nz);
            px += p[0] * w;
            py += p[1] * w;
            pz += p[2] * w;
            nx += n[0] * w;
            ny += n[1] * w;
            nz += n[2] * w;
            wsum += w;
        }
        if (wsum < 0.0001) {
            out[i] = v;
        } else {
            const inv = 1.0 / wsum;
            out[i] = .{
                .px = px * inv,
                .py = py * inv,
                .pz = pz * inv,
                .nx = nx * inv,
                .ny = ny * inv,
                .nz = nz * inv,
                .r = v.r,
                .g = v.g,
                .b = v.b,
                .a = v.a,
            };
        }
    }
}

/// Identity joint palette (bind pose).
pub fn identityJoints(joint_count: u32, out: []f32) void {
    const jc = @min(@as(usize, joint_count), MAX_JOINTS);
    var j: usize = 0;
    while (j < jc) : (j += 1) {
        const o = j * 16;
        if (o + 16 > out.len) break;
        @memset(out[o .. o + 16], 0);
        out[o + 0] = 1;
        out[o + 5] = 1;
        out[o + 10] = 1;
        out[o + 15] = 1;
    }
}

fn mulMat4(a: *const [16]f32, b: *const [16]f32, out: *[16]f32) void {
    var c: usize = 0;
    while (c < 4) : (c += 1) {
        var r: usize = 0;
        while (r < 4) : (r += 1) {
            out[c * 4 + r] =
                a[0 * 4 + r] * b[c * 4 + 0] +
                a[1 * 4 + r] * b[c * 4 + 1] +
                a[2 * 4 + r] * b[c * 4 + 2] +
                a[3 * 4 + r] * b[c * 4 + 3];
        }
    }
}

fn transformPoint(m: [16]f32, x: f32, y: f32, z: f32) [3]f32 {
    return .{
        m[0] * x + m[4] * y + m[8] * z + m[12],
        m[1] * x + m[5] * y + m[9] * z + m[13],
        m[2] * x + m[6] * y + m[10] * z + m[14],
    };
}

fn transformDir(m: [16]f32, x: f32, y: f32, z: f32) [3]f32 {
    return .{
        m[0] * x + m[4] * y + m[8] * z,
        m[1] * x + m[5] * y + m[9] * z,
        m[2] * x + m[6] * y + m[10] * z,
    };
}
