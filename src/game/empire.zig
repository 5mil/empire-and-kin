const std = @import("std");
const city = @import("city.zig");
const crew = @import("crew.zig");

// ---------------------------------------------------------------------------
// Rackets
// ---------------------------------------------------------------------------

pub const RacketType = enum {
    speakeasy, // or nightclub in 80s
    numbers,
    protection,
    gambling,
    loan_sharking,
    smuggling,
    union,
};

pub fn racketName(r: RacketType) []const u8 {
    return switch (r) {
        .speakeasy => "Speakeasy / Club",
        .numbers => "Numbers Bank",
        .protection => "Protection",
        .gambling => "Gambling Den",
        .loan_sharking => "Loan Sharking",
        .smuggling => "Smuggling",
        .union => "Union Racketeering",
    };
}

pub const Racket = struct {
    rtype: RacketType,
    district: city.DistrictType,
    level: u8, // 1-5
    assigned_member: ?u8, // index into crew.members, null = unassigned
    income_mod: f32, // multiplier
    heat_gen: u8, // extra heat produced
};

pub const MAX_RACKETS = 12;

pub const Empire = struct {
    rackets: [MAX_RACKETS]Racket = undefined,
    racket_count: u8 = 0,
    influence: u32 = 0,
    reputation: i16 = 0, // -100 .. +100 (feared / respected)
    respect_italian: u8 = 20,
    respect_street: u8 = 20,
};

pub fn addRacket(e: *Empire, rtype: RacketType, district: city.DistrictType) bool {
    if (e.racket_count >= MAX_RACKETS) return false;
    const idx = e.racket_count;
    e.rackets[idx] = .{
        .rtype = rtype,
        .district = district,
        .level = 1,
        .assigned_member = null,
        .income_mod = 1.0,
        .heat_gen = 5,
    };
    e.racket_count += 1;
    return true;
}

pub fn assignCrewToRacket(e: *Empire, racket_idx: u8, member_idx: u8) bool {
    if (racket_idx >= e.racket_count) return false;
    e.rackets[racket_idx].assigned_member = member_idx;
    e.rackets[racket_idx].income_mod = 1.25; // crew boosts income
    return true;
}

pub fn unassignRacket(e: *Empire, racket_idx: u8) void {
    if (racket_idx >= e.racket_count) return;
    e.rackets[racket_idx].assigned_member = null;
    e.rackets[racket_idx].income_mod = 1.0;
}

pub fn upgradeRacket(e: *Empire, racket_idx: u8) bool {
    if (racket_idx >= e.racket_count) return false;
    if (e.rackets[racket_idx].level >= 5) return false;
    e.rackets[racket_idx].level += 1;
    e.rackets[racket_idx].income_mod += 0.2;
    e.rackets[racket_idx].heat_gen += 3;
    return true;
}

pub fn totalRacketIncome(e: Empire) u32 {
    var total: u32 = 0;
    var i: u8 = 0;
    while (i < e.racket_count) : (i += 1) {
        const base: u32 = 40 + e.rackets[i].level * 25;
        const mod = e.rackets[i].income_mod;
        total += @intFromFloat(@as(f32, @floatFromInt(base)) * mod);
    }
    return total;
}

// ---------------------------------------------------------------------------
// Crew Orders
// ---------------------------------------------------------------------------

pub const Order = enum {
    idle,
    collect, // collect from rackets
    rest,
    enforce, // raise control / intimidate
    scout, // lower heat / gather info
    guard, // protect a racket
};

pub fn orderName(o: Order) []const u8 {
    return switch (o) {
        .idle => "Idle",
        .collect => "Collect",
        .rest => "Rest",
        .enforce => "Enforce",
        .scout => "Scout",
        .guard => "Guard",
    };
}

/// Apply a simple order effect. Returns cash gained (if any).
pub fn issueOrder(c: *crew.Crew, member_idx: u8, order: Order, e: *Empire, d: *city.District) u32 {
    if (member_idx >= c.count) return 0;
    var m = &c.members[member_idx];
    if (!m.alive) return 0;

    switch (order) {
        .idle => {},
        .rest => {
            if (m.fatigue > 15) m.fatigue -= 15 else m.fatigue = 0;
            c.morale = @min(100, c.morale + 2);
        },
        .collect => {
            const take = totalRacketIncome(e.*) / 4;
            m.fatigue = @min(100, m.fatigue + 8);
            return take;
        },
        .enforce => {
            city.increaseControl(d, 4);
            m.fatigue = @min(100, m.fatigue + 12);
            e.reputation = @min(100, e.reputation + 3);
            e.influence += 2;
        },
        .scout => {
            if (d.heat > 8) d.heat -= 8 else d.heat = 0;
            m.fatigue = @min(100, m.fatigue + 6);
        },
        .guard => {
            m.fatigue = @min(100, m.fatigue + 5);
            // reduces heat gen slightly when guarding
            if (e.racket_count > 0 and e.rackets[0].heat_gen > 2) {
                e.rackets[0].heat_gen -= 1;
            }
        },
    }
    return 0;
}

// ---------------------------------------------------------------------------
// Influence & Reputation
// ---------------------------------------------------------------------------

pub fn addInfluence(e: *Empire, amount: u32) void {
    e.influence += amount;
}

pub fn changeReputation(e: *Empire, delta: i16) void {
    const next = e.reputation + delta;
    if (next > 100) e.reputation = 100 else if (next < -100) e.reputation = -100 else e.reputation = next;
}

pub fn reputationLabel(e: Empire) []const u8 {
    if (e.reputation >= 60) return "Feared & Respected";
    if (e.reputation >= 25) return "Respected";
    if (e.reputation >= -10) return "Unknown";
    if (e.reputation >= -40) return "Disliked";
    return "Marked";
}

pub fn printEmpireStatus(e: Empire, c: crew.Crew) void {
    std.debug.print("\n========== EMPIRE STATUS ==========\n", .{});
    std.debug.print("Influence: {d}   Reputation: {d} ({s})\n", .{ e.influence, e.reputation, reputationLabel(e) });
    std.debug.print("Rackets: {d}   Est. daily take: ${d}\n", .{ e.racket_count, totalRacketIncome(e) });
    std.debug.print("-----------------------------------\n", .{});
    var i: u8 = 0;
    while (i < e.racket_count) : (i += 1) {
        const r = e.rackets[i];
        const who = if (r.assigned_member) |idx| c.members[idx].name else "— unassigned —";
        std.debug.print("  [{d}] {s:<18} Lv{d}  District heat gen {d}  → {s}\n", .{
            i,
            racketName(r.rtype),
            r.level,
            r.heat_gen,
            who,
        });
    }
    std.debug.print("===================================\n\n", .{});
}
