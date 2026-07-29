//! glTF 2.0 / GLB loader — meshes + skin influences (CPU skin path).
//! Targets CC0 packs: Quaternius, Kenney, KayKit exported as GLB.

const std = @import("std");
const mesh = @import("mesh.zig");

pub const LoadError = error{
    InvalidGlb,
    UnsupportedFeature,
    OutOfMemory,
    MissingAttribute,
    BadAccessor,
};

pub const LoadedModel = struct {
    vertices: []mesh.Vertex,
    indices: []u32,
    influences: ?[]mesh.SkinInfluence = null,
    inverse_binds: ?[]f32 = null,
    joint_count: u32 = 0,
    allocator: std.mem.Allocator,

    pub fn deinit(self: *LoadedModel) void {
        self.allocator.free(self.vertices);
        self.allocator.free(self.indices);
        if (self.influences) |inf| self.allocator.free(inf);
        if (self.inverse_binds) |ibm| self.allocator.free(ibm);
        self.* = undefined;
    }

    pub fn asSkinned(self: LoadedModel) mesh.SkinnedMesh {
        return .{
            .vertices = self.vertices,
            .indices = self.indices,
            .influences = self.influences,
            .inverse_binds = self.inverse_binds,
            .joint_count = self.joint_count,
        };
    }
};

pub fn loadGlbPath(allocator: std.mem.Allocator, path: []const u8) LoadError!LoadedModel {
    const file = std.fs.cwd().openFile(path, .{}) catch return error.InvalidGlb;
    defer file.close();
    const bytes = file.readToEndAlloc(allocator, 64 * 1024 * 1024) catch return error.OutOfMemory;
    defer allocator.free(bytes);
    return loadGlbBytes(allocator, bytes);
}

pub fn loadGlbBytes(allocator: std.mem.Allocator, bytes: []const u8) LoadError!LoadedModel {
    if (bytes.len < 12) return error.InvalidGlb;
    const magic = std.mem.readInt(u32, bytes[0..4], .little);
    if (magic != 0x46546C67) return error.InvalidGlb; // glTF
    const version = std.mem.readInt(u32, bytes[4..8], .little);
    if (version != 2) return error.UnsupportedFeature;

    var offset: usize = 12;
    var json_slice: []const u8 = &[_]u8{};
    var bin_slice: []const u8 = &[_]u8{};

    while (offset + 8 <= bytes.len) {
        const chunk_len = std.mem.readInt(u32, bytes[offset .. offset + 4][0..4], .little);
        const chunk_type = std.mem.readInt(u32, bytes[offset + 4 .. offset + 8][0..4], .little);
        offset += 8;
        if (offset + chunk_len > bytes.len) return error.InvalidGlb;
        const data = bytes[offset .. offset + chunk_len];
        offset += chunk_len;
        // 0x4E4F534A = JSON, 0x004E4942 = BIN
        if (chunk_type == 0x4E4F534A) json_slice = data;
        if (chunk_type == 0x004E4942) bin_slice = data;
    }
    if (json_slice.len == 0) return error.InvalidGlb;

    const parsed = std.json.parseFromSlice(std.json.Value, allocator, json_slice, .{}) catch return error.InvalidGlb;
    defer parsed.deinit();
    const root = parsed.value;
    if (root != .object) return error.InvalidGlb;

    const accessors = root.object.get("accessors") orelse return error.MissingAttribute;
    const buffer_views = root.object.get("bufferViews") orelse return error.MissingAttribute;
    if (accessors != .array or buffer_views != .array) return error.InvalidGlb;

    // First mesh / first primitive
    const meshes = root.object.get("meshes") orelse return error.MissingAttribute;
    if (meshes != .array or meshes.array.items.len == 0) return error.MissingAttribute;
    const mesh0 = meshes.array.items[0];
    if (mesh0 != .object) return error.InvalidGlb;
    const prims = mesh0.object.get("primitives") orelse return error.MissingAttribute;
    if (prims != .array or prims.array.items.len == 0) return error.MissingAttribute;
    const prim = prims.array.items[0];
    if (prim != .object) return error.InvalidGlb;

    const attrs = prim.object.get("attributes") orelse return error.MissingAttribute;
    if (attrs != .object) return error.InvalidGlb;

    const pos_acc_i = attrIndex(attrs.object, "POSITION") orelse return error.MissingAttribute;
    const pos = try readAccessorVec3(allocator, accessors.array, buffer_views.array, bin_slice, pos_acc_i);
    defer allocator.free(pos);

    var norms: [][3]f32 = &[_][3]f32{};
    var norms_owned = false;
    if (attrIndex(attrs.object, "NORMAL")) |n_i| {
        norms = try readAccessorVec3(allocator, accessors.array, buffer_views.array, bin_slice, n_i);
        norms_owned = true;
    }
    defer if (norms_owned) allocator.free(norms);

    const vert_count = pos.len;
    var vertices = try allocator.alloc(mesh.Vertex, vert_count);
    errdefer allocator.free(vertices);
    var vi: usize = 0;
    while (vi < vert_count) : (vi += 1) {
        const n = if (vi < norms.len) norms[vi] else [3]f32{ 0, 1, 0 };
        vertices[vi] = .{
            .px = pos[vi][0],
            .py = pos[vi][1],
            .pz = pos[vi][2],
            .nx = n[0],
            .ny = n[1],
            .nz = n[2],
            .r = 0.85,
            .g = 0.75,
            .b = 0.65,
            .a = 1.0,
        };
    }

    var indices: []u32 = undefined;
    if (prim.object.get("indices")) |idx_val| {
        const idx_i: usize = @intCast(idx_val.integer);
        indices = try readAccessorIndices(allocator, accessors.array, buffer_views.array, bin_slice, idx_i);
    } else {
        indices = try allocator.alloc(u32, vert_count);
        var i: u32 = 0;
        while (i < vert_count) : (i += 1) indices[i] = i;
    }
    errdefer allocator.free(indices);

    var influences: ?[]mesh.SkinInfluence = null;
    if (attrIndex(attrs.object, "JOINTS_0")) |j_i| {
        if (attrIndex(attrs.object, "WEIGHTS_0")) |w_i| {
            influences = try readSkinInfluences(allocator, accessors.array, buffer_views.array, bin_slice, j_i, w_i, vert_count);
        }
    }

    var inverse_binds: ?[]f32 = null;
    var joint_count: u32 = 0;
    if (root.object.get("skins")) |skins| {
        if (skins == .array and skins.array.items.len > 0) {
            const skin0 = skins.array.items[0];
            if (skin0 == .object) {
                if (skin0.object.get("joints")) |joints| {
                    if (joints == .array) joint_count = @intCast(joints.array.items.len);
                }
                if (skin0.object.get("inverseBindMatrices")) |ibm_val| {
                    const ibm_i: usize = @intCast(ibm_val.integer);
                    inverse_binds = try readAccessorMat4(allocator, accessors.array, buffer_views.array, bin_slice, ibm_i);
                    if (joint_count == 0) joint_count = @intCast(inverse_binds.?.len / 16);
                }
            }
        }
    }

    std.debug.print("[gltf] loaded verts={d} inds={d} joints={d} skinned={}\n", .{
        vert_count,
        indices.len,
        joint_count,
        influences != null,
    });

    return .{
        .vertices = vertices,
        .indices = indices,
        .influences = influences,
        .inverse_binds = inverse_binds,
        .joint_count = joint_count,
        .allocator = allocator,
    };
}

