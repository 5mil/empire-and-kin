pub const Contact = struct {
    name: []const u8,
    role: []const u8,
    available: bool = true,
};

pub const Book = struct {
    contacts: [4]Contact = .{
        .{ .name = "Officer Riley", .role = "dirty cop" },
        .{ .name = "Doc Abrams", .role = "patch-up" },
        .{ .name = "Rosa", .role = "numbers runner" },
        .{ .name = "Big Lou", .role = "dock boss" },
    },
};
