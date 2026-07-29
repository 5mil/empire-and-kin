//! High-level model registry built on ResourceManager.
//! Scans assets/cc0/** for GLB, picks character/building/vehicle slots.

const std = @import("std");
const gpu_mesh = @import("gpu_mesh.zig");
const resource_manager = @import("resource_manager.zig");

pub const Registry = struct {
    allocator: std.mem.Allocator,
    res: resource_manager.ResourceManager,
    boss_id: ?resource_manager.AssetId = null,
    building_id: ?resource_manager.AssetId = null,
    vehicle_id: ?resource_manager.AssetId = null,

    pub fn init(allocator: std.mem.Allocator) Registry {
        return .{ .allocator = allocator, .res = resource_manager.ResourceManager.init(allocator) };
    }

    pub fn deinit(self: *Registry) void {
        self.res.deinit();
        self.* = .{ .allocator = self.allocator, .res = resource_manager.ResourceManager.init(self.allocator) };
    }

    /// Mass-ingest all GLBs under standard CC0 trees + named fallbacks.
    pub fn tryLoadDefaults(self: *Registry) void {
        self.res.addScanRoot("assets/cc0");
        self.res.addScanRoot("assets/cc0/characters");
        self.res.addScanRoot("assets/cc0/buildings");
        self.res.addScanRoot("assets/cc0/vehicles");
        self.res.addScanRoot("assets/cc0/props");
        self.res.addScanRoot("assets/cc0/environment");
        self.res.ingestTree();

        // Prefer explicit names if present
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

        const prefer_bld = [_][]const u8{
            "assets/cc0/buildings/building.glb",
            "assets/cc0/buildings/house.glb",
        };
        for (prefer_bld) |p| {
            if (self.res.loadPath(p)) |id| {
                self.building_id = id;
                break;
            }
        }
        if (self.building_id == null) self.building_id = self.res.firstOf(.building);

        self.vehicle_id = self.res.firstOf(.vehicle);

        std.debug.print("[models] cache={d} chars={d} bld={d} veh={d} props={d}\n", .{
            self.res.totalCached(),
            self.res.countCategory(.character),
            self.res.countCategory(.building),
            self.res.countCategory(.vehicle),
            self.res.countCategory(.prop),
        });
    }

    pub fn boss_gpu(self: *const Registry) ?gpu_mesh.GpuMesh {
        const id = self.boss_id orelse return null;
        // const cast for getGpu — need mut; use workaround
        return @constCast(&self.res).getGpu(id);
    }

    pub fn building_gpu(self: *const Registry) ?gpu_mesh.GpuMesh {
        const id = self.building_id orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    pub fn vehicle_gpu(self: *const Registry) ?gpu_mesh.GpuMesh {
        const id = self.vehicle_id orelse return null;
        return @constCast(&self.res).getGpu(id);
    }

    // Back-compat fields for older renderer hooks
    pub fn getBossGpu(self: *Registry) ?gpu_mesh.GpuMesh {
        return self.boss_gpu();
    }
};
