//! Runtime model registry — load CC0 GLB from assets/cc0 or fall back to procedural.

const std = @import("std");
const mesh = @import("mesh.zig");
const gpu_mesh = @import("gpu_mesh.zig");
const gltf = @import("gltf_loader.zig");
const skin = @import("skin.zig");

pub const ModelSlot = enum { boss, building, prop };

pub const Registry = struct {
    allocator: std.mem.Allocator,
    boss_gpu: ?gpu_mesh.GpuMesh = null,
    building_gpu: ?gpu_mesh.GpuMesh = null,
    boss_skinned: bool = false,
    loaded_path_boss: bool = false,

    pub fn init(allocator: std.mem.Allocator) Registry {
        return .{ .allocator = allocator };
    }

    pub fn deinit(self: *Registry) void {
        if (self.boss_gpu) |*m| m.destroy();
        if (self.building_gpu) |*m| m.destroy();
        self.* = .{ .allocator = self.allocator };
    }

    /// Try load character / building GLBs from common CC0 paths.
    pub fn tryLoadDefaults(self: *Registry) void {
        const boss_paths = [_][]const u8{
            "assets/cc0/characters/character.glb",
            "assets/cc0/characters/Character.glb",
            "assets/cc0/characters/Boss.glb",
            "assets/cc0/characters/player.glb",
        };
        for (boss_paths) |p| {
            if (self.loadBossGlb(p)) break;
        }
        const bld_paths = [_][]const u8{
            "assets/cc0/buildings/building.glb",
            "assets/cc0/buildings/Building.glb",
            "assets/cc0/buildings/house.glb",
        };
        for (bld_paths) |p| {
            if (self.loadBuildingGlb(p)) break;
        }
    }

    pub fn loadBossGlb(self: *Registry, path: []const u8) bool {
        var model = gltf.loadGlbPath(self.allocator, path) catch {
            return false;
        };
        defer model.deinit();

        var draw_verts = self.allocator.alloc(mesh.Vertex, model.vertices.len) catch return false;
        defer self.allocator.free(draw_verts);

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
            self.boss_skinned = true;
        } else {
            @memcpy(draw_verts, model.vertices);
            self.boss_skinned = false;
        }

        const m: mesh.Mesh = .{ .vertices = draw_verts, .indices = model.indices };
        if (self.boss_gpu) |*old| old.destroy();
        self.boss_gpu = gpu_mesh.GpuMesh.create(m);
        self.loaded_path_boss = true;
        std.debug.print("[models] boss GLB OK: {s} skinned={}\n", .{ path, self.boss_skinned });
        return true;
    }

    pub fn loadBuildingGlb(self: *Registry, path: []const u8) bool {
        var model = gltf.loadGlbPath(self.allocator, path) catch return false;
        defer model.deinit();
        const m: mesh.Mesh = .{ .vertices = model.vertices, .indices = model.indices };
        if (self.building_gpu) |*old| old.destroy();
        self.building_gpu = gpu_mesh.GpuMesh.create(m);
        std.debug.print("[models] building GLB OK: {s}\n", .{path});
        return true;
    }
};
