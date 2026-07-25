//! GPU mesh (VAO / VBO / EBO).
const gl = @import("gl.zig");
const mesh = @import("mesh.zig");

pub const GpuMesh = struct {
    vao: gl.GLuint = 0,
    vbo: gl.GLuint = 0,
    ebo: gl.GLuint = 0,
    index_count: gl.GLsizei = 0,

    pub fn create(data: mesh.MeshData) GpuMesh {
        var m: GpuMesh = .{};
        gl.glGenVertexArrays(1, &m.vao);
        gl.glGenBuffers(1, &m.vbo);
        gl.glGenBuffers(1, &m.ebo);
        gl.glBindVertexArray(m.vao);
        gl.glBindBuffer(gl.ARRAY_BUFFER, m.vbo);
        const vsize: gl.GLsizeiptr = @intCast(data.vertices.len * @sizeOf(mesh.Vertex));
        gl.glBufferData(gl.ARRAY_BUFFER, vsize, data.vertices.ptr, gl.STATIC_DRAW);
        gl.glBindBuffer(gl.ELEMENT_ARRAY_BUFFER, m.ebo);
        const isize: gl.GLsizeiptr = @intCast(data.indices.len * @sizeOf(u32));
        gl.glBufferData(gl.ELEMENT_ARRAY_BUFFER, isize, data.indices.ptr, gl.STATIC_DRAW);
        const stride: gl.GLsizei = @sizeOf(mesh.Vertex);
        gl.glEnableVertexAttribArray(0);
        gl.glVertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(0));
        gl.glEnableVertexAttribArray(1);
        gl.glVertexAttribPointer(1, 3, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(12));
        gl.glEnableVertexAttribArray(2);
        gl.glVertexAttribPointer(2, 4, gl.FLOAT, gl.FALSE, stride, @ptrFromInt(24));
        gl.glBindVertexArray(0);
        m.index_count = @intCast(data.indices.len);
        return m;
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
