const std = @import("std");
const action = @import("action.zig");

pub const MAX_FLEET = 8;

pub const OwnedVehicle = struct {
    vehicle: action.Vehicle,
    label: []const u8,
    stored: bool = false,
    insurance: bool = false,
};

pub const Fleet = struct {
    slots: [MAX_FLEET]OwnedVehicle = undefined,
    count: u8 = 0,
    active_idx: ?u8 = null,
};

pub fn addVehicle(f: *Fleet, vtype: action.VehicleType, label: []const u8, x: f32, y: f32) bool {
    if (f.count >= MAX_FLEET) return false;
    f.slots[f.count] = .{ .vehicle = action.spawnVehicle(vtype, x, y), .label = label, .stored = false, .insurance = false };
    f.count += 1;
    return true;
}

pub fn createStarterFleet() Fleet {
    var f: Fleet = .{};
    _ = addVehicle(&f, .sedan, "Black Sedan", 14.0, 20.0);
    _ = addVehicle(&f, .truck, "Delivery Truck", 18.0, 22.0);
    _ = addVehicle(&f, .motorcycle, "Indian Scout", 12.0, 18.0);
    return f;
}

pub fn repairVehicle(f: *Fleet, idx: u8) bool {
    if (idx >= f.count) return false;
    if (f.slots[idx].vehicle.health >= 100) return false;
    f.slots[idx].vehicle.health = 100;
    return true;
}

pub fn storeVehicle(f: *Fleet, idx: u8) bool {
    if (idx >= f.count) return false;
    if (f.slots[idx].vehicle.occupied) return false;
    f.slots[idx].stored = true;
    f.slots[idx].vehicle.speed = 0;
    return true;
}

pub fn deployVehicle(f: *Fleet, idx: u8, x: f32, y: f32) bool {
    if (idx >= f.count) return false;
    f.slots[idx].stored = false;
    f.slots[idx].vehicle.x = x;
    f.slots[idx].vehicle.y = y;
    return true;
}

pub fn setActive(f: *Fleet, idx: u8) bool {
    if (idx >= f.count) return false;
    if (f.slots[idx].stored) return false;
    f.active_idx = idx;
    return true;
}

pub fn activeVehicle(f: *Fleet) ?*action.Vehicle {
    if (f.active_idx) |i| {
        if (i < f.count) return &f.slots[i].vehicle;
    }
    return null;
}
