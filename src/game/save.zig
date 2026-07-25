const std = @import("std");
const economy = @import("economy.zig");
const crew = @import("crew.zig");
const time = @import("time.zig");
const player = @import("player.zig");
const city = @import("city.zig");

pub const SAVE_PATH = "empire_save.txt";

pub const SaveData = struct {
    day: u32 = 1,
    time_of_day: f64 = 8 * 3600,
    treasury: u32 = 0,
    influence: u32 = 0,
    crew_cash: u32 = 0,
    crew_morale: u8 = 50,
    crew_count: u8 = 0,
    player_x: f32 = 10,
    player_y: f32 = 20,
    player_health: u8 = 100,
    player_wanted: u8 = 0,
    district_heat0: u8 = 0,
    district_control0: u8 = 0,
    era_id: u8 = 0,
    valid: bool = false,
};

var slot: SaveData = .{};

pub fn capture(
    eco: economy.Economy,
    c: crew.Crew,
    clock: time.Clock,
    p: player.Player,
    districts: []const city.District,
) SaveData {
    var s: SaveData = .{
        .day = clock.day,
        .time_of_day = clock.time_of_day,
        .treasury = eco.treasury,
        .influence = eco.total_influence,
        .crew_cash = c.cash,
        .crew_morale = c.morale,
        .crew_count = c.count,
        .player_x = p.x,
        .player_y = p.y,
        .player_health = p.health,
        .player_wanted = p.wanted_level,
        .valid = true,
    };
    if (districts.len > 0) {
        s.district_heat0 = districts[0].heat;
        s.district_control0 = districts[0].control;
    }
    return s;
}

pub fn saveGame(eco: economy.Economy, c: crew.Crew, clock: time.Clock) void {
    slot = .{
        .day = clock.day,
        .time_of_day = clock.time_of_day,
        .treasury = eco.treasury,
        .influence = eco.total_influence,
        .crew_cash = c.cash,
        .crew_morale = c.morale,
        .crew_count = c.count,
        .valid = true,
    };
}

pub fn saveFull(
    eco: economy.Economy,
    c: crew.Crew,
    clock: time.Clock,
    p: player.Player,
    districts: []const city.District,
) void {
    slot = capture(eco, c, clock, p, districts);
}

pub fn loadGame() ?SaveData {
    if (!slot.valid) return null;
    return slot;
}

pub fn hasSave() bool {
    return slot.valid;
}

pub fn clearSave() void {
    slot.valid = false;
}

pub fn writeToDisk(io: std.Io, data: SaveData) !void {
    const cwd = std.Io.Dir.cwd();
    const file = try cwd.createFile(io, SAVE_PATH, .{});
    defer file.close(io);

    var buf: [512]u8 = undefined;
    const body = try std.fmt.bufPrint(&buf,
        \\# Empire & Kin save
        \\day={d}
        \\time_of_day={d}
        \\treasury={d}
        \\influence={d}
        \\crew_cash={d}
        \\crew_morale={d}
        \\crew_count={d}
        \\player_x={d}
        \\player_y={d}
        \\player_health={d}
        \\player_wanted={d}
        \\district_heat0={d}
        \\district_control0={d}
        \\era_id={d}
        \\
    , .{
        data.day,
        data.time_of_day,
        data.treasury,
        data.influence,
        data.crew_cash,
        data.crew_morale,
        data.crew_count,
        data.player_x,
        data.player_y,
        data.player_health,
        data.player_wanted,
        data.district_heat0,
        data.district_control0,
        data.era_id,
    });

    // Simple whole-buffer write via File writer
    var wbuf: [512]u8 = undefined;
    var writer = file.writer(io, &wbuf);
    try writer.interface.writeAll(body);
    try writer.interface.flush();

    slot = data;
    slot.valid = true;
}

pub fn readFromDisk(io: std.Io) !?SaveData {
    const cwd = std.Io.Dir.cwd();
    var buf: [1024]u8 = undefined;
    const text = cwd.readFile(io, SAVE_PATH, &buf) catch return null;

    var data: SaveData = .{ .valid = true };
    var lines = std.mem.splitScalar(u8, text, '\n');
    while (lines.next()) |line| {
        if (line.len == 0 or line[0] == '#') continue;
        if (std.mem.indexOfScalar(u8, line, '=')) |eq| {
            const key = line[0..eq];
            const val = line[eq + 1 ..];
            if (std.mem.eql(u8, key, "day")) data.day = std.fmt.parseInt(u32, val, 10) catch data.day;
            if (std.mem.eql(u8, key, "time_of_day")) data.time_of_day = std.fmt.parseFloat(f64, val) catch data.time_of_day;
            if (std.mem.eql(u8, key, "treasury")) data.treasury = std.fmt.parseInt(u32, val, 10) catch data.treasury;
            if (std.mem.eql(u8, key, "influence")) data.influence = std.fmt.parseInt(u32, val, 10) catch data.influence;
            if (std.mem.eql(u8, key, "crew_cash")) data.crew_cash = std.fmt.parseInt(u32, val, 10) catch data.crew_cash;
            if (std.mem.eql(u8, key, "crew_morale")) data.crew_morale = std.fmt.parseInt(u8, val, 10) catch data.crew_morale;
            if (std.mem.eql(u8, key, "crew_count")) data.crew_count = std.fmt.parseInt(u8, val, 10) catch data.crew_count;
            if (std.mem.eql(u8, key, "player_x")) data.player_x = std.fmt.parseFloat(f32, val) catch data.player_x;
            if (std.mem.eql(u8, key, "player_y")) data.player_y = std.fmt.parseFloat(f32, val) catch data.player_y;
            if (std.mem.eql(u8, key, "player_health")) data.player_health = std.fmt.parseInt(u8, val, 10) catch data.player_health;
            if (std.mem.eql(u8, key, "player_wanted")) data.player_wanted = std.fmt.parseInt(u8, val, 10) catch data.player_wanted;
            if (std.mem.eql(u8, key, "district_heat0")) data.district_heat0 = std.fmt.parseInt(u8, val, 10) catch data.district_heat0;
            if (std.mem.eql(u8, key, "district_control0")) data.district_control0 = std.fmt.parseInt(u8, val, 10) catch data.district_control0;
            if (std.mem.eql(u8, key, "era_id")) data.era_id = std.fmt.parseInt(u8, val, 10) catch data.era_id;
        }
    }
    slot = data;
    return data;
}

pub fn applyTo(
    data: SaveData,
    eco: *economy.Economy,
    c: *crew.Crew,
    clock: *time.Clock,
    p: *player.Player,
    districts: []city.District,
) void {
    clock.day = data.day;
    clock.time_of_day = data.time_of_day;
    eco.treasury = data.treasury;
    eco.total_influence = data.influence;
    c.cash = data.crew_cash;
    c.morale = data.crew_morale;
    p.x = data.player_x;
    p.y = data.player_y;
    p.health = data.player_health;
    p.wanted_level = data.player_wanted;
    if (districts.len > 0) {
        districts[0].heat = data.district_heat0;
        districts[0].control = data.district_control0;
    }
}
