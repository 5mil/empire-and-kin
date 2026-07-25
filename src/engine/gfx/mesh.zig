//! CPU-side mesh data and unit primitives for GPU upload.

const math = @import("math.zig");

pub const Vertex = extern struct {
    px: f32,
    py: f32,
    pz: f32,
    nx: f32,
    ny: f32,
    nz: f32,
    r: f32,
    g: f32,
    b: f32,
    a: f32,

    pub fn init(p: math.Vec3, n: math.Vec3, col: [4]f32) Vertex {
        return .{
            .px = p.x, .py = p.y, .pz = p.z,
            .nx = n.x, .ny = n.y, .nz = n.z,
            .r = col[0], .g = col[1], .b = col[2], .a = col[3],
        };
    }
};

pub const Mesh = struct {
    vertices: []const Vertex,
    indices: []const u32,
};

pub fn buildBox(sx: f32, sy: f32, sz: f32, col: [4]f32, verts: *[24]Vertex, inds: *[36]u32) Mesh {
    const hx = sx * 0.5;
    const hy = sy * 0.5;
    const hz = sz * 0.5;
    const faces = [_]struct { n: math.Vec3, p: [4]math.Vec3 }{
        .{ .n = .{ .x = 0, .y = 0, .z = 1 }, .p = .{ .{ .x = -hx, .y = -hy, .z = hz }, .{ .x = hx, .y = -hy, .z = hz }, .{ .x = hx, .y = hy, .z = hz }, .{ .x = -hx, .y = hy, .z = hz } } },
        .{ .n = .{ .x = 0, .y = 0, .z = -1 }, .p = .{ .{ .x = hx, .y = -hy, .z = -hz }, .{ .x = -hx, .y = -hy, .z = -hz }, .{ .x = -hx, .y = hy, .z = -hz }, .{ .x = hx, .y = hy, .z = -hz } } },
        .{ .n = .{ .x = 0, .y = 1, .z = 0 }, .p = .{ .{ .x = -hx, .y = hy, .z = hz }, .{ .x = hx, .y = hy, .z = hz }, .{ .x = hx, .y = hy, .z = -hz }, .{ .x = -hx, .y = hy, .z = -hz } } },
        .{ .n = .{ .x = 0, .y = -1, .z = 0 }, .p = .{ .{ .x = -hx, .y = -hy, .z = -hz }, .{ .x = hx, .y = -hy, .z = -hz }, .{ .x = hx, .y = -hy, .z = hz }, .{ .x = -hx, .y = -hy, .z = hz } } },
        .{ .n = .{ .x = 1, .y = 0, .z = 0 }, .p = .{ .{ .x = hx, .y = -hy, .z = hz }, .{ .x = hx, .y = -hy, .z = -hz }, .{ .x = hx, .y = hy, .z = -hz }, .{ .x = hx, .y = hy, .z = hz } } },
        .{ .n = .{ .x = -1, .y = 0, .z = 0 }, .p = .{ .{ .x = -hx, .y = -hy, .z = -hz }, .{ .x = -hx, .y = -hy, .z = hz }, .{ .x = -hx, .y = hy, .z = hz }, .{ .x = -hx, .y = hy, .z = -hz } } },
    };
    var vi: usize = 0;
    var ii: usize = 0;
    for (faces) |face| {
        const base: u32 = @intCast(vi);
        var q: usize = 0;
        while (q < 4) : (q += 1) {
            verts[vi] = Vertex.init(face.p[q], face.n, col);
            vi += 1;
        }
        inds[ii] = base; inds[ii + 1] = base + 1; inds[ii + 2] = base + 2;
        inds[ii + 3] = base; inds[ii + 4] = base + 2; inds[ii + 5] = base + 3;
        ii += 6;
    }
    return .{ .vertices = verts[0..24], .indices = inds[0..36] };
}

pub fn buildGround(size: f32, col: [4]f32, verts: *[4]Vertex, inds: *[6]u32) Mesh {
    const h = size * 0.5;
    const n = math.Vec3{ .x = 0, .y = 1, .z = 0 };
    verts[0] = Vertex.init(.{ .x = -h, .y = 0, .z = -h }, n, col);
    verts[1] = Vertex.init(.{ .x = h, .y = 0, .z = -h }, n, col);
    verts[2] = Vertex.init(.{ .x = h, .y = 0, .z = h }, n, col);
    verts[3] = Vertex.init(.{ .x = -h, .y = 0, .z = h }, n, col);
    inds.* = .{ 0, 1, 2, 0, 2, 3 };
    return .{ .vertices = verts[0..4], .indices = inds[0..6] };
}
