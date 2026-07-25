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
};

pub fn spawnJob(id: u32, mtype: missions.MissionType, x: f32, y: f32) ActiveJob {
    return .{
        .world = .{ .mission = missions.generateMission(id, mtype), .x = x, .y = y, .radius = 6.0, .active = true },
        .state = .available,
        .progress = 0,
        .duration = switch (mtype) {
            .bootlegging => 3.5,
            .protection => 3.0,
            .smuggling => 5.0,
            .hit => 6.0,
            .heist => 8.0,
        },
    };
}

pub fn nearMarker(job: ActiveJob, p: player.Player) bool {
    return action.canStartMission(job.world, p) and job.state != .done;
}

pub fn tryStart(job: *ActiveJob, p: player.Player) bool {
    if (job.state != .available) return false;
    if (!action.canStartMission(job.world, p)) return false;
    job.state = .in_progress;
    job.progress = 0;
    return true;
}

pub fn tickJob(job: *ActiveJob, p: *player.Player, eco: *economy.Economy, district: *city.District, dt: f64) u32 {
    if (job.state != .in_progress) return 0;
    job.progress += @as(f32, @floatCast(dt)) / job.duration;
    if (job.progress < 1.0) return 0;
    job.progress = 1.0;
    job.state = .done;
    job.world.active = false;
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
    gfx.drawBox(.{ .x = job.world.x, .y = 1.5, .z = job.world.y }, 1.5, 3.0, 1.5, col);
    if (nearMarker(job, p) or job.state == .in_progress) {
        var buf: [96]u8 = undefined;
        if (job.state == .available) {
            const line = std.fmt.bufPrint(&buf, "[E] Job: {s}  (${d}  risk {d})", .{ job.world.mission.name, job.world.mission.reward_cash, job.world.mission.risk }) catch "";
            gfx.drawText(line, 10, 290, backend.Color.rgb(120, 220, 255));
        } else {
            const pct: u32 = @intFromFloat(job.progress * 100.0);
            const line = std.fmt.bufPrint(&buf, "Job in progress: {s}  {d}%", .{ job.world.mission.name, pct }) catch "";
            gfx.drawText(line, 10, 290, backend.Color.rgb(255, 200, 80));
        }
    }
}

pub fn drawMinimapHint(gfx: backend.Backend, job: ActiveJob, p: player.Player) void {
    if (job.state == .done) {
        gfx.drawText("No active jobs", 10, 308, backend.Color.rgb(120, 120, 120));
        return;
    }
    var buf: [64]u8 = undefined;
    const line = std.fmt.bufPrint(&buf, "Job marker: ({d:.0}, {d:.0})  delta ({d:.0}, {d:.0})", .{ job.world.x, job.world.y, job.world.x - p.x, job.world.y - p.y }) catch "";
    gfx.drawText(line, 10, 308, backend.Color.rgb(160, 180, 200));
}
