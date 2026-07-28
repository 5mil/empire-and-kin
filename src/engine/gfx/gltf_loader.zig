//! Minimal glTF 2.0 / GLB loader plan (Phase 1 of docs/FIDELITY_PIPELINE.md).
//!
//! Status: stub — no binary parse yet. When assets/cc0/*.glb exist:
//! 1. Map GLB chunks (JSON + BIN)
//! 2. Read meshes.primitives attributes POSITION/NORMAL/TEXCOORD_0
//! 3. Upload via gpu_mesh.GpuMesh
//! 4. Optional: sample animation channels for walk/idle
//!
//! Free asset sources (CC0): Kenney city kits, Quaternius characters, KayKit anims.
//! Tooling: Mesh2Motion (FOSS), Blender export GLB.

const std = @import("std");

pub const LoadError = error{
    NotImplemented,
    InvalidGlb,
    UnsupportedFeature,
    OutOfMemory,
};

pub const MeshHandle = struct {
    // Reserved for GPU buffer ids once loader is live.
    vertex_count: u32 = 0,
    index_count: u32 = 0,
};

/// Placeholder: returns error until binary GLB parse is implemented.
pub fn loadGlbPath(path: []const u8) LoadError!MeshHandle {
    _ = path;
    std.debug.print("[gltf] loadGlbPath: not implemented — place CC0 GLB under assets/cc0/\n", .{});
    return error.NotImplemented;
}

pub fn loadGlbBytes(bytes: []const u8) LoadError!MeshHandle {
    if (bytes.len < 12) return error.InvalidGlb;
    // GLB magic = 0x46546C67 ('glTF')
    const magic = std.mem.readInt(u32, bytes[0..4], .little);
    if (magic != 0x46546C67) return error.InvalidGlb;
    _ = bytes;
    return error.NotImplemented;
}
