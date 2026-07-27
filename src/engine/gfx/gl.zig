//! Minimal OpenGL 3.3 / GLES loader via getProcAddress.

const std = @import("std");

pub const GLenum = c_uint;
pub const GLuint = c_uint;
pub const GLint = c_int;
pub const GLsizei = c_int;
pub const GLbitfield = c_uint;
pub const GLboolean = u8;
pub const GLfloat = f32;
pub const GLsizeiptr = isize;
pub const GLintptr = isize;
pub const GLchar = u8;

pub const FALSE: GLboolean = 0;
pub const TRUE: GLboolean = 1;
pub const COLOR_BUFFER_BIT: GLbitfield = 0x00004000;
pub const DEPTH_BUFFER_BIT: GLbitfield = 0x00000100;
pub const ARRAY_BUFFER: GLenum = 0x8892;
pub const ELEMENT_ARRAY_BUFFER: GLenum = 0x8893;
pub const STATIC_DRAW: GLenum = 0x88E4;
pub const DYNAMIC_DRAW: GLenum = 0x88E8;
pub const FLOAT: GLenum = 0x1406;
pub const UNSIGNED_INT: GLenum = 0x1405;
pub const TRIANGLES: GLenum = 0x0004;
pub const DEPTH_TEST: GLenum = 0x0B71;
pub const CULL_FACE: GLenum = 0x0B44;
pub const BLEND: GLenum = 0x0BE2;
pub const SRC_ALPHA: GLenum = 0x0302;
pub const ONE_MINUS_SRC_ALPHA: GLenum = 0x0303;
pub const VERTEX_SHADER: GLenum = 0x8B31;
pub const FRAGMENT_SHADER: GLenum = 0x8B30;
pub const COMPILE_STATUS: GLenum = 0x8B81;
pub const LINK_STATUS: GLenum = 0x8B82;
pub const INFO_LOG_LENGTH: GLenum = 0x8B84;

pub var glClear: *const fn (GLbitfield) callconv(.c) void = undefined;
pub var glClearColor: *const fn (GLfloat, GLfloat, GLfloat, GLfloat) callconv(.c) void = undefined;
pub var glViewport: *const fn (GLint, GLint, GLsizei, GLsizei) callconv(.c) void = undefined;
pub var glEnable: *const fn (GLenum) callconv(.c) void = undefined;
pub var glDisable: *const fn (GLenum) callconv(.c) void = undefined;
pub var glBlendFunc: *const fn (GLenum, GLenum) callconv(.c) void = undefined;
pub var glGenVertexArrays: *const fn (GLsizei, *GLuint) callconv(.c) void = undefined;
pub var glDeleteVertexArrays: *const fn (GLsizei, *const GLuint) callconv(.c) void = undefined;
pub var glBindVertexArray: *const fn (GLuint) callconv(.c) void = undefined;
pub var glGenBuffers: *const fn (GLsizei, *GLuint) callconv(.c) void = undefined;
pub var glDeleteBuffers: *const fn (GLsizei, *const GLuint) callconv(.c) void = undefined;
pub var glBindBuffer: *const fn (GLenum, GLuint) callconv(.c) void = undefined;
pub var glBufferData: *const fn (GLenum, GLsizeiptr, ?*const anyopaque, GLenum) callconv(.c) void = undefined;
pub var glEnableVertexAttribArray: *const fn (GLuint) callconv(.c) void = undefined;
pub var glVertexAttribPointer: *const fn (GLuint, GLint, GLenum, GLboolean, GLsizei, ?*const anyopaque) callconv(.c) void = undefined;
pub var glDrawElements: *const fn (GLenum, GLsizei, GLenum, ?*const anyopaque) callconv(.c) void = undefined;
pub var glDrawArrays: *const fn (GLenum, GLint, GLsizei) callconv(.c) void = undefined;
pub var glCreateShader: *const fn (GLenum) callconv(.c) GLuint = undefined;
pub var glDeleteShader: *const fn (GLuint) callconv(.c) void = undefined;
pub var glShaderSource: *const fn (GLuint, GLsizei, *const [*]const GLchar, ?*const GLint) callconv(.c) void = undefined;
pub var glCompileShader: *const fn (GLuint) callconv(.c) void = undefined;
pub var glGetShaderiv: *const fn (GLuint, GLenum, *GLint) callconv(.c) void = undefined;
pub var glGetShaderInfoLog: *const fn (GLuint, GLsizei, ?*GLsizei, [*]GLchar) callconv(.c) void = undefined;
pub var glCreateProgram: *const fn () callconv(.c) GLuint = undefined;
pub var glDeleteProgram: *const fn (GLuint) callconv(.c) void = undefined;
pub var glAttachShader: *const fn (GLuint, GLuint) callconv(.c) void = undefined;
pub var glLinkProgram: *const fn (GLuint) callconv(.c) void = undefined;
pub var glGetProgramiv: *const fn (GLuint, GLenum, *GLint) callconv(.c) void = undefined;
pub var glGetProgramInfoLog: *const fn (GLuint, GLsizei, ?*GLsizei, [*]GLchar) callconv(.c) void = undefined;
pub var glUseProgram: *const fn (GLuint) callconv(.c) void = undefined;
pub var glGetUniformLocation: *const fn (GLuint, [*:0]const GLchar) callconv(.c) GLint = undefined;
pub var glUniformMatrix4fv: *const fn (GLint, GLsizei, GLboolean, [*]const GLfloat) callconv(.c) void = undefined;
pub var glUniform1f: *const fn (GLint, GLfloat) callconv(.c) void = undefined;
pub var glUniform3f: *const fn (GLint, GLfloat, GLfloat, GLfloat) callconv(.c) void = undefined;
pub var glUniform4f: *const fn (GLint, GLfloat, GLfloat, GLfloat, GLfloat) callconv(.c) void = undefined;
pub var glUniform2f: *const fn (GLint, GLfloat, GLfloat) callconv(.c) void = undefined;

