//! A8 — tuned numbers for a ~10 minute alpha demo

pub const STARTING_TREASURY: u32 = 3000;
pub const JOB_RADIUS: f32 = 6.0;

/// Event cadence (game-seconds). With time_scale ~20, real wait is shorter.
pub const EVENT_INTERVAL: f64 = 22.0;
pub const RIVAL_INTERVAL: f64 = 16.0;

pub const BOOTLEG_DURATION: f32 = 3.0;
pub const PROTECTION_DURATION: f32 = 2.5;
pub const SMUGGLING_DURATION: f32 = 4.0;

pub const HEAT_JOB_MULT: u8 = 2;
pub const WANTED_RISK_THRESHOLD: u8 = 6;
