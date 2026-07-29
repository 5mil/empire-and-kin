//! Full character map — appearance, skills, lifestyle, identity, traits.
//! Driveable by UI (C key), move speed, tint, and save system.

const std = @import("std");

pub const BodyType = enum { slim, average, heavy, athletic };
pub const HairStyle = enum { short, slicked, wavy, bald, undercut, pompadour };
pub const FacialHair = enum { clean, stubble, mustache, full_beard };
pub const SuitStyle = enum { charcoal, navy, brown, pinstripe, casual, leather };
pub const HatStyle = enum { none, fedora, flat_cap, newsboy };
pub const EthnicityTone = enum { pale, light, medium, olive, deep };

pub const Skill = enum {
    muscle,
    street_smarts,
    charm,
    stealth,
    driving,
    business,
    marksmanship,
    intimidation,
};

pub const Trait = enum {
    none,
    hot_head,
    ice_cold,
    silver_tongue,
    ghost,
    wheelman,
    bookkeeper,
};

pub const CharacterMap = struct {
    // Identity
    legal_name: []const u8 = "Vinnie Russo",
    street_name: []const u8 = "The Chin",
    age: u8 = 34,
    era_born: u16 = 1896,

    // Appearance dimensions
    body: BodyType = .average,
    hair: HairStyle = .slicked,
    facial: FacialHair = .stubble,
    suit: SuitStyle = .charcoal,
    hat: HatStyle = .none,
    tone: EthnicityTone = .olive,
    height_scale: f32 = 1.0,
    bulk_scale: f32 = 1.0,
    scar_cheek: bool = false,
    jewelry: bool = false,

    // Skills 0-100
    muscle: u8 = 45,
    street_smarts: u8 = 55,
    charm: u8 = 40,
    stealth: u8 = 30,
    driving: u8 = 50,
    business: u8 = 48,
    marksmanship: u8 = 35,
    intimidation: u8 = 42,

    // Primary trait (affects flavor + small multipliers)
    trait: Trait = .none,

    // Lifestyle meters 0-100
    energy: u8 = 80,
    stress: u8 = 25,
    hunger: u8 = 40,
    hygiene: u8 = 70,
    morale: u8 = 60,
    addiction: u8 = 0, // 0–100 vice pressure

    // Social
    family_standing: u8 = 35,
    civilian_rep: i8 = 0,
    underworld_rep: i8 = 10,
    police_heat_bias: i8 = 0,

    pub fn skillValue(self: CharacterMap, s: Skill) u8 {
        return switch (s) {
            .muscle => self.muscle,
            .street_smarts => self.street_smarts,
            .charm => self.charm,
            .stealth => self.stealth,
            .driving => self.driving,
            .business => self.business,
            .marksmanship => self.marksmanship,
            .intimidation => self.intimidation,
        };
    }

    pub fn moveSpeedMul(self: CharacterMap) f32 {
        var m: f32 = 1.0;
        if (self.body == .athletic) m += 0.08;
        if (self.body == .heavy) m -= 0.06;
        if (self.body == .slim) m += 0.03;
        if (self.energy < 30) m -= 0.12;
        if (self.hunger > 80) m -= 0.08;
        if (self.stress > 70) m -= 0.05;
        if (self.trait == .wheelman) m += 0.04;
        if (self.trait == .ghost) m += 0.03;
        return @max(0.55, m);
    }

    pub fn combatMul(self: CharacterMap) f32 {
        var m: f32 = 1.0 + @as(f32, @floatFromInt(self.muscle)) * 0.002;
        if (self.trait == .hot_head) m += 0.08;
        if (self.trait == .ice_cold) m += 0.04;
        return m;
    }

    pub fn stealthMul(self: CharacterMap) f32 {
        var m: f32 = 1.0 + @as(f32, @floatFromInt(self.stealth)) * 0.003;
        if (self.trait == .ghost) m += 0.12;
        if (self.hygiene < 25) m -= 0.06; // stink draws eyes
        return @max(0.4, m);
    }

    pub fn skinRgb(self: CharacterMap) [3]u8 {
        return switch (self.tone) {
            .pale => .{ 235, 210, 190 },
            .light => .{ 220, 185, 155 },
            .medium => .{ 190, 145, 110 },
            .olive => .{ 175, 135, 100 },
            .deep => .{ 110, 75, 55 },
        };
    }

    pub fn suitRgb(self: CharacterMap) [3]u8 {
        return switch (self.suit) {
            .charcoal => .{ 32, 38, 55 },
            .navy => .{ 28, 40, 70 },
            .brown => .{ 55, 40, 28 },
            .pinstripe => .{ 40, 42, 52 },
            .casual => .{ 60, 70, 85 },
            .leather => .{ 28, 24, 22 },
        };
    }

    pub fn hairRgb(self: CharacterMap) [3]u8 {
        return switch (self.hair) {
            .bald => self.skinRgb(),
            .short => .{ 40, 32, 28 },
            .slicked => .{ 22, 18, 16 },
            .wavy => .{ 55, 40, 28 },
            .undercut => .{ 30, 28, 32 },
            .pompadour => .{ 35, 28, 22 },
        };
    }

    pub fn tickNeeds(self: *CharacterMap, dt: f64) void {
        // Coarse drain; prefer accumulators in main loop for precision
        _ = self;
        _ = dt;
    }
};

pub fn createDefault() CharacterMap {
    return .{};
}

pub fn create1930s() CharacterMap {
    return .{
        .legal_name = "Vincenzo Russo",
        .street_name = "The Chin",
        .age = 34,
        .era_born = 1896,
        .suit = .pinstripe,
        .hat = .fedora,
        .facial = .mustache,
        .trait = .ice_cold,
        .business = 55,
        .intimidation = 50,
    };
}

pub fn create1980s() CharacterMap {
    return .{
        .legal_name = "Vincent Russo",
        .street_name = "Vinny R",
        .age = 32,
        .era_born = 1954,
        .suit = .leather,
        .hair = .undercut,
        .facial = .stubble,
        .hat = .none,
        .trait = .hot_head,
        .driving = 62,
        .marksmanship = 48,
        .street_smarts = 60,
    };
}
