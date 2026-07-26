const backend = @import("backend.zig");
const world = @import("../game/world.zig");
const city = @import("../game/city.zig");

pub fn draw(gfx: backend.Backend, dtype: city.DistrictType) void {
    gfx.drawText(world.districtName(dtype), 480, 700, backend.Color.rgb(80, 90, 110));
}
