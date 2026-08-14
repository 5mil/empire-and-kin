//! Phase 5 — pure-Zig raycast vehicle physics (no PhysX).
//! Flat-ground model: suspension vs y=0, lateral grip curve, body pitch/roll.

const std = @import("std");
const action = @import("action.zig");
const vehicle_def = @import("vehicle_def.zig");
const collision = @import("collision.zig");

pub const PhysTuning = struct {
    mass: f32,
    power: f32, // N along forward at full throttle
    brake_force: f32,
    max_steer: f32, // rad
    grip: f32, // lateral friction coefficient scale
    drag: f32, // quadratic air drag
    rolling_resist: f32,
    spring_k: f32,
    damper_c: f32,
    rest_len: f32, // suspension rest length (body height offset)
    max_travel: f32,
    wheelbase: f32,
    track: f32,
    cg_height: f32,
    yaw_inertia: f32,
    assist: f32, // 0..1 arcade steering assist
};

pub fn tuningFor(vtype: action.VehicleType) PhysTuning {
    return switch (vtype) {
        .sedan => .{
            .mass = 1200,
            .power = 9200,
            .brake_force = 14000,
            .max_steer = 0.55,
            .grip = 1.05,
            .drag = 0.42,
            .rolling_resist = 180,
            .spring_k = 28000,
            .damper_c = 3200,
            .rest_len = 0.42,
            .max_travel = 0.28,
            .wheelbase = 2.1,
            .track = 1.5,
            .cg_height = 0.55,
            .yaw_inertia = 1800,
            .assist = 0.55,
        },
        .taxi => .{
            .mass = 1250,
            .power = 8800,
            .brake_force = 13500,
            .max_steer = 0.52,
            .grip = 1.0,
            .drag = 0.45,
            .rolling_resist = 190,
            .spring_k = 27000,
            .damper_c = 3100,
            .rest_len = 0.42,
            .max_travel = 0.28,
            .wheelbase = 2.15,
            .track = 1.5,
            .cg_height = 0.55,
            .yaw_inertia = 1900,
            .assist = 0.5,
        },
        .truck => .{
            .mass = 2800,
            .power = 11000,
            .brake_force = 20000,
            .max_steer = 0.42,
            .grip = 0.85,
            .drag = 0.7,
            .rolling_resist = 320,
            .spring_k = 42000,
            .damper_c = 4800,
            .rest_len = 0.55,
            .max_travel = 0.35,
            .wheelbase = 2.6,
            .track = 1.85,
            .cg_height = 0.85,
            .yaw_inertia = 4500,
            .assist = 0.4,
        },
        .motorcycle => .{
            .mass = 220,
            .power = 6500,
            .brake_force = 5000,
            .max_steer = 0.7,
            .grip = 1.15,
            .drag = 0.28,
            .rolling_resist = 40,
            .spring_k = 12000,
            .damper_c = 900,
            .rest_len = 0.38,
            .max_travel = 0.22,
            .wheelbase = 1.4,
            .track = 0.05,
            .cg_height = 0.5,
            .yaw_inertia = 120,
            .assist = 0.35,
        },
    };
}

