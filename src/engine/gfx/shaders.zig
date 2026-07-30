//! GLSL 330 core — lit + fog + grain + optional albedo sample (Phase 1 textures).

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
    \\float hash(vec2 p) {
    \\    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
    \\}
    \\float noise(vec2 p) {
    \\    vec2 i = floor(p);
    \\    vec2 f = fract(p);
    \\    float a = hash(i);
    \\    float b = hash(i + vec2(1.0, 0.0));
    \\    float c = hash(i + vec2(0.0, 1.0));
    \\    float d = hash(i + vec2(1.0, 1.0));
    \\    vec2 u = f * f * (3.0 - 2.0 * f);
    \\    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
    \\}
    \\float fbm(vec2 p) {
    \\    float v = 0.0;
    \\    float a = 0.5;
    \\    for (int i = 0; i < 4; i++) {
    \\        v += a * noise(p);
    \\        p *= 2.05;
    \\        a *= 0.5;
    \\    }
    \\    return v;
    \\}
    \\void main() {
    \\    vec3 n = normalize(vNormal);
    \\    float ndl = max(dot(n, normalize(-uLightDir)), 0.0);
    \\    float half_lambert = ndl * 0.5 + 0.5;
    \\    float rim = pow(1.0 - max(dot(n, normalize(uCamPos - vWorldPos)), 0.0), 3.0) * 0.14;
    \\    vec3 an = abs(n);
    \\    float s = max(uUvScale, 0.05);
    \\    vec2 uv_y = vWorldPos.xz * s;
    \\    vec2 uv_x = vWorldPos.zy * s;
    \\    vec2 uv_z = vWorldPos.xy * s;
    \\    float ax = an.x; float ay = an.y; float az = an.z;
    \\    float sum = ax + ay + az + 1e-4;
    \\    ax /= sum; ay /= sum; az /= sum;
    \\    vec3 tex = vec3(1.0);
    \\    if (uUseTexture != 0) {
    \\        vec3 tx = texture(uAlbedo, uv_x).rgb;
    \\        vec3 ty = texture(uAlbedo, uv_y).rgb;
    \\        vec3 tz = texture(uAlbedo, uv_z).rgb;
    \\        tex = tx * ax + ty * ay + tz * az;
    \\    }
    \\    float g = fbm(vWorldPos.xz * 1.8) * 0.06 + noise(vWorldPos.xz * 11.0) * 0.03;
    \\    float streak = noise(vec2(vWorldPos.x * 0.35, vWorldPos.z * 4.5)) * 0.02;
    \\    vec3 base = tex * vColor.rgb * uTint.rgb * (1.0 + g + streak);
    \\    float gloss_hint = smoothstep(0.35, 0.75, length(base));
    \\    float spec = pow(max(dot(reflect(normalize(uLightDir), n), normalize(uCamPos - vWorldPos)), 0.0), 24.0) * 0.10 * gloss_hint;
    \\    vec3 lit = base * (uAmbient + vec3(half_lambert * 0.90)) + vec3(rim + spec);
    \\    float dist = length(vWorldPos - uCamPos);
    \\    float fog = clamp(1.0 - exp(-uFogDensity * dist), 0.0, 0.88);
    \\    vec3 color = mix(lit, uFogColor, fog);
    \\    FragColor = vec4(color, vColor.a * uTint.a);
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
    \\void main() {
    \\    FragColor = vColor;
    \\}
;
