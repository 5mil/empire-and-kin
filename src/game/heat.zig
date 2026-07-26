//! Passive heat cooling when the district is not on fire.
const city = @import("city.zig");

/// Call with real-time dt. Cools slowly if heat moderate.
pub fn tickDecay(d: *city.District, dt: f64) void {
    if (d.heat == 0) return;
    // ~1 heat per 8 real seconds when under 50; slower when hotter
    const rate: f64 = if (d.heat < 40) 0.15 else if (d.heat < 70) 0.08 else 0.03;
    const drop = rate * dt;
    // accumulate via fractional — use simple discrete chance
    // For simplicity: subtract 1 every 1/rate seconds using residual stored in heat itself is wrong.
    // Use static-ish: subtract based on integral via heat as u8 only — probabilistic
    _ = drop;
    // Deterministic: cool 1 every ~7s when low
    // Caller passes accumulated cooler
}

pub fn applyDecayAccum(d: *city.District, accum: *f32, dt: f64) void {
    const rate: f32 = if (d.heat < 40) 0.18 else if (d.heat < 70) 0.09 else 0.04;
    accum.* += rate * @as(f32, @floatCast(dt));
    while (accum.* >= 1.0 and d.heat > 0) {
        d.heat -= 1;
        accum.* -= 1.0;
    }
}