pub const GetProc = *const fn (procname: [*:0]const u8) callconv(.c) ?*anyopaque;

fn loadFn(comptime T: type, get: GetProc, name: [*:0]const u8) !T {
    const p = get(name) orelse return error.MissingGlProc;
    return @ptrCast(p);
}

pub fn load(get: GetProc) !void {
    glClear = try loadFn(@TypeOf(glClear), get, "glClear");
    glClearColor = try loadFn(@TypeOf(glClearColor), get, "glClearColor");
    glViewport = try loadFn(@TypeOf(glViewport), get, "glViewport");
    glEnable = try loadFn(@TypeOf(glEnable), get, "glEnable");
    glDisable = try loadFn(@TypeOf(glDisable), get, "glDisable");
    glBlendFunc = try loadFn(@TypeOf(glBlendFunc), get, "glBlendFunc");
    glGenVertexArrays = try loadFn(@TypeOf(glGenVertexArrays), get, "glGenVertexArrays");
    glDeleteVertexArrays = try loadFn(@TypeOf(glDeleteVertexArrays), get, "glDeleteVertexArrays");
    glBindVertexArray = try loadFn(@TypeOf(glBindVertexArray), get, "glBindVertexArray");
    glGenBuffers = try loadFn(@TypeOf(glGenBuffers), get, "glGenBuffers");
    glDeleteBuffers = try loadFn(@TypeOf(glDeleteBuffers), get, "glDeleteBuffers");
    glBindBuffer = try loadFn(@TypeOf(glBindBuffer), get, "glBindBuffer");
    glBufferData = try loadFn(@TypeOf(glBufferData), get, "glBufferData");
    glEnableVertexAttribArray = try loadFn(@TypeOf(glEnableVertexAttribArray), get, "glEnableVertexAttribArray");
    glVertexAttribPointer = try loadFn(@TypeOf(glVertexAttribPointer), get, "glVertexAttribPointer");
    glDrawElements = try loadFn(@TypeOf(glDrawElements), get, "glDrawElements");
    glDrawArrays = try loadFn(@TypeOf(glDrawArrays), get, "glDrawArrays");
    glCreateShader = try loadFn(@TypeOf(glCreateShader), get, "glCreateShader");
    glDeleteShader = try loadFn(@TypeOf(glDeleteShader), get, "glDeleteShader");
    glShaderSource = try loadFn(@TypeOf(glShaderSource), get, "glShaderSource");
    glCompileShader = try loadFn(@TypeOf(glCompileShader), get, "glCompileShader");
    glGetShaderiv = try loadFn(@TypeOf(glGetShaderiv), get, "glGetShaderiv");
    glGetShaderInfoLog = try loadFn(@TypeOf(glGetShaderInfoLog), get, "glGetShaderInfoLog");
    glCreateProgram = try loadFn(@TypeOf(glCreateProgram), get, "glCreateProgram");
    glDeleteProgram = try loadFn(@TypeOf(glDeleteProgram), get, "glDeleteProgram");
    glAttachShader = try loadFn(@TypeOf(glAttachShader), get, "glAttachShader");
    glLinkProgram = try loadFn(@TypeOf(glLinkProgram), get, "glLinkProgram");
    glGetProgramiv = try loadFn(@TypeOf(glGetProgramiv), get, "glGetProgramiv");
    glGetProgramInfoLog = try loadFn(@TypeOf(glGetProgramInfoLog), get, "glGetProgramInfoLog");
    glUseProgram = try loadFn(@TypeOf(glUseProgram), get, "glUseProgram");
    glGetUniformLocation = try loadFn(@TypeOf(glGetUniformLocation), get, "glGetUniformLocation");
    glUniformMatrix4fv = try loadFn(@TypeOf(glUniformMatrix4fv), get, "glUniformMatrix4fv");
    glUniform1f = try loadFn(@TypeOf(glUniform1f), get, "glUniform1f");
    glUniform3f = try loadFn(@TypeOf(glUniform3f), get, "glUniform3f");
    glUniform4f = try loadFn(@TypeOf(glUniform4f), get, "glUniform4f");
    glUniform2f = try loadFn(@TypeOf(glUniform2f), get, "glUniform2f");
}
