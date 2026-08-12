//! High-level model registry built on ResourceManager.
//! Scans assets/cc0/** and assets/generated/** for GLB.

const std = @import("std");
const gpu_mesh = @import("gpu_mesh.zig");
const resource_manager = @import("resource_manager.zig");

pub const MAX_BUILDING_VARIANTS: usize = 32;
pub const MAX_PROP_VARIANTS: usize = 24;

pub const Registry = struct {
    allocator: std.mem.Allocator,
    res: resource_manager.ResourceManager,
    boss_id: ?resource_manager.AssetId = null,
    building_id: ?resource_manager.AssetId = null,
    building_ids: [MAX_BUILDING_VARIANTS]resource_manager.AssetId = undefined,
    building_count: usize = 0,
    vehicle_id: ?resource_manager.AssetId = null,
    prop_ids: [MAX_PROP_VARIANTS]resource_manager.AssetId = undefined,
    prop_count: usize = 0,

    pub fn init(allocator: std.mem.Allocator) Registry {
        return .{ .allocator = allocator, .res = resource_manager.ResourceManager.init(allocator) };
    }

    pub fn deinit(self: *Registry) void {
        self.res.deinit();
        self.* = .{ .allocator = self.allocator, .res = resource_manager.ResourceManager.init(self.allocator) };
    }

    pub fn tryLoadDefaults(self: *Registry) void {
        self.res.addScanRoot("assets/cc0");
        self.res.addScanRoot("assets/cc0/characters");
        self.res.addScanRoot("assets/cc0/buildings");
        self.res.addScanRoot("assets/cc0/vehicles");
        self.res.addScanRoot("assets/cc0/props");
        self.res.addScanRoot("assets/cc0/environment");
        self.res.addScanRoot("assets/generated");
        self.res.addScanRoot("assets/generated/buildings");
        self.res.addScanRoot("assets/generated/props");
        self.res.addScanRoot("assets/generated/vehicles");
        self.res.ingestTree();

        const prefer_boss = [_][]const u8{
            "assets/cc0/characters/character.glb",
            "assets/cc0/characters/Character.glb",
            "assets/cc0/characters/player.glb",
        };
        for (prefer_boss) |p| {
            if (self.res.loadPath(p)) |id| {
                self.boss_id = id;
                break;
            }
        }
        if (self.boss_id == null) self.boss_id = self.res.firstOf(.character);

        self.building_count = self.res.collectCategory(.building, self.building_ids[0..]);
        if (self.building_count == 0) {
            const prefer_bld = [_][]const u8{
                "assets/cc0/buildings/building.glb",
                "assets/cc0/buildings/house.glb",
            };
            for (prefer_bld) |p| {
                if (self.res.loadPath(p)) |id| {
                    self.building_ids[0] = id;
                    self.building_count = 1;
                    break;
                }
            }
            if (self.building_count == 0) {
                if (self.res.firstOf(.building)) |id| {
                    self.building_ids[0] = id;
                    self.building_count = 1;
                }
            }
        }
        if (self.building_count > 0) self.building_id = self.building_ids[0];

        self.vehicle_id = self.res.firstOf(.vehicle);

        self.prop_count = self.res.collectCategory(.prop, self.prop_ids[0..]);
        if (self.prop_count == 0) {
            if (self.res.firstOf(.prop)) |id| {
                self.prop_ids[0] = id;
                self.prop_count = 1;
            }
        }

        std.debug.print("[models] cache={d} chars={d} bld={d} variants={d} veh={d} props={d}\n", .{
            self.res.totalCached(),
            self.res.countCategory(.character),
            self.res.countCategory(.building),
            self.building_count,
            self.res.countCategory(.vehicle),
            self.prop_count,
        });
    }

    pub fn buildingIdAt(self: *const Registry, x: f32, z: f32) ?resource_manager.AssetId {
        if (self.building_count == 0) return self.building_id;
        const hx: i32 = @intFromFloat(x * 10.0);
        const hz: i32 = @intFromFloat(z * 10.0);
        const h: u32 = @bitCast(hx *% 73856093 ^ hz *% 19349663);
        return self.building_ids[h % self.building_count];
    }

    pub fn propIdAt(self: *const Registry, x: f32, z: f32) ?resource_manager.AssetId {
        if (self.prop_count == 0) return null;
        const hx: i32 = @intFromFloat(x * 17.0);
        const hz: i32 = @intFromFloat(z * 31.0);
        const h: u32 = @bitCast(hx *% 2654435761 ^ hz *% 2246822519);
        return self.prop_ids[h % self.prop_count];
    }

    pub fn boss_gpu(self: *const Registry) ?gpu_mesh.GpuMesh {
        const id = self.boss_id orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn building_gpu(self: *const Registry) ?gpu_mesh.GpuMesh {
        const id = self.building_id orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn building_gpu_at(self: *const Registry, x: f32, z: f32) ?gpu_mesh.GpuMesh {
        const id = self.buildingIdAt(x, z) orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn prop_gpu_at(self: *const Registry, x: f32, z: f32) ?gpu_mesh.GpuMesh {
        const id = self.propIdAt(x, z) orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn vehicle_gpu(self: *const Registry) ?gpu_mesh.GpuMesh {
        const id = self.vehicle_id orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn getBossGpu(self: *Registry) ?gpu_mesh.GpuMesh {
        return self.boss_gpu();
    }
};
