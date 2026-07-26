const economy = @import("economy.zig");

pub const Loan = struct {
    principal: u32 = 0,
    due: u32 = 0,
    days_left: u8 = 0,
};

pub fn borrow(l: *Loan, eco: *economy.Economy, amount: u32) bool {
    if (l.due > 0) return false;
    if (amount == 0 or amount > 2000) return false;
    l.principal = amount;
    l.due = amount + amount / 4; // 25% interest
    l.days_left = 3;
    eco.treasury += amount;
    return true;
}

pub fn tickDay(l: *Loan, eco: *economy.Economy) void {
    if (l.due == 0) return;
    if (l.days_left > 0) l.days_left -= 1;
    if (l.days_left == 0) {
        if (eco.treasury >= l.due) {
            eco.treasury -= l.due;
        } else {
            eco.treasury = 0;
        }
        l.* = .{};
    }
}

pub fn repay(l: *Loan, eco: *economy.Economy) bool {
    if (l.due == 0) return false;
    if (eco.treasury < l.due) return false;
    eco.treasury -= l.due;
    l.* = .{};
    return true;
}
