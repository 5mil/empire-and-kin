//! Backend selection from build_options.
const build_options = @import("build_options");

pub const BackendMod = if (build_options.enable_gpu)
    @import("gl_backend.zig")
else if (@hasDecl(build_options, "enable_android") and build_options.enable_android)
    @import("android_backend.zig")
else
    @import("null_backend.zig");
