const std = @import("std");
const backend = @import("backend.zig");
const empire = @import("../game/empire.zig");
const crew = @import("../game/crew.zig");
const city = @import("../game/city.zig");
const input = @import("input.zig");

pub const ORDER_KEYS =
    \\[1] Collect  [2] Rest  [3] Enforce  [4] Scout  [5] Guard
;

pub const EmpireMenu = struct {
    selected_member: u8 = 1,
    selected_racket: u8 = 0,
    last_order_msg: []const u8 = "",
};

pub fn draw(
    gfx: backend.Backend,
    emp: empire.Empire,
    c: crew.Crew,
    districts: []const city.District,
    menu: EmpireMenu,
) void {
    const title = backend.Color.rgb(255, 210, 120);
    const white = backend.Color.rgb(230, 230, 220);
    const dim = backend.Color.rgb(150, 150, 145);
    const accent = backend.Color.rgb(120, 200, 160);

    var y: i32 = 10;
    gfx.drawText("======== EMPIRE (PAUSED) ========", 280, y, title);
    y += 22;

    var buf: [96]u8 = undefined;
    const inf = std.fmt.bufPrint(&buf, "Influence {d}   Reputation {d} ({s})", .{
        emp.influence,
        emp.reputation,
        empire.reputationLabel(emp),
    }) catch "";
    gfx.drawText(inf, 280, y, accent);
    y += 20;

    const take = std.fmt.bufPrint(&buf, "Est. racket take ${d}/day   Rackets {d}", .{
        empire.totalRacketIncome(emp),
        emp.racket_count,
    }) catch "";
    gfx.drawText(take, 280, y, white);
    y += 28;

    gfx.drawText("--- Rackets ---", 280, y, title);
    y += 18;
    var i: u8 = 0;
    while (i < emp.racket_count) : (i += 1) {
        const r = emp.rackets[i];
        const who = if (r.assigned_member) |m| c.members[m].name else "unassigned";
        const line = std.fmt.bufPrint(&buf, "{s}{d} {s:<16} Lv{d}  {s}", .{
            if (i == menu.selected_racket) ">" else " ",
            i,
            empire.racketName(r.rtype),
            r.level,
            who,
        }) catch "";
        gfx.drawText(line, 280, y, if (i == menu.selected_racket) white else dim);
        y += 16;
    }

    y += 12;
    gfx.drawText("--- Crew ---", 280, y, title);
    y += 18;
    i = 0;
    while (i < c.count) : (i += 1) {
        const m = c.members[i];
        const line = std.fmt.bufPrint(&buf, "{s}{d} {s:<20} loy {d} fat {d}", .{
            if (i == menu.selected_member) ">" else " ",
            i,
            m.name,
            m.loyalty,
            m.fatigue,
        }) catch "";
        gfx.drawText(line, 280, y, if (i == menu.selected_member) white else dim);
        y += 16;
    }

    y += 14;
    gfx.drawText(ORDER_KEYS, 280, y, accent);
    y += 18;
    if (menu.last_order_msg.len > 0) {
        gfx.drawText(menu.last_order_msg, 280, y, white);
    }
    y += 24;
    gfx.drawText("Esc/Space resume", 280, y, dim);
    _ = districts;
}

pub const MenuKeys = struct {
    order_collect: bool = false,
    order_rest: bool = false,
    order_enforce: bool = false,
    order_scout: bool = false,
    order_guard: bool = false,
};

pub fn handleOrders(
    keys: MenuKeys,
    emp: *empire.Empire,
    c: *crew.Crew,
    districts: []city.District,
    menu: *EmpireMenu,
) void {
    if (districts.len == 0) return;
    const d = &districts[0];
    const mid = menu.selected_member;

    if (keys.order_collect) {
        _ = empire.issueOrder(c, mid, .collect, emp, d);
        menu.last_order_msg = "Order: Collect";
    } else if (keys.order_rest) {
        _ = empire.issueOrder(c, mid, .rest, emp, d);
        menu.last_order_msg = "Order: Rest";
    } else if (keys.order_enforce) {
        _ = empire.issueOrder(c, mid, .enforce, emp, d);
        menu.last_order_msg = "Order: Enforce (+control, +rep)";
    } else if (keys.order_scout) {
        _ = empire.issueOrder(c, mid, .scout, emp, d);
        menu.last_order_msg = "Order: Scout (-heat)";
    } else if (keys.order_guard) {
        _ = empire.issueOrder(c, mid, .guard, emp, d);
        menu.last_order_msg = "Order: Guard";
    }
}
