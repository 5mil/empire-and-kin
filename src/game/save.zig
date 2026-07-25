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
    valid: bool = false,
};

var slot: SaveData = .{};

pub fn capture(eco: economy.Economy, c: crew.Crew, clock: time.Clock, p: player.Player, districts: []const city.District) SaveData {
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
    slot = .{ .day = clock.day, .time_of_day = clock.time_of_day, .treasury = eco.treasury, .influence = eco.total_influence, .crew_cash = c.cash, .crew_morale = c.morale, .crew_count = c.count, .valid = true };
}

pub fn saveFull(eco: economy.Economy, c: crew.Crew, clock: time.Clock, p: player.Player, districts: []const city.District) void {
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

pub fn writeToDisk(data: SaveData) !void {
    const file = try std.fs.cwd().createFile(SAVE_PATH, .{});
    defer file.close();
    var buf: [512]u8 = undefined;
    const body = try std.fmt.bufPrint(&buf,
        \\# Empire & Kin save\nday={d}\ntime_of_day={d}\ntreasury={d}\ninfluence={d}\ncrew_cash={d}\ncrew_morale={d}\ncrew_count={d}\nplayer_x={d}\nplayer_y={d}\nplayer_health={d}\nplayer_wanted={d}\ndistrict_heat0={d}\ndistrict_control0={d}\n
    , .{ data.day, data.time_of_day, data.treasury, data.influence, data.crew_cash, data.crew_morale, data.crew_count, data.player_x, data.player_y, data.player_health, data.player_wanted, data.district_heat0, data.district_control0 });
    try file.writeAll(body);
    slot = data;
    slot.valid = true;
}

pub fn readFromDisk() !?SaveData {
    const file = std.fs.cwd().openFile(SAVE_PATH, .{}) catch return null;
    defer file.close();
    var buf: [1024]u8 = undefined;
    const n = try file.readAll(&buf);
    const text = buf[0..n];
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
        }
    }
    slot = data;
    return data;
}

pub fn applyTo(data: SaveData, eco: *economy.Economy, c: *crew.Crew, clock: *time.Clock, p: *player.Player, districts: []city.District) void {
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