fn attrIndex(obj: std.json.ObjectMap, name: []const u8) ?usize {
    const v = obj.get(name) orelse return null;
    return @intCast(v.integer);
}

fn accessorObj(accessors: std.json.Array, index: usize) LoadError!std.json.ObjectMap {
    if (index >= accessors.items.len) return error.BadAccessor;
    const a = accessors.items[index];
    if (a != .object) return error.BadAccessor;
    return a.object;
}

fn viewSlice(buffer_views: std.json.Array, bin: []const u8, view_i: usize) LoadError![]const u8 {
    if (view_i >= buffer_views.items.len) return error.BadAccessor;
    const bv = buffer_views.items[view_i];
    if (bv != .object) return error.BadAccessor;
    const byte_offset: usize = if (bv.object.get("byteOffset")) |o| @intCast(o.integer) else 0;
    const byte_length: usize = @intCast((bv.object.get("byteLength") orelse return error.BadAccessor).integer);
    if (byte_offset + byte_length > bin.len) return error.BadAccessor;
    return bin[byte_offset .. byte_offset + byte_length];
}

fn readAccessorVec3(
    allocator: std.mem.Allocator,
    accessors: std.json.Array,
    buffer_views: std.json.Array,
    bin: []const u8,
    index: usize,
) LoadError![][3]f32 {
    const acc = try accessorObj(accessors, index);
    const count: usize = @intCast((acc.get("count") orelse return error.BadAccessor).integer);
    const view_i: usize = @intCast((acc.get("bufferView") orelse return error.BadAccessor).integer);
    const component_type: i64 = (acc.get("componentType") orelse return error.BadAccessor).integer;
    if (component_type != 5126) return error.UnsupportedFeature; // FLOAT
    const acc_off: usize = if (acc.get("byteOffset")) |o| @intCast(o.integer) else 0;
    const slice = try viewSlice(buffer_views, bin, view_i);
    const bv = buffer_views.items[view_i].object;
    const stride: usize = if (bv.get("byteStride")) |s| @intCast(s.integer) else 12;
    var out = try allocator.alloc([3]f32, count);
    var i: usize = 0;
    while (i < count) : (i += 1) {
        const o = acc_off + i * stride;
        if (o + 12 > slice.len) return error.BadAccessor;
        out[i][0] = @bitCast(std.mem.readInt(u32, slice[o .. o + 4][0..4], .little));
        out[i][1] = @bitCast(std.mem.readInt(u32, slice[o + 4 .. o + 8][0..4], .little));
        out[i][2] = @bitCast(std.mem.readInt(u32, slice[o + 8 .. o + 12][0..4], .little));
    }
    return out;
}

