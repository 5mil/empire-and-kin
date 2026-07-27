//! Backend selection from build_options.
//!
//! Priority:
//!   1. enable_gpu  → GLFW + OpenGL 3.3 (PC)
//!   2. enable_gles → EGL + GLES 3.0 (Android device graphics)
//!   3. enable_android → headless Android/touch demo (CI / no window)
//!   4. else NullBackend

const build_options = @import("build_options");

pub const BackendMod = if (build_options.enable_gpu)
    @import("gl_backend.zig")
else if (@hasDecl(build_options, "enable_gles") and build_options.enable_gles)
    @import("gles_backend.zig")
else if (@hasDecl(build_options, "enable_android") and build_options.enable_android)
    @import("android_backend.zig")
else
    @import("null_backend.zig");
