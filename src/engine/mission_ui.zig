const std = @import("std");
const backend = @import("backend.zig");
const action = @import("../game/action.zig");
const missions = @import("../game/missions.zig");
const player = @import("../game/player.zig");
const economy = @import("../game/economy.zig");
const city = @import("../game/city.zig");
const empire = @import("../game/empire.zig");
const wanted_ui = @import("wanted_ui.zig");

pub const JobState = enum { available, in_progress, done };

pub const ActiveJob = struct {
    world: action.WorldMission,
    state: JobState = .available,
    progress: f32 = 0,
    duration: f32 = 4.0,
    respawn_timer: f32 = 0,
};

pub fn spawnJob(id: u32, mtype: missions.MissionType, x: f32, y: f32) ActiveJob {
    return .{
        .world = .{ .mission = missions.generateMission(id, mtype), .x = x, .y = y, .radius = 5.5, .active = true },
        .state = .available,
        .progress = 0,
        .duration = switch (mtype) {
            .bootlegging => 3.5,
            .protection => 3.0,
            .smuggling => 5.0,
            .hit => 6.0,
            .heist => 8.0,
        },
        .respawn_timer = 0,
    };
}

pub fn nearMarker(job: ActiveJob, p: player.Player) bool {
    return action.canStartMission(job.world, p) and job.state == .available;
}

pub fn inRadius(job: ActiveJob, p: player.Player) bool {
    const dx = p.x - job.world.x;
    const dy = p.y - job.world.y;
    const r = job.world.radius + 2.0;
    return dx * dx + dy * dy <= r * r;
}

pub fn anyNear(jobs: []const ActiveJob, p: player.Player) bool {
    for (jobs) |j| {
        if (nearMarker(j, p) or j.state == .in_progress) return true;
    }
    return false;
}

pub fn tryStart(job: *ActiveJob, p: player.Player) bool {
    if (job.state != .available) return false;
    if (!action.canStartMission(job.world, p)) return false;
    job.state = .in_progress;
    job.progress = 0;
    return true;
}

/// Returns payout when job completes. Reputation boosts pay. Leaving radius cancels.
pub fn tickJob(job: *ActiveJob, p: *player.Player, eco: *economy.Economy, district: *city.District, emp: empire.Empire, dt: f64) u32 {
    _ = eco;
    if (job.state == .done) {
        job.respawn_timer -= @as(f32, @floatCast(dt));
        if (job.respawn_timer <= 0) {
            job.state = .available;
            job.progress = 0;
            job.world.active = true;
            job.world.mission.completed = false;
        }
        return 0;
    }
    if (job.state != .in_progress) return 0;

    // Cancel if player leaves area
    if (!inRadius(job.*, p.*)) {
        job.state = .available;
        job.progress = 0;
        job.world.active = true;
        return 0;
    }

    job.progress += @as(f32, @floatCast(dt)) / job.duration;
    if (job.progress < 1.0) return 0;
    job.progress = 1.0;
    job.state = .done;
    job.world.active = false;
    job.respawn_timer = 10.0;
    var pay = missions.completeMission(&job.world.mission);
    // Reputation bonus up to +25%
    if (emp.reputation > 0) {
        const bonus = @as(u32, @intCast(@min(25, emp.reputation))) * pay / 100;
        pay += bonus;
    }
    const heat_add: u8 = @min(20, job.world.mission.risk * 2);
    district.heat = @min(100, district.heat + heat_add);
    if (job.world.mission.risk >= 6) wanted_ui.addWanted(p, 1);
    if (job.world.mission.risk >= 8) wanted_ui.addWanted(p, 1);
    return pay;
}

pub fn drawMarker(gfx: backend.Backend, job: ActiveJob, p: player.Player) void {
    if (job.state == .done) return;
    if (nearMarker(job, p) or job.state == .in_progress) {
        var buf: [96]u8 = undefined;
        if (job.state == .available) {
            const line = std.fmt.bufPrint(&buf, "[E] {s}  ${d}  risk {d}", .{ job.world.mission.name, job.world.mission.reward_cash, job.world.mission.risk }) catch "";
            gfx.drawText(line, 10, 360, backend.Color.rgb(120, 230, 255));
        } else {
            const pct: u32 = @intFromFloat(@min(100.0, job.progress * 100.0));
            const line = std.fmt.bufPrint(&buf, "Working: {s}  {d}%  (stay near)", .{ job.world.mission.name, pct }) catch "";
            gfx.drawText(line, 10, 360, backend.Color.rgb(255, 210, 90));
        }
    }
}

pub fn drawMinimapHint(gfx: backend.Backend, jobs: []const ActiveJob, p: player.Player) void {
    var best: ?ActiveJob = null;
    var best_d: f32 = 1e9;
    for (jobs) |j| {
        if (j.state == .done) continue;
        const dx = j.world.x - p.x;
        const dy = j.world.y - p.y;
        const d = dx * dx + dy * dy;
        if (d < best_d) {
            best_d = d;
            best = j;
        }
    }
    if (best) |j| {
        var buf: [72]u8 = undefined;
        const line = std.fmt.bufPrint(&buf, "Nearest job d={d:.0}", .{@sqrt(best_d)}) catch "";
        gfx.drawText(line, 10, 378, backend.Color.rgb(160, 180, 200));
        _ = j;
    } else {
        gfx.drawText("Jobs refreshing...", 10, 378, backend.Color.rgb(120, 120, 120));
    }
}
