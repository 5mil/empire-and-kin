//! Tuned numbers for a ~10 minute alpha demo

pub const STARTING_TREASURY: u32 = 3000;
pub const JOB_RADIUS: f32 = 5.5;

/// Event cadence (game-seconds). With time_scale ~20, real wait is shorter.
pub const EVENT_INTERVAL: f64 = 22.0;
pub const RIVAL_INTERVAL: f64 = 16.0;

pub const BOOTLEG_DURATION: f32 = 3.0;
pub const PROTECTION_DURATION: f32 = 2.5;
pub const SMUGGLING_DURATION: f32 = 4.0;

pub const HEAT_JOB_MULT: u8 = 2;
pub const WANTED_RISK_THRESHOLD: u8 = 6;

/// Passive heal when heat low and not in combat (HP per real second, fractional).
pub const HEAL_PER_SEC: f32 = 2.0;
pub const HEAL_MAX_HEAT: u8 = 25;

pub const TOAST_JOB_SEC: f64 = 3.0;
pub const TOAST_SAVE_SEC: f64 = 2.0;

pub const TIME_SCALE_DEMO: f64 = 18.0;
