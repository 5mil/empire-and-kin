//! Asset Continuum resolver — never blank, upgrade when better data exists.
//!
//! T0 procedural → T1 cache → T2 disk path → (T3/T4 offline via tools).
//! Runtime does not call network or TRELLIS; it only reads local state and may
//! write a generate job file for offline workers.

const std = @import("std");
const texture_bank = @import("texture_bank.zig");
const resource_manager = @import("resource_manager.zig");

pub const Tier = enum(u8) {
    procedural = 0,
    cache = 1,
    disk = 2,
    /// Offline only — recorded when a job is written
    queued_generate = 4,
};

pub const Kind = enum {
    building,
    vehicle,
    prop,
    character,
    surface,
};

pub const Fallback = struct {
    material: texture_bank.MaterialId = .brick,
    /// Logical prim the scene already knows how to draw.
    prim: enum { box_building, box_vehicle, box_prop, procedural_humanoid, surface_tile } = .box_building,
};

pub const Recipe = struct {
    id: []const u8,
    kind: Kind,
    fallback: Fallback = .{},
    /// Preferred relative paths (first hit wins).
    prefer: []const []const u8 = &[_][]const u8{},
    /// If set, missing mesh can enqueue offline premium generation.
    generate_tool: ?[]const u8 = null,
    generate_prompt: ?[]const u8 = null,
    generate_out: ?[]const u8 = null,
};

pub const ResolveResult = struct {
    tier: Tier,
    recipe_id: []const u8,
    /// Set when a mesh should be drawn.
    mesh_id: ?resource_manager.AssetId = null,
    fallback: Fallback = .{},
    /// True if a T4 job was written this resolve.
    enqueued: bool = false,
};

pub const Resolver = struct {
    allocator: std.mem.Allocator,
    res: *resource_manager.ResourceManager,
    /// When true, write assets/queue/<id>.job.json if mesh missing and recipe has generate_*.
    allow_enqueue: bool = true,
    /// Stats for debug overlay.
    draws_mesh: u32 = 0,
    draws_prim: u32 = 0,
    enqueues: u32 = 0,

    pub fn init(allocator: std.mem.Allocator, res: *resource_manager.ResourceManager) Resolver {
        return .{ .allocator = allocator, .res = res };
    }

    /// Resolve a recipe to mesh-or-procedural. Never fails empty — always a drawable result.
    pub fn resolve(self: *Resolver, recipe: Recipe) ResolveResult {
        var result: ResolveResult = .{
            .tier = .procedural,
            .recipe_id = recipe.id,
            .fallback = recipe.fallback,
        };

        // T1/T2: preferred paths already cached or loadable from disk
        for (recipe.prefer) |path| {
            if (self.res.loadPath(path)) |id| {
                result.tier = .cache;
                result.mesh_id = id;
                self.draws_mesh += 1;
                return result;
            }
        }

        // T0 procedural is the guaranteed path
        self.draws_prim += 1;
        result.tier = .procedural;

        // T4: enqueue premium generation for offline worker (non-blocking)
        if (self.allow_enqueue) {
            if (recipe.generate_tool != null and recipe.generate_out != null) {
                if (self.enqueueJob(recipe)) {
                    result.enqueued = true;
                    result.tier = .queued_generate;
                    // Still draw procedural this frame; tier marks that better art is pending.
                    self.enqueues += 1;
                }
            }
        }
        return result;
    }

    /// Convenience: building footprint without a full recipe file yet.
    pub fn resolveBuildingQuick(
        self: *Resolver,
        recipe_id: []const u8,
        prefer_path: ?[]const u8,
        material: texture_bank.MaterialId,
    ) ResolveResult {
        var prefer_buf: [1][]const u8 = undefined;
        var prefer_slice: []const []const u8 = &[_][]const u8{};
        if (prefer_path) |p| {
            prefer_buf[0] = p;
            prefer_slice = prefer_buf[0..];
        }
        const recipe = Recipe{
            .id = recipe_id,
            .kind = .building,
            .fallback = .{ .material = material, .prim = .box_building },
            .prefer = prefer_slice,
            .generate_tool = "trellis2",
            .generate_prompt = null,
            .generate_out = null,
        };
        return self.resolve(recipe);
    }

    fn enqueueJob(self: *Resolver, recipe: Recipe) bool {
        const tool = recipe.generate_tool orelse return false;
        const out_dir = recipe.generate_out orelse return false;

        // Sanitize id for filename
        var name_buf: [128]u8 = undefined;
        const safe = sanitizeId(recipe.id, &name_buf);

        var path_buf: [256]u8 = undefined;
        const path = std.fmt.bufPrint(&path_buf, "assets/queue/{s}.job.json", .{safe}) catch return false;

        // Do not overwrite completed/pending jobs blindly — skip if exists
        if (std.fs.cwd().access(path, .{})) |_| {
            return false;
        } else |_| {}

        std.fs.cwd().makePath("assets/queue") catch {};

        const prompt = recipe.generate_prompt orelse recipe.id;
        var body_buf: [1024]u8 = undefined;
        const body = std.fmt.bufPrint(&body_buf,
            \\{{
            \\  "recipe_id": "{s}",
            \\  "status": "pending",
            \\  "tool": "{s}",
            \\  "out": "{s}",
            \\  "prompt": "{s}",
            \\  "res": 512
            \\}}
        , .{ recipe.id, tool, out_dir, prompt }) catch return false;

        const file = std.fs.cwd().createFile(path, .{}) catch return false;
        defer file.close();
        file.writeAll(body) catch return false;
        std.debug.print("[continuum] queued {s} → {s}\n", .{ recipe.id, path });
        return true;
    }

    pub fn resetStats(self: *Resolver) void {
        self.draws_mesh = 0;
        self.draws_prim = 0;
        self.enqueues = 0;
    }
};

fn sanitizeId(id: []const u8, buf: []u8) []const u8 {
    const n = @min(id.len, buf.len);
    var i: usize = 0;
    while (i < n) : (i += 1) {
        const c = id[i];
        buf[i] = if ((c >= 'a' and c <= 'z') or
            (c >= 'A' and c <= 'Z') or
            (c >= '0' and c <= '9') or
            c == '_' or c == '-' or c == '.')
            c
        else
            '_';
    }
    return buf[0..n];
}

/// Built-in starter recipes (no JSON parse required for first continuum pass).
pub const builtin_tenement = Recipe{
    .id = "bld.tenement.brick.mid.01",
    .kind = .building,
    .fallback = .{ .material = .brick, .prim = .box_building },
    .prefer = &[_][]const u8{
        "assets/cc0/buildings/building.glb",
        "assets/cc0/buildings/house.glb",
        "assets/generated/buildings/tenement_brick_mid_01/tenement_brick_mid_01.glb",
    },
    .generate_tool = "trellis2",
    .generate_prompt = "1930s NYC brick tenement, clean game asset, orthographic three-quarter view, plain background",
    .generate_out = "assets/generated/buildings/tenement_brick_mid_01",
};

pub const builtin_sedan = Recipe{
    .id = "veh.sedan.period.01",
    .kind = .vehicle,
    .fallback = .{ .material = .metal, .prim = .box_vehicle },
    .prefer = &[_][]const u8{
        "assets/cc0/vehicles/sedan.glb",
        "assets/generated/vehicles/sedan_period_01/sedan_period_01.glb",
    },
    .generate_tool = "trellis2",
    .generate_prompt = "1930s sedan car, side view, plain background, game-ready vehicle mesh",
    .generate_out = "assets/generated/vehicles/sedan_period_01",
};
