const std = @import("std");
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const world = @import("../game/world.zig");
const input = @import("input.zig");

pub const Controller = struct {
    mapper: input.Mapper = .{},
    paused: bool = false,
    last_district: ?@import("../game/city.zig").DistrictType = null,
    district_changed: bool = false,

    pub fn tick(
        self: *Controller,
        raw: input.RawKeys,
        p: *player.Player,
        dt: f64,
    ) backend.InputState {
        const state = self.mapper.map(raw);

        if (state.pause) {
            self.paused = !self.paused;
        }

        if (!self.paused) {
            player.move(p, state.move_x, state.move_y, dt);
            const prev = p.current_district;
            world.updatePlayerDistrict(p);
            self.district_changed = (p.current_district != prev);
            self.last_district = p.current_district;
        }

        return state;
    }
};
