pub fn recover(safehouse: u8, food: u8, entertainment: bool) u8 {
    return @max(1, 6 - safehouse - food / 3 - if (entertainment) 2 else 0);
}
