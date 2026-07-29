//! Full character map — appearance, skills, lifestyle, identity.
//! Driveable by UI (C key) and save system later.

const std = @import("std");

pub const BodyType = enum { slim, average, heavy, athletic };
pub const HairStyle = enum { short, slicked, wavy, bald, undercut };
pub const SuitStyle = enum { charcoal, navy, brown, pinstripe, casual };
pub const EthnicityTone = enum { pale, light, medium, olive, deep };

pub const Skill = enum {
    muscle,
    street_smarts,
    charm,
    stealth,
    driving,
    business,
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
    suit: SuitStyle = .charcoal,
    tone: EthnicityTone = .olive,
    height_scale: f32 = 1.0,
    bulk_scale: f32 = 1.0,

    // Skills 0-100
    muscle: u8 = 45,
    street_smarts: u8 = 55,
    charm: u8 = 40,
    stealth: u8 = 30,
    driving: u8 = 50,
    business: u8 = 48,

    // Lifestyle meters 0-100
    energy: u8 = 80,
    stress: u8 = 25,
    hunger: u8 = 40,
    hygiene: u8 = 70,
    morale: u8 = 60,

    // Social
    family_standing: u8 = 35,
    civilian_rep: i8 = 0,
    underworld_rep: i8 = 10,

    pub fn skillValue(self: CharacterMap, s: Skill) u8 {
        return switch (s) {
            .muscle => self.muscle,
            .street_smarts => self.street_smarts,
            .charm => self.charm,
            .stealth => self.stealth,
            .driving => self.driving,
            .business => self.business,
        };
    }

    pub fn moveSpeedMul(self: CharacterMap) f32 {
        // Athletic / muscle slightly faster; stress/hunger slow you down
        var m: f32 = 1.0;
        if (self.body == .athletic) m += 0.08;
        if (self.body == .heavy) m -= 0.06;
        if (self.energy < 30) m -= 0.12;
        if (self.hunger > 80) m -= 0.08;
        if (self.stress > 70) m -= 0.05;
        return @max(0.55, m);
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
        };
    }

    pub fn hairRgb(self: CharacterMap) [3]u8 {
        return switch (self.hair) {
            .bald => .{ 175, 135, 100 },
            .short => .{ 40, 32, 28 },
            .slicked => .{ 22, 18, 16 },
            .wavy => .{ 55, 40, 28 },
            .undercut => .{ 30, 28, 32 },
        };
    }

    pub fn tickNeeds(self: *CharacterMap, dt: f64) void {
        // Slow drain while alive in world
        const sec = @as(f32, @floatCast(dt));
        if (self.energy > 0 and sec > 0) {
            // ~1 energy per 40s
            // handled coarsely by caller with accumulators preferred; keep simple
            _ = sec;
        }
    }
};

pub fn createDefault() CharacterMap {
    return .{};
}
