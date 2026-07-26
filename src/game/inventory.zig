pub const Item = enum { none, smokescreen, medkit, lockpick };

pub const Inventory = struct {
    slots: [4]Item = .{ .none, .none, .none, .none },

    pub fn add(self: *Inventory, item: Item) bool {
        for (&self.slots) |*s| {
            if (s.* == .none) {
                s.* = item;
                return true;
            }
        }
        return false;
    }

    pub fn useFirst(self: *Inventory, item: Item) bool {
        for (&self.slots) |*s| {
            if (s.* == item) {
                s.* = .none;
                return true;
            }
        }
        return false;
    }
};
