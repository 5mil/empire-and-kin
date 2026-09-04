//! GLSL 330 — lit + fog + triplanar albedo + 2 street lamps + window glow.

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
    \\uniform vec4 uTint;
    \\uniform vec3 uFogColor;
    \\uniform float uFogDensity;
    \\uniform vec3 uCamPos;
    \\uniform sampler2D uAlbedo;
    \\uniform int uUseTexture;
    \\uniform float uUvScale;
    \\out vec4 FragColor;
    \\float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
    \\float noise(vec2 p) {
    \\    vec2 i = floor(p); vec2 f = fract(p);
    \\    float a = hash(i); float b = hash(i + vec2(1.0, 0.0));
    \\    float c = hash(i + vec2(0.0, 1.0)); float d = hash(i + vec2(1.0, 1.0));
    \\    vec2 u = f * f * (3.0 - 2.0 * f);
    \\    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
    \\}
    \\float lampAtten(vec3 pos, vec3 lamp, float range) {
    \\    float d = length(pos - lamp);
    \\    float a = 1.0 - clamp(d / range, 0.0, 1.0);
    \\    return a * a;
    \\}
    \\void main() {
    \\    vec3 n = normalize(vNormal);
    \\    float ndl = max(dot(n, normalize(-uLightDir)), 0.0);
    \\    float half_lambert = ndl * 0.5 + 0.5;
    \\    float rim = pow(1.0 - max(dot(n, normalize(uCamPos - vWorldPos)), 0.0), 3.0) * 0.14;
    \\    vec3 an = abs(n);
    \\    float s = max(uUvScale, 0.05);
    \\    float sum = an.x + an.y + an.z + 1e-4;
    \\    vec3 tex = vec3(1.0);
    \\    if (uUseTexture != 0) {
    \\        tex = texture(uAlbedo, vWorldPos.zy * s).rgb * (an.x / sum)
    \\            + texture(uAlbedo, vWorldPos.xz * s).rgb * (an.y / sum)
    \\            + texture(uAlbedo, vWorldPos.xy * s).rgb * (an.z / sum);
    \\    }
    \\    float g = noise(vWorldPos.xz * 11.0) * 0.04;
    \\    vec3 base = tex * vColor.rgb * uTint.rgb * (1.0 + g);
    \\    float spec = pow(max(dot(reflect(normalize(uLightDir), n), normalize(uCamPos - vWorldPos)), 0.0), 24.0) * 0.08;
    \\    vec3 lamp_col = vec3(1.0, 0.82, 0.55);
    \\    float lamps = lampAtten(vWorldPos, vec3(6.0, 5.4, 18.0), 16.0)
    \\               + lampAtten(vWorldPos, vec3(22.0, 5.4, 22.0), 16.0)
    \\               + lampAtten(vWorldPos, vec3(14.0, 5.4, 14.0), 14.0)
    \\               + lampAtten(vWorldPos, vec3(8.0, 5.4, 26.0), 14.0);
    \\    float night = 1.0 - clamp((uAmbient.x - 0.28) / 0.32, 0.0, 1.0);
    \\    vec3 point = lamp_col * lamps * (0.35 + 0.85 * night);
    \\    float win = 0.0;
    \\    if (abs(n.y) < 0.45) {
    \\        float cellx = fract(vWorldPos.x * 0.42 + vWorldPos.z * 0.11);
    \\        float celly = fract(vWorldPos.y * 0.38);
    \\        float pane = step(0.22, cellx) * step(cellx, 0.78) * step(0.28, celly) * step(celly, 0.82);
    \\        float litw = step(0.55, hash(floor(vec2(vWorldPos.x, vWorldPos.y) * 0.4)));
    \\        win = pane * litw * (0.25 + 0.55 * night);
    \\    }
    \\    vec3 lit = base * (uAmbient + vec3(half_lambert * 0.88) + point) + vec3(rim + spec) + lamp_col * win;
    \\    float dist = length(vWorldPos - uCamPos);
    \\    float fog = clamp(1.0 - exp(-uFogDensity * dist), 0.0, 0.88);
    \\    FragColor = vec4(mix(lit, uFogColor, fog), vColor.a * uTint.a);
    \\}
;

pub const ui_vert =
    \\#version 330 core
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
    \\#version 330 core
    \\in vec4 vColor;
    \\out vec4 FragColor;
    \\void main() { FragColor = vColor; }
;
