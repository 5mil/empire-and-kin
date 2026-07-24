const std = @import("std");

pub const MissionType = enum {
    bootlegging,
    protection,
    hit,
    heist,
    smuggling,
};

pub const Mission = struct {
    id: u32,
    name: []const u8,
    mtype: MissionType,
    difficulty: u8, // 1-10
    reward_cash: u32,
    risk: u8, // 1-10
    completed: bool = false,
};

pub fn generateMission(id: u32, mtype: MissionType) Mission {
    const base_reward: u32 = switch (mtype) {
        .bootlegging => 150,
        .protection => 100,
        .hit => 400,
        .heist => 800,
        .smuggling => 250,
    };
    const difficulty: u8 = switch (mtype) {
        .bootlegging => 3,
        .protection => 2,
        .hit => 7,
        .heist => 9,
        .smuggling => 5,
    };
    const risk: u8 = difficulty + 1;

    return Mission{
        .id = id,
        .name = switch (mtype) {
            .bootlegging => "Speakeasy Delivery",
            .protection => "Neighborhood Shakedown",
            .hit => "Quiet Job",
            .heist => "Bank Job",
            .smuggling => "Harbor Run",
        },
        .mtype = mtype,
        .difficulty = difficulty,
        .reward_cash = base_reward * difficulty,
        .risk = risk,
    };
}

pub fn completeMission(m: *Mission) u32 {
    if (m.completed) return 0;
    m.completed = true;
    return m.reward_cash;
}
