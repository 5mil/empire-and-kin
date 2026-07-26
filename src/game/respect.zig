//! Soft respect meters affecting passive income and shop costs.
const empire = @import("empire.zig");

pub fn shopCostMult(e: empire.Empire) f32 {
    // Higher street respect = cheaper fences
    if (e.respect_street >= 60) return 0.75;
    if (e.respect_street >= 30) return 0.9;
    return 1.0;
}

pub fn earnStreet(e: *empire.Empire, amount: u8) void {
    e.respect_street = @min(100, e.respect_street + amount);
}

pub fn earnItalian(e: *empire.Empire, amount: u8) void {
    e.respect_italian = @min(100, e.respect_italian + amount);
}

pub fn loseStreet(e: *empire.Empire, amount: u8) void {
    if (e.respect_street > amount) e.respect_street -= amount else e.respect_street = 0;
}
