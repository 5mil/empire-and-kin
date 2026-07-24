const std = @import("std");
const era = @import("era.zig");

pub const Ethnicity = enum {
    italian,
    jewish,
    irish,
    chinese,
    black,
    russian,
    other,
};

pub fn ethnicityName(e: Ethnicity) []const u8 {
    return switch (e) {
        .italian => "Italian",
        .jewish => "Jewish",
        .irish => "Irish",
        .chinese => "Chinese",
        .black => "Black",
        .russian => "Russian",
        .other => "Other",
    };
}

pub const RivalOrg = struct {
    name: []const u8,
    boss: []const u8,
    ethnicity: Ethnicity,
    strength: u8, // 1-100
    territory: u8,
    hostility: u8, // 0-100 toward player
    cash: u32,
    notes: []const u8,
};

/// Maximum rivals we track at once
pub const MAX_RIVALS = 8;

pub fn getRivalsForEra(e: era.Era, out: *[MAX_RIVALS]RivalOrg) u8 {
    return switch (e) {
        .nyc_1930s => load1930s(out),
        .nyc_1980s => load1980s(out),
    };
}

fn load1930s(out: *[MAX_RIVALS]RivalOrg) u8 {
    // Historically grounded names – early 1930s NYC underworld
    out[0] = .{
        .name = "Luciano Family",
        .boss = "Charles \"Lucky\" Luciano",
        .ethnicity = .italian,
        .strength = 88,
        .territory = 4,
        .hostility = 35,
        .cash = 25000,
        .notes = "Architect of the modern Commission",
    };
    out[1] = .{
        .name = "Genovese Crew",
        .boss = "Vito Genovese",
        .ethnicity = .italian,
        .strength = 78,
        .territory = 3,
        .hostility = 45,
        .cash = 18000,
        .notes = "Ambitious and dangerous",
    };
    out[2] = .{
        .name = "Anastasia / Mangano",
        .boss = "Albert Anastasia",
        .ethnicity = .italian,
        .strength = 82,
        .territory = 3,
        .hostility = 50,
        .cash = 16000,
        .notes = "Lord High Executioner – Murder, Inc. ties",
    };
    out[3] = .{
        .name = "Lansky-Siegel Alliance",
        .boss = "Meyer Lansky",
        .ethnicity = .jewish,
        .strength = 85,
        .territory = 2,
        .hostility = 25,
        .cash = 30000,
        .notes = "The brains – casino & financial power",
    };
    out[4] = .{
        .name = "Dutch Schultz Organization",
        .boss = "Dutch Schultz",
        .ethnicity = .jewish,
        .strength = 70,
        .territory = 2,
        .hostility = 55,
        .cash = 14000,
        .notes = "Numbers & beer – volatile",
    };
    out[5] = .{
        .name = "West Side Irish",
        .boss = "Owney \"The Killer\" Madden",
        .ethnicity = .irish,
        .strength = 65,
        .territory = 2,
        .hostility = 30,
        .cash = 11000,
        .notes = "Hell's Kitchen & the Cotton Club",
    };
    out[6] = .{
        .name = "Harlem Numbers",
        .boss = "Stephanie St. Clair",
        .ethnicity = .black,
        .strength = 55,
        .territory = 2,
        .hostility = 20,
        .cash = 9000,
        .notes = "Queen of the Harlem policy banks",
    };
    out[7] = .{
        .name = "On Leong / Hip Sing",
        .boss = "Tong leadership",
        .ethnicity = .chinese,
        .strength = 45,
        .territory = 1,
        .hostility = 15,
        .cash = 7000,
        .notes = "Chinatown tongs – opium & gambling",
    };
    return 8;
}

fn load1980s(out: *[MAX_RIVALS]RivalOrg) u8 {
    // 1980s NYC – Commission era + other groups
    out[0] = .{
        .name = "Gambino Family",
        .boss = "Paul Castellano",
        .ethnicity = .italian,
        .strength = 90,
        .territory = 5,
        .hostility = 40,
        .cash = 45000,
        .notes = "Largest family – Gotti rising in the wings",
    };
    out[1] = .{
        .name = "Genovese Family",
        .boss = "Vincent \"The Chin\" Gigante",
        .ethnicity = .italian,
        .strength = 92,
        .territory = 4,
        .hostility = 35,
        .cash = 50000,
        .notes = "Most powerful and secretive",
    };
    out[2] = .{
        .name = "Lucchese Family",
        .boss = "Anthony \"Tony Ducks\" Corallo",
        .ethnicity = .italian,
        .strength = 80,
        .territory = 3,
        .hostility = 45,
        .cash = 28000,
        .notes = "Construction & garment rackets",
    };
    out[3] = .{
        .name = "Bonanno Family",
        .boss = "Philip \"Rusty\" Rastelli",
        .ethnicity = .italian,
        .strength = 70,
        .territory = 2,
        .hostility = 50,
        .cash = 18000,
        .notes = "Still recovering from the Banana War",
    };
    out[4] = .{
        .name = "Colombo Family",
        .boss = "Carmine \"The Snake\" Persico",
        .ethnicity = .italian,
        .strength = 72,
        .territory = 2,
        .hostility = 55,
        .cash = 16000,
        .notes = "Internal strife never far away",
    };
    out[5] = .{
        .name = "The Westies",
        .boss = "James \"Jimmy\" Coonan",
        .ethnicity = .irish,
        .strength = 60,
        .territory = 1,
        .hostility = 65,
        .cash = 8000,
        .notes = "Hell's Kitchen – extremely violent",
    };
    out[6] = .{
        .name = "Ghost Shadows",
        .boss = "Nicky Louie / leadership",
        .ethnicity = .chinese,
        .strength = 55,
        .territory = 1,
        .hostility = 30,
        .cash = 12000,
        .notes = "Chinatown – extortion & gambling",
    };
    out[7] = .{
        .name = "Brighton Beach Crew",
        .boss = "Evsei Agron",
        .ethnicity = .russian,
        .strength = 50,
        .territory = 1,
        .hostility = 25,
        .cash = 15000,
        .notes = "Emerging Russian organized crime",
    };
    return 8;
}

pub fn provoke(r: *RivalOrg, amount: u8) void {
    r.hostility = @min(100, r.hostility + amount);
}

pub fn coolDown(r: *RivalOrg, amount: u8) void {
    if (r.hostility > amount) {
        r.hostility -= amount;
    } else {
        r.hostility = 0;
    }
}

pub fn isWar(r: RivalOrg) bool {
    return r.hostility >= 70;
}

pub fn printRoster(orgs: []const RivalOrg, count: u8) void {
    std.debug.print("\n--- Underworld Roster ---\n", .{});
    var i: u8 = 0;
    while (i < count) : (i += 1) {
        const r = orgs[i];
        const war = if (isWar(r)) " [WAR]" else "";
        std.debug.print("  {s:<24} ({s})  Boss: {s:<28} Str {d:3}  Host {d:3}{s}\n", .{
            r.name,
            ethnicityName(r.ethnicity),
            r.boss,
            r.strength,
            r.hostility,
            war,
        });
    }
}
