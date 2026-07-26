const missions = @import("missions.zig");

pub fn basePay(t: missions.MissionType) u32 {
    return switch (t) {
        .bootlegging => 400,
        .protection => 350,
        .smuggling => 550,
        .hit => 900,
        .heist => 1200,
    };
}