fn readAccessorIndices(
    allocator: std.mem.Allocator,
    accessors: std.json.Array,
    buffer_views: std.json.Array,
    bin: []const u8,
    index: usize,
) LoadError![]u32 {
    const acc = try accessorObj(accessors, index);
    const count: usize = @intCast((acc.get("count") orelse return error.BadAccessor).integer);
    const view_i: usize = @intCast((acc.get("bufferView") orelse return error.BadAccessor).integer);
    const component_type: i64 = (acc.get("componentType") orelse return error.BadAccessor).integer;
    const acc_off: usize = if (acc.get("byteOffset")) |o| @intCast(o.integer) else 0;
    const slice = try viewSlice(buffer_views, bin, view_i);
    var out = try allocator.alloc(u32, count);
    var i: usize = 0;
    if (component_type == 5123) { // UNSIGNED_SHORT
        while (i < count) : (i += 1) {
            const o = acc_off + i * 2;
            if (o + 2 > slice.len) return error.BadAccessor;
            out[i] = std.mem.readInt(u16, slice[o .. o + 2][0..2], .little);
        }
    } else if (component_type == 5125) { // UNSIGNED_INT
        while (i < count) : (i += 1) {
            const o = acc_off + i * 4;
            if (o + 4 > slice.len) return error.BadAccessor;
            out[i] = std.mem.readInt(u32, slice[o .. o + 4][0..4], .little);
        }
    } else return error.UnsupportedFeature;
    return out;
}

fn readAccessorMat4(
    allocator: std.mem.Allocator,
    accessors: std.json.Array,
    buffer_views: std.json.Array,
    bin: []const u8,
    index: usize,
) LoadError![]f32 {
    const acc = try accessorObj(accessors, index);
    const count: usize = @intCast((acc.get("count") orelse return error.BadAccessor).integer);
    const view_i: usize = @intCast((acc.get("bufferView") orelse return error.BadAccessor).integer);
    const acc_off: usize = if (acc.get("byteOffset")) |o| @intCast(o.integer) else 0;
    const slice = try viewSlice(buffer_views, bin, view_i);
    var out = try allocator.alloc(f32, count * 16);
    var i: usize = 0;
    while (i < count * 16) : (i += 1) {
        const o = acc_off + i * 4;
        if (o + 4 > slice.len) return error.BadAccessor;
        out[i] = @bitCast(std.mem.readInt(u32, slice[o .. o + 4][0..4], .little));
    }
    return out;
}

fn readSkinInfluences(
    allocator: std.mem.Allocator,
    accessors: std.json.Array,
    buffer_views: std.json.Array,
    bin: []const u8,
    joints_i: usize,
    weights_i: usize,
    vert_count: usize,
) LoadError![]mesh.SkinInfluence {
    const j_acc = try accessorObj(accessors, joints_i);
    const w_acc = try accessorObj(accessors, weights_i);
    const j_view: usize = @intCast((j_acc.get("bufferView") orelse return error.BadAccessor).integer);
    const w_view: usize = @intCast((w_acc.get("bufferView") orelse return error.BadAccessor).integer);
    const j_off: usize = if (j_acc.get("byteOffset")) |o| @intCast(o.integer) else 0;
    const w_off: usize = if (w_acc.get("byteOffset")) |o| @intCast(o.integer) else 0;
    const j_type: i64 = (j_acc.get("componentType") orelse return error.BadAccessor).integer;
    const j_slice = try viewSlice(buffer_views, bin, j_view);
    const w_slice = try viewSlice(buffer_views, bin, w_view);
    const j_stride: usize = if (buffer_views.items[j_view].object.get("byteStride")) |s| @intCast(s.integer) else if (j_type == 5121) 4 else 8;
    const w_stride: usize = if (buffer_views.items[w_view].object.get("byteStride")) |s| @intCast(s.integer) else 16;

    var out = try allocator.alloc(mesh.SkinInfluence, vert_count);
    var i: usize = 0;
    while (i < vert_count) : (i += 1) {
        var joints: [4]u16 = .{ 0, 0, 0, 0 };
        var k: usize = 0;
        while (k < 4) : (k += 1) {
            if (j_type == 5121) { // UNSIGNED_BYTE
                const o = j_off + i * j_stride + k;
                if (o < j_slice.len) joints[k] = j_slice[o];
            } else { // UNSIGNED_SHORT
                const o = j_off + i * j_stride + k * 2;
                if (o + 2 <= j_slice.len) joints[k] = std.mem.readInt(u16, j_slice[o .. o + 2][0..2], .little);
            }
        }
        var weights: [4]f32 = .{ 0, 0, 0, 0 };
        k = 0;
        while (k < 4) : (k += 1) {
            const o = w_off + i * w_stride + k * 4;
            if (o + 4 <= w_slice.len) weights[k] = @bitCast(std.mem.readInt(u32, w_slice[o .. o + 4][0..4], .little));
        }
        out[i] = .{ .joints = joints, .weights = weights };
    }
    return out;
}
