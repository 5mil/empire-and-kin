//! GLSL 330 core sources (embedded).

pub const lit_vert =
    \\#version 330 core
    \\layout(location = 0) in vec3 aPos;
    \\layout(location = 1) in vec3 aNormal;
    \\layout(location = 2) in vec4 aColor;
    \\uniform mat4 uMVP;
    \\uniform mat4 uModel;
    \\out vec3 vNormal;
    \\out vec4 vColor;
    \\out vec3 vWorldPos;
    \\void main() {
    \\    vec4 world = uModel * vec4(aPos, 1.0);
    \\    vWorldPos = world.xyz;
    \\    vNormal = mat3(uModel) * aNormal;
    \\    vColor = aColor;
    \\    gl_Position = uMVP * vec4(aPos, 1.0);
    \\}
;

pub const lit_frag =
    \\#version 330 core
    \\in vec3 vNormal;
    \\in vec4 vColor;
    \\in vec3 vWorldPos;
    \\uniform vec3 uLightDir;
    \\uniform vec3 uAmbient;
    \\out vec4 FragColor;
    \\void main() {
    \\    vec3 n = normalize(vNormal);
    \\    float ndl = max(dot(n, normalize(-uLightDir)), 0.0);
    \\    vec3 lit = vColor.rgb * (uAmbient + vec3(ndl));
    \\    FragColor = vec4(lit, vColor.a);
    \\}
;

pub const ui_vert =
    \\#version 330 core
    \\layout(location = 0) in vec2 aPos;
    \\layout(location = 1) in vec4 aColor;
    \\uniform vec2 uScreen;
    \\out vec4 vColor;
    \\void main() {
    \\    float x = (aPos.x / uScreen.x) * 2.0 - 1.0;
    \\    float y = 1.0 - (aPos.y / uScreen.y) * 2.0;
    \\    gl_Position = vec4(x, y, 0.0, 1.0);
    \\    vColor = aColor;
    \\}
;

pub const ui_frag =
    \\#version 330 core
    \\in vec4 vColor;
    \\out vec4 FragColor;
    \\void main() {
    \\    FragColor = vColor;
    \\}
;
