//! Pick desktop GL 3.3 vs GLES 3.0 shader sources.
const build_options = @import("build_options");

pub const shaders = if (@hasDecl(build_options, "enable_android") and build_options.enable_android)
    @import("shaders_es.zig")
else if (@hasDecl(build_options, "enable_gles") and build_options.enable_gles)
    @import("shaders_es.zig")
else
    @import("shaders.zig");
