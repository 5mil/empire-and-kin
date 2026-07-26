pub const Flags = struct {
    first_job: bool = false,
    first_bribe: bool = false,
    first_goal: bool = false,
};

pub fn markJob(f: *Flags) ?[]const u8 {
    if (f.first_job) return null;
    f.first_job = true;
    return "First job done";
}

pub fn markBribe(f: *Flags) ?[]const u8 {
    if (f.first_bribe) return null;
    f.first_bribe = true;
    return "First bribe";
}

pub fn markGoal(f: *Flags) ?[]const u8 {
    if (f.first_goal) return null;
    f.first_goal = true;
    return "First goal tier";
}