/// One integration step. throttle/steer_in in [-1,1]. handbrake reduces rear grip.
pub fn integrate(
    v: *action.Vehicle,
    throttle: f32,
    steer_in: f32,
    handbrake: bool,
    dt64: f64,
) void {
    if (!v.occupied) return;
    const dt: f32 = @floatCast(dt64);
    if (dt <= 0 or dt > 0.1) return;

    const t = tuningFor(v.vtype);
    const wl = vehicle_def.wheelsFor(v.vtype);

    // --- Steering (speed-sensitive) ---
    const speed = @sqrt(v.vx * v.vx + v.vz * v.vz);
    const speed_factor = 1.0 / (1.0 + speed * 0.08);
    const target_steer = std.math.clamp(steer_in, -1.0, 1.0) * t.max_steer * speed_factor;
    v.steer += (target_steer - v.steer) * @min(1.0, 10.0 * dt);

    // Forward / right in XZ (yaw: 0 = +X)
    const cy = @cos(v.yaw);
    const sy = @sin(v.yaw);
    const fwd_x = cy;
    const fwd_z = sy;
    const right_x = -sy;
    const right_z = cy;

    // Body-frame velocity
    const v_long = v.vx * fwd_x + v.vz * fwd_z;
    const v_lat = v.vx * right_x + v.vz * right_z;

    // --- Longitudinal forces ---
    var f_long: f32 = 0;
    const thr = std.math.clamp(throttle, -1.0, 1.0);
    if (thr > 0.05) {
        // power fades at high speed
        const fade = @max(0.15, 1.0 - speed / (v.max_speed * 1.15));
        f_long += thr * t.power * fade;
    } else if (thr < -0.05) {
        f_long += thr * t.brake_force; // reverse / engine brake feel
    }
    // Foot brake when releasing throttle at speed (mild)
    if (@abs(thr) < 0.08 and speed > 0.5) {
        f_long -= std.math.sign(v_long) * t.rolling_resist * 0.6;
    }
    f_long -= std.math.sign(v_long) * t.rolling_resist;
    f_long -= t.drag * v_long * @abs(v_long);

    // --- Lateral grip (slip angle proxy) ---
    var rear_grip = t.grip;
    var front_grip = t.grip;
    if (handbrake) {
        rear_grip *= 0.28;
        // slight front boost so car rotates into slide
        front_grip *= 1.05;
    }
    // Pacejka-ish clamp: force vs lateral speed
    const lat_slip = v_lat;
    const max_lat_f = t.mass * 9.81 * ((front_grip + rear_grip) * 0.5);
    var f_lat = -lat_slip * t.mass * 8.0 * ((front_grip + rear_grip) * 0.5);
    f_lat = std.math.clamp(f_lat, -max_lat_f, max_lat_f);

    // Steering yaw torque from front lateral + assist
    const steer_yaw = v.steer * (0.6 + t.assist) * (1.0 + speed * 0.15);
    // Oversteer when rear grip low and lat speed high
    const oversteer = if (handbrake) lat_slip * 0.35 else lat_slip * 0.05;
    var yaw_accel = (steer_yaw * speed * 0.55 - oversteer * 2.5 - v.yaw_rate * 2.2) / (t.yaw_inertia / t.mass);
    // clamp wild spin
    yaw_accel = std.math.clamp(yaw_accel, -8.0, 8.0);

    // World force
    const fx = fwd_x * f_long + right_x * f_lat;
    const fz = fwd_z * f_long + right_z * f_lat;

    v.vx += (fx / t.mass) * dt;
    v.vz += (fz / t.mass) * dt;
    v.yaw_rate += yaw_accel * dt;
    v.yaw_rate *= @max(0.0, 1.0 - 1.8 * dt); // yaw damping
    v.yaw += v.yaw_rate * dt;
    // normalize yaw
    if (v.yaw > std.math.pi) v.yaw -= 2.0 * std.math.pi;
    if (v.yaw < -std.math.pi) v.yaw += 2.0 * std.math.pi;

    // --- Suspension (4 rays vs ground y=0) for pitch/roll + body_y ---
    // Wheel local mounts (approx from layout)
    const mounts = [_][2]f32{
        .{ wl.fl[0], wl.fl[2] },
        .{ wl.fr[0], wl.fr[2] },
        .{ wl.rl[0], wl.rl[2] },
        .{ wl.rr[0], wl.rr[2] },
    };
    var spring_force_total: f32 = 0;
    var pitch_torque: f32 = 0;
    var roll_torque: f32 = 0;
    var grounded_n: f32 = 0;
    var wi: usize = 0;
    while (wi < 4) : (wi += 1) {
        // world mount height ≈ body_y + rest (ignore full 3D transform for flat world)
        const local_x = mounts[wi][0];
        const local_z = mounts[wi][1];
        const mount_y = v.body_y + t.rest_len;
        // ray down: compression = how much spring is squashed
        const ground_y: f32 = 0.0;
        const ray_hit = mount_y - ground_y;
        const compression = std.math.clamp(t.rest_len + t.max_travel - ray_hit, 0.0, t.max_travel + t.rest_len);
        const grounded = ray_hit < (t.rest_len + t.max_travel);
        if (grounded) {
            grounded_n += 1;
            const spring_f = compression * t.spring_k;
            const damp_f = -v.vy * t.damper_c;
            const f = spring_f + damp_f;
            spring_force_total += f;
            // pitch: front positive local_z → nose up when front compressed more
            pitch_torque += f * local_z;
            roll_torque += f * (-local_x);
        }
    }
    if (grounded_n > 0) {
        v.vy += ((spring_force_total / t.mass) - 9.81) * dt;
    } else {
        v.vy -= 9.81 * dt;
    }
    v.body_y += v.vy * dt;
    // hard floor
    if (v.body_y < 0.05) {
        v.body_y = 0.05;
        if (v.vy < 0) v.vy = 0;
    }
    if (v.body_y > t.rest_len + t.max_travel) {
        v.body_y = t.rest_len + t.max_travel;
        if (v.vy > 0) v.vy *= 0.3;
    }

    // Visual pitch/roll (smoothed)
    const target_pitch = std.math.clamp(-pitch_torque / (t.mass * 40.0) - thr * 0.04 + (if (thr < -0.3) -0.06 else 0.0), -0.18, 0.14);
    const target_roll = std.math.clamp(roll_torque / (t.mass * 35.0) + v.yaw_rate * 0.08, -0.22, 0.22);
    v.pitch += (target_pitch - v.pitch) * @min(1.0, 8.0 * dt);
    v.roll += (target_roll - v.roll) * @min(1.0, 8.0 * dt);

    // --- Integrate position + collision ---
    const dx = v.vx * dt;
    const dz = v.vz * dt;
    const resolved = collision.resolveMove(v.x, v.y, dx, dz, 1.15);
    if (resolved.x == v.x and resolved.z == v.y and (dx * dx + dz * dz) > 1e-6) {
        // hit wall: bounce + damage
        v.vx *= -0.25;
        v.vz *= -0.25;
        v.yaw_rate *= 0.5;
        if (v.health > 3) v.health -= 2;
        // small bounce impulse outward not needed; velocity flip is enough
    } else if (@abs(resolved.x - (v.x + dx)) > 0.001 or @abs(resolved.z - (v.y + dz)) > 0.001) {
        // sliding along wall — kill component into wall
        v.vx *= 0.7;
        v.vz *= 0.7;
        if (v.health > 0 and speed > 4.0) v.health -|= 1;
    }
    v.x = resolved.x;
    v.y = resolved.z;

    // Sync legacy speed + wheel spin
    v.speed = @sqrt(v.vx * v.vx + v.vz * v.vz);
    // cap soft
    if (v.speed > v.max_speed * 1.2) {
        const s = (v.max_speed * 1.2) / v.speed;
        v.vx *= s;
        v.vz *= s;
        v.speed = v.max_speed * 1.2;
    }
    const radius = wl.radius;
    v.wheel_spin += (v_long / radius) * dt;
}

/// Map WASD-style move vector to throttle + steer for driving.
pub fn inputsFromMove(move_x: f32, move_y: f32) struct { throttle: f32, steer: f32 } {
    return .{ .throttle = std.math.clamp(move_y, -1.0, 1.0), .steer = std.math.clamp(move_x, -1.0, 1.0) };
}
