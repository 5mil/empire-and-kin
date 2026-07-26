const std = @import("std");
const backend = @import("backend.zig");
const action = @import("../game/action.zig");
const missions = @import("../game/missions.zig");
const player = @import("../game/player.zig");
const economy = @import("../game/economy.zig");
const city = @import("../game/city.zig");
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

/// Returns payout if job just completed this tick.
pub fn tickJob(job: *ActiveJob, p: *player.Player, eco: *economy.Economy, district: *city.District, dt: f64) u32 {
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
    job.progress += @as(f32, @floatCast(dt)) / job.duration;
    if (job.progress < 1.0) return 0;
    job.progress = 1.0;
    job.state = .done;
    job.world.active = false;
    job.respawn_timer = 12.0; // real-seconds until next offer
    const pay = missions.completeMission(&job.world.mission);
    eco.treasury += pay;
    const heat_add: u8 = @min(25, job.world.mission.risk * 3);
    district.heat = @min(100, district.heat + heat_add);
    if (job.world.mission.risk >= 6) wanted_ui.addWanted(p, 1);
    if (job.world.mission.risk >= 8) wanted_ui.addWanted(p, 1);
    return pay;
}

pub fn drawMarker(gfx: backend.Backend, job: ActiveJob, p: player.Player) void {
    if (job.state == .done) return;
    const col = switch (job.state) {
        .available => backend.Color.rgb(80, 200, 255),
        .in_progress => backend.Color.rgb(255, 200, 60),
        .done => backend.Color.rgb(80, 80, 80),
    };
    gfx.drawBox(.{ .x = job.world.x, .y = 1.5, .z = job.world.y }, 1.2, 2.4, 1.2, col);
    if (nearMarker(job, p) or job.state == .in_progress) {
        var buf: [96]u8 = undefined;
        if (job.state == .available) {
            const line = std.fmt.bufPrint(&buf, "[E] {s}  ${d}  risk {d}", .{ job.world.mission.name, job.world.mission.reward_cash, job.world.mission.risk }) catch "";
            gfx.drawText(line, 10, 300, backend.Color.rgb(120, 220, 255));
        } else {
            const pct: u32 = @intFromFloat(@min(100.0, job.progress * 100.0));
            const line = std.fmt.bufPrint(&buf, "Working: {s}  {d}%", .{ job.world.mission.name, pct }) catch "";
            gfx.drawText(line, 10, 300, backend.Color.rgb(255, 200, 80));
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
        const line = std.fmt.bufPrint(&buf, "Nearest job ({d:.0},{d:.0})  d={d:.0}", .{ j.world.x, j.world.y, @sqrt(best_d) }) catch "";
        gfx.drawText(line, 10, 318, backend.Color.rgb(160, 180, 200));
    } else {
        gfx.drawText("Jobs refreshing...", 10, 318, backend.Color.rgb(120, 120, 120));
    }
}
