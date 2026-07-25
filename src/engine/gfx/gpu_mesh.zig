//! GPU-resident mesh (VAO + VBO + EBO).

const gl = @import("gl.zig");
const mesh = @import("mesh.zig");

pub const GpuMesh = struct {
    vao: gl.GLuint = 0,
    vbo: gl.GLuint = 0,
    ebo: gl.GLuint = 0,
    index_count: gl.GLsizei = 0,

    pub fn create(cpu: mesh.Mesh) GpuMesh {
        var vao: gl.GLuint = 0;
        var vbo: gl.GLuint = 0;
        var ebo: gl.GLuint = 0;
        gl.glGenVertexArrays(1, &vao);
        gl.glGenBuffers(1, &vbo);
        gl.glGenBuffers(1, &ebo);
        gl.glBindVertexArray(vao);
        gl.glBindBuffer(gl.ARRAY_BUFFER, vbo);
        const vsize: gl.GLsizeiptr = @intCast(cpu.vertices.len * @sizeOf(mesh.Vertex));
        gl.glBufferData(gl.ARRAY_BUFFER, vsize, cpu.vertices.ptr, gl.STATIC_DRAW);
        gl.glBindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
        const isize: gl.GLsizeiptr = @intCast(cpu.indices.len * @sizeOf(u32));
        gl.glBufferData(gl.ELEMENT_ARRAY_BUFFER, isize, cpu.indices.ptr, gl.STATIC_DRAW);
        const stride: gl.GLsizei = @sizeOf(mesh.Vertex);
        gl.glEnableVertexAttribArray(0);
        gl.glVertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(0));
        gl.glEnableVertexAttribArray(1);
        gl.glVertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(12));
        gl.glEnableVertexAttribArray(2);
        gl.glVertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(24));
        gl.glBindVertexArray(0);
        return .{ .vao = vao, .vbo = vbo, .ebo = ebo, .index_count = @intCast(cpu.indices.len) };
    }

    pub fn draw(self: GpuMesh) void {
        gl.glBindVertexArray(self.vao);
        gl.glDrawElements(gl.TRIANGLES, self.index_count, gl.UNSIGNED_INT, null);
        gl.glBindVertexArray(0);
    }

    pub fn destroy(self: *GpuMesh) void {
        if (self.vao != 0) gl.glDeleteVertexArrays(1, &self.vao);
        if (self.vbo != 0) gl.glDeleteBuffers(1, &self.vbo);
        if (self.ebo != 0) gl.glDeleteBuffers(1, &self.ebo);
        self.* = .{};
    }
};
