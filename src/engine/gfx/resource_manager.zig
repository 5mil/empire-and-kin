//! Resource management — ground-up asset cache for many CC0 meshes.
//! Designed for scale: hash paths, cache GPU meshes, scan directories, lazy load.
//! Superior ops model vs ad-hoc loaders: one registry, ref-count ready, category tags.

const std = @import("std");
const mesh = @import("mesh.zig");
const gpu_mesh = @import("gpu_mesh.zig");
const gltf = @import("gltf_loader.zig");
const skin = @import("skin.zig");

pub const MAX_CACHED: usize = 256;

pub const Category = enum {
    character,
    building,
    vehicle,
    prop,
    environment,
    unknown,

    pub fn fromPath(path: []const u8) Category {
        if (std.mem.indexOf(u8, path, "character") != null or std.mem.indexOf(u8, path, "Characters") != null) return .character;
        if (std.mem.indexOf(u8, path, "building") != null or std.mem.indexOf(u8, path, "City") != null) return .building;
        if (std.mem.indexOf(u8, path, "vehicle") != null or std.mem.indexOf(u8, path, "car") != null or std.mem.indexOf(u8, path, "Car") != null) return .vehicle;
        if (std.mem.indexOf(u8, path, "prop") != null or std.mem.indexOf(u8, path, "nature") != null) return .prop;
        if (std.mem.indexOf(u8, path, "environment") != null or std.mem.indexOf(u8, path, "road") != null) return .environment;
        return .unknown;
    }
};

pub const AssetId = u64;

pub fn hashPath(path: []const u8) AssetId {
    return std.hash.Wyhash.hash(0, path);
}

const Slot = struct {
    id: AssetId = 0,
    path: []u8 = &[_]u8{},
    gpu: gpu_mesh.GpuMesh = .{},
    category: Category = .unknown,
    skinned: bool = false,
    vertex_count: u32 = 0,
    index_count: u32 = 0,
    refs: u32 = 0,
    used: bool = false,
};

pub const ResourceManager = struct {
    allocator: std.mem.Allocator,
    slots: [MAX_CACHED]Slot = [_]Slot{.{}} ** MAX_CACHED,
    count: usize = 0,
    scan_roots: [8][]const u8 = undefined,
    scan_root_count: usize = 0,

    pub fn init(allocator: std.mem.Allocator) ResourceManager {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *ResourceManager) void {
        var i: usize = 0;
        while (i < MAX_CACHED) : (i += 1) {
            if (self.slots[i].used) {
                self.slots[i].gpu.destroy();
                if (self.slots[i].path.len > 0) self.allocator.free(self.slots[i].path);
            }
        }
        self.* = .{ .allocator = self.allocator };
    }

    pub fn addScanRoot(self: *ResourceManager, root: []const u8) void {
        if (self.scan_root_count >= self.scan_roots.len) return;
        self.scan_roots[self.scan_root_count] = root;
        self.scan_root_count += 1;
    }

    /// Recursively find .glb / .gltf under scan roots and load into cache (cap MAX_CACHED).
    pub fn ingestTree(self: *ResourceManager) void {
        var i: usize = 0;
        while (i < self.scan_root_count) : (i += 1) {
            self.walkDir(self.scan_roots[i]) catch {};
        }
        std.debug.print("[res] ingest done cached={d}/{d}\n", .{ self.count, MAX_CACHED });
    }

    fn walkDir(self: *ResourceManager, dir_path: []const u8) !void {
        var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch return;
        defer dir.close();
        var it = dir.iterate();
        while (try it.next()) |entry| {
            if (self.count >= MAX_CACHED) return;
            var path_buf: [512]u8 = undefined;
            const full = std.fmt.bufPrint(&path_buf, "{s}/{s}", .{ dir_path, entry.name }) catch continue;
            if (entry.kind == .directory) {
                if (std.mem.eql(u8, entry.name, ".") or std.mem.eql(u8, entry.name, "..")) continue;
                try self.walkDir(full);
            } else if (entry.kind == .file) {
                if (std.mem.endsWith(u8, entry.name, ".glb") or std.mem.endsWith(u8, entry.name, ".GLB")) {
                    _ = self.loadPath(full);
                }
            }
        }
    }

    pub fn loadPath(self: *ResourceManager, path: []const u8) ?AssetId {
        const id = hashPath(path);
        if (self.find(id)) |idx| {
            self.slots[idx].refs += 1;
            return id;
        }
        if (self.count >= MAX_CACHED) {
            std.debug.print("[res] cache full, skip {s}\n", .{path});
            return null;
        }
        var model = gltf.loadGlbPath(self.allocator, path) catch {
            return null;
        };
        defer model.deinit();

        var draw_verts = self.allocator.alloc(mesh.Vertex, model.vertices.len) catch return null;
        defer self.allocator.free(draw_verts);

        var is_skinned = false;
        if (model.influences != null and model.inverse_binds != null and model.joint_count > 0) {
            var joints: [skin.MAX_JOINTS * 16]f32 = undefined;
            skin.identityJoints(model.joint_count, joints[0..]);
            skin.skinVertices(
                model.vertices,
                model.influences.?,
                model.inverse_binds.?,
                joints[0..],
                model.joint_count,
                draw_verts,
            );
            is_skinned = true;
        } else {
            @memcpy(draw_verts, model.vertices);
        }

        const m: mesh.Mesh = .{ .vertices = draw_verts, .indices = model.indices };
        const gpu = gpu_mesh.GpuMesh.create(m);

        const path_copy = self.allocator.dupe(u8, path) catch {
            var g = gpu;
            g.destroy();
            return null;
        };

        var slot_i: usize = 0;
        while (slot_i < MAX_CACHED) : (slot_i += 1) {
            if (!self.slots[slot_i].used) break;
        }
        if (slot_i >= MAX_CACHED) {
            self.allocator.free(path_copy);
            var g = gpu;
            g.destroy();
            return null;
        }

        self.slots[slot_i] = .{
            .id = id,
            .path = path_copy,
            .gpu = gpu,
            .category = Category.fromPath(path),
            .skinned = is_skinned,
            .vertex_count = @intCast(model.vertices.len),
            .index_count = @intCast(model.indices.len),
            .refs = 1,
            .used = true,
        };
        self.count += 1;
        std.debug.print("[res] +{s} cat={s} v={d} skin={}\n", .{
            path,
            @tagName(self.slots[slot_i].category),
            model.vertices.len,
            is_skinned,
        });
        return id;
    }

    fn find(self: *ResourceManager, id: AssetId) ?usize {
        var i: usize = 0;
        while (i < MAX_CACHED) : (i += 1) {
            if (self.slots[i].used and self.slots[i].id == id) return i;
        }
        return null;
    }

    pub fn getGpu(self: *ResourceManager, id: AssetId) ?gpu_mesh.GpuMesh {
        const idx = self.find(id) orelse return null;
        return self.slots[idx].gpu;
    }

    pub fn firstOf(self: *ResourceManager, cat: Category) ?AssetId {
        var i: usize = 0;
        while (i < MAX_CACHED) : (i += 1) {
            if (self.slots[i].used and self.slots[i].category == cat) return self.slots[i].id;
        }
        return null;
    }

    pub fn countCategory(self: *ResourceManager, cat: Category) usize {
        var n: usize = 0;
        var i: usize = 0;
        while (i < MAX_CACHED) : (i += 1) {
            if (self.slots[i].used and self.slots[i].category == cat) n += 1;
        }
        return n;
    }

    pub fn totalCached(self: *const ResourceManager) usize {
        return self.count;
    }
};
