const std = @import("std");
const crew = @import("crew.zig");
const economy = @import("economy.zig");
const city = @import("city.zig");
const player = @import("player.zig");
const time = @import("time.zig");
const world = @import("world.zig");

/// Extremely simple text-based pause / empire menu.
/// Later this becomes a real overlay in Magister/Arcis.
pub const PauseMenu = struct {
    open: bool = false,
};

pub fn toggle(menu: *PauseMenu) void {
    menu.open = !menu.open;
}

pub fn drawEmpireOverview(
    p: player.Player,
    c: crew.Crew,
    eco: economy.Economy,
    districts: []const city.District,
    clock: time.Clock,
) void {
    std.debug.print("\n========== EMPIRE MENU (PAUSED) ==========\n", .{});
    std.debug.print("Boss: {s}   |  Location: {s}\n", .{ p.name, world.districtName(p.current_district) });
    std.debug.print("Health: {d}   Wanted: {d}\n", .{ p.health, p.wanted_level });
    std.debug.print("Time: Day {d}  {d:0>2}:{d:0>2}\n", .{ clock.day, clock.hour(), clock.minute() });
    std.debug.print("------------------------------------------\n", .{});
    std.debug.print("Treasury: ${d}   Crew Cash: ${d}   Morale: {d}\n", .{ eco.treasury, c.cash, c.morale });
    std.debug.print("Crew: {s} ({d} members)\n", .{ c.name, c.count });
    std.debug.print("------------------------------------------\n", .{});
    std.debug.print("Districts:\n", .{});
    for (districts) |d| {
        std.debug.print("  • {s:<22} Control {d:3}%  Heat {d:3}  Income/day ${d}\n", .{
            d.name,
            d.control,
            d.heat,
            city.dailyIncome(d),
        });
    }
    std.debug.print("==========================================\n\n", .{});
}
