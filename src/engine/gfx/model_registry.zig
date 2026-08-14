//! High-level model registry built on ResourceManager.
//! Scans assets/cc0/** and assets/generated/** for GLB.

const std = @import("std");
const gpu_mesh = @import("gpu_mesh.zig");
const resource_manager = @import("resource_manager.zig");

pub const MAX_BUILDING_VARIANTS: usize = 32;
pub const MAX_PROP_VARIANTS: usize = 24;
pub const MAX_CHARACTER_VARIANTS: usize = 16;
pub const MAX_VEHICLE_VARIANTS: usize = 16;

pub const Registry = struct {
    allocator: std.mem.Allocator,
    res: resource_manager.ResourceManager,
    boss_id: ?resource_manager.AssetId = null,
    building_id: ?resource_manager.AssetId = null,
    building_ids: [MAX_BUILDING_VARIANTS]resource_manager.AssetId = undefined,
    building_count: usize = 0,
    vehicle_id: ?resource_manager.AssetId = null,
    vehicle_ids: [MAX_VEHICLE_VARIANTS]resource_manager.AssetId = undefined,
    vehicle_count: usize = 0,
    prop_ids: [MAX_PROP_VARIANTS]resource_manager.AssetId = undefined,
    prop_count: usize = 0,
    character_ids: [MAX_CHARACTER_VARIANTS]resource_manager.AssetId = undefined,
    character_count: usize = 0,

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
        self.res.addScanRoot("assets/generated/characters");
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

        self.character_count = self.res.collectCategory(.character, self.character_ids[0..]);
        if (self.character_count == 0) {
            if (self.boss_id) |id| {
                self.character_ids[0] = id;
                self.character_count = 1;
            } else if (self.res.firstOf(.character)) |id| {
                self.character_ids[0] = id;
                self.character_count = 1;
                self.boss_id = id;
            }
        }
        if (self.boss_id == null and self.character_count > 0) {
            self.boss_id = self.character_ids[0];
        }

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

        self.vehicle_count = self.res.collectCategory(.vehicle, self.vehicle_ids[0..]);
        if (self.vehicle_count == 0) {
            if (self.res.firstOf(.vehicle)) |id| {
                self.vehicle_ids[0] = id;
                self.vehicle_count = 1;
            }
        }
        if (self.vehicle_count > 0) self.vehicle_id = self.vehicle_ids[0];

        self.prop_count = self.res.collectCategory(.prop, self.prop_ids[0..]);
        if (self.prop_count == 0) {
            if (self.res.firstOf(.prop)) |id| {
                self.prop_ids[0] = id;
                self.prop_count = 1;
            }
        }

        std.debug.print("[models] cache={d} chars={d} variants={d} bld={d} veh={d} veh_var={d} props={d}\n", .{
            self.res.totalCached(),
            self.res.countCategory(.character),
            self.character_count,
            self.building_count,
            self.res.countCategory(.vehicle),
            self.vehicle_count,
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

    pub fn characterIdAt(self: *const Registry, x: f32, z: f32) ?resource_manager.AssetId {
        if (self.character_count == 0) return self.boss_id;
        const hx: i32 = @intFromFloat(x * 13.0);
        const hz: i32 = @intFromFloat(z * 29.0);
        const h: u32 = @bitCast(hx *% 1597334677 ^ hz *% 3812015801);
        return self.character_ids[h % self.character_count];
    }

    pub fn vehicleIdAt(self: *const Registry, x: f32, z: f32) ?resource_manager.AssetId {
        if (self.vehicle_count == 0) return self.vehicle_id;
        const hx: i32 = @intFromFloat(x * 11.0);
        const hz: i32 = @intFromFloat(z * 19.0);
        const h: u32 = @bitCast(hx *% 2246822519 ^ hz *% 3266489917);
        return self.vehicle_ids[h % self.vehicle_count];
    }

    pub fn vehicle_gpu_at(self: *const Registry, x: f32, z: f32) ?gpu_mesh.GpuMesh {
        const id = self.vehicleIdAt(x, z) orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn boss_gpu(self: *const Registry) ?gpu_mesh.GpuMesh {
        const id = self.boss_id orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn character_gpu_at(self: *const Registry, x: f32, z: f32) ?gpu_mesh.GpuMesh {
        const id = self.characterIdAt(x, z) orelse return null;
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
