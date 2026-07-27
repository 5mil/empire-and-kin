//! OpenGL ES 3.0 — same lighting model as desktop (fog + rim).

pub const lit_vert =
    \\#version 300 es
    \\precision mediump float;
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
    \\#version 300 es
    \\precision mediump float;
    \\in vec3 vNormal;
    \\in vec4 vColor;
    \\in vec3 vWorldPos;
    \\uniform vec3 uLightDir;
    \\uniform vec3 uAmbient;
    \\uniform vec4 uTint;
    \\uniform vec3 uFogColor;
    \\uniform float uFogDensity;
    \\uniform vec3 uCamPos;
    \\out vec4 FragColor;
    \\void main() {
    \\    vec3 n = normalize(vNormal);
    \\    float ndl = max(dot(n, normalize(-uLightDir)), 0.0);
    \\    float half_lambert = ndl * 0.5 + 0.5;
    \\    float rim = pow(1.0 - max(dot(n, normalize(uCamPos - vWorldPos)), 0.0), 3.0) * 0.12;
    \\    vec3 base = vColor.rgb * uTint.rgb;
    \\    vec3 lit = base * (uAmbient + vec3(half_lambert * 0.9)) + vec3(rim);
    \\    float dist = length(vWorldPos - uCamPos);
    \\    float fog = 1.0 - exp(-uFogDensity * dist);
    \\    fog = clamp(fog, 0.0, 0.85);
    \\    vec3 color = mix(lit, uFogColor, fog);
    \\    FragColor = vec4(color, vColor.a * uTint.a);
    \\}
;

pub const ui_vert =
    \\#version 300 es
    \\precision mediump float;
    \\layout(location = 0) in vec2 aPos;
    \\layout(location = 1) in vec4 aColor;
    \\uniform vec2 uScreen;
    \\out vec4 vColor;
    \\void main() {
    \\    float x = (aPos.x / max(uScreen.x, 1.0)) * 2.0 - 1.0;
    \\    float y = 1.0 - (aPos.y / max(uScreen.y, 1.0)) * 2.0;
    \\    gl_Position = vec4(x, y, 0.0, 1.0);
    \\    vColor = aColor;
    \\}
;

pub const ui_frag =
    \\#version 300 es
    \\precision mediump float;
    \\in vec4 vColor;
    \\out vec4 FragColor;
    \\void main() {
    \\    FragColor = vColor;
    \\}
;
