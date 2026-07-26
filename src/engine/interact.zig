//! Single place for world E-key interactions.
const backend = @import("backend.zig");
const player = @import("../game/player.zig");
const economy = @import("../game/economy.zig");
const city = @import("../game/city.zig");
const inventory = @import("../game/inventory.zig");
const rival = @import("../game/rival.zig");
const empire = @import("../game/empire.zig");
const fence = @import("../game/fence.zig");
const stash_mod = @import("../game/stash.zig");
const doc = @import("../game/doc.zig");
const numbers = @import("../game/numbers.zig");
const bartender = @import("../game/bartender.zig");
const vendor = @import("../game/vendor.zig");
const phonebooth = @import("../game/phonebooth.zig");
const newspaper = @import("../game/newspaper.zig");
const church = @import("../game/church.zig");
const dock = @import("../game/dock.zig");
const blackjack = @import("../game/blackjack.zig");
const informant = @import("../game/informant.zig");
const warehouse = @import("../game/warehouse.zig");
const arcade = @import("../game/arcade.zig");
const taxi = @import("../game/taxi.zig");
const bakery = @import("../game/bakery.zig");
const barber = @import("../game/barber.zig");
const laundry = @import("../game/laundry.zig");
const perfume = @import("../game/perfume.zig");
const cigar = @import("../game/cigar.zig");
const postoffice = @import("../game/postoffice.zig");
const alley_deal = @import("../game/alley_deal.zig");
const scene = @import("scene.zig");
const balance = @import("../game/balance.zig");

pub const Result = struct {
    handled: bool = false,
    msg: []const u8 = "",
};

pub fn promptNear(p: player.Player) []const u8 {
    if (fence.near(p)) return "[E] Fence";
    if (stash_mod.near(p)) return "[E] Stash";
    if (doc.near(p)) return "[E] Doc $300";
    if (numbers.near(p)) return "[E] Numbers $100";
    if (bartender.near(p)) return "[E] Drink $50  [R] Tip $150";
    if (vendor.near(p)) return "[E] Buy medkit $200";
    if (phonebooth.near(p)) return "[E] Phone tip $25";
    if (newspaper.near(p)) return "[E] Paper $5";
    if (church.near(p)) return "[E] Confess";
    if (dock.near(p)) return "[E] Dock collect";
    if (blackjack.near(p)) return "[E] Gamble $100";
    if (informant.near(p)) return "[E] Informant $250";
    if (warehouse.near(p)) return "[E] Warehouse $500";
    if (arcade.near(p)) return "[E] Arcade $10";
    if (taxi.near(p)) return "[E] Taxi home $40";
    if (bakery.near(p)) return "[E] Bakery $15";
    if (barber.near(p)) return "[E] Barber $20";
    if (laundry.near(p)) return "[E] Laundry $30";
    if (perfume.near(p)) return "[E] Perfume $75";
    if (cigar.near(p)) return "[E] Cigar $40";
    if (postoffice.near(p)) return "[E] Mail";
    if (alley_deal.nearAlley(p)) return "[E] Alley deal";
    if (scene.nearSafehouse(p)) return "[E] heal  [R] bribe";
    return "";
}

pub fn tryE(
    p: *player.Player,
    eco: *economy.Economy,
    d: *city.District,
    inv: *inventory.Inventory,
    stash: *stash_mod.Stash,
    riv: *rival.Rival,
    emp: *empire.Empire,
    seed: u32,
    safehouse_cd: *f64,
) Result {
    if (fence.near(p.*)) {
        if (fence.coolHeat(eco, d)) return .{ .handled = true, .msg = "Fence: heat down" };
        if (fence.clearStar(eco, p)) return .{ .handled = true, .msg = "Fence: star gone" };
        return .{ .handled = true, .msg = "Fence wants cash" };
    }
    if (stash_mod.near(p.*)) {
        if (stash_mod.deposit(stash, eco, balance.STASH_CHUNK)) return .{ .handled = true, .msg = "Stashed $250" };
        if (stash_mod.withdraw(stash, eco, balance.STASH_CHUNK)) return .{ .handled = true, .msg = "Withdrew $250" };
        return .{ .handled = true, .msg = "Stash empty / no cash" };
    }
    if (doc.near(p.*)) {
        if (doc.heal(p, eco)) return .{ .handled = true, .msg = "Doc patched you" };
        return .{ .handled = true, .msg = "Doc: $300 or full HP" };
    }
    if (numbers.near(p.*)) {
        const delta = numbers.play(eco, seed);
        if (delta > 0) return .{ .handled = true, .msg = "Numbers hit" };
        if (delta < 0) return .{ .handled = true, .msg = "Numbers miss" };
        return .{ .handled = true, .msg = "Need $100" };
    }
    if (bartender.near(p.*)) {
        if (bartender.drink(eco, p, d)) return .{ .handled = true, .msg = "Had a drink" };
        return .{ .handled = true, .msg = "Need $50" };
    }
    if (vendor.near(p.*)) {
        if (vendor.buyMedkit(eco, inv)) return .{ .handled = true, .msg = "Bought medkit" };
        return .{ .handled = true, .msg = "Can't buy medkit" };
    }
    if (phonebooth.near(p.*)) {
        if (phonebooth.callTip(eco)) return .{ .handled = true, .msg = "Phone tip +$55" };
        return .{ .handled = true, .msg = "Need $25" };
    }
    if (newspaper.near(p.*)) {
        if (newspaper.buyPaper(eco, seed)) |_| return .{ .handled = true, .msg = "Bought paper" };
        return .{ .handled = true, .msg = "Need $5" };
    }
    if (church.near(p.*)) {
        church.confess(d, p);
        return .{ .handled = true, .msg = "Confessed" };
    }
    if (dock.near(p.*)) {
        const pay = dock.collect(eco, d.*);
        if (pay > 0) return .{ .handled = true, .msg = "Dock payout" };
        return .{ .handled = true, .msg = "Need more control" };
    }
    if (blackjack.near(p.*)) {
        const delta = blackjack.play(eco, seed);
        if (delta > 0) return .{ .handled = true, .msg = "Table win" };
        if (delta < 0) return .{ .handled = true, .msg = "Table loss" };
        return .{ .handled = true, .msg = "Need $100" };
    }
    if (informant.near(p.*)) {
        if (informant.pay(eco, riv)) return .{ .handled = true, .msg = "Rival eased" };
        return .{ .handled = true, .msg = "Need $250" };
    }
    if (warehouse.near(p.*)) {
        if (warehouse.bigDeposit(stash, eco)) return .{ .handled = true, .msg = "Warehouse $500" };
        return .{ .handled = true, .msg = "Need $500 cash" };
    }
    if (arcade.near(p.*)) {
        if (arcade.play(eco)) return .{ .handled = true, .msg = "Arcade" };
        return .{ .handled = true, .msg = "Need $10" };
    }
    if (taxi.near(p.*)) {
        if (taxi.rideHome(p, eco)) return .{ .handled = true, .msg = "Taxi home" };
        return .{ .handled = true, .msg = "Need $40" };
    }
    if (bakery.near(p.*)) {
        if (bakery.buy(eco, emp)) return .{ .handled = true, .msg = "Cannoli run" };
        return .{ .handled = true, .msg = "Need $15" };
    }
    if (barber.near(p.*)) {
        if (barber.cut(eco, d)) return .{ .handled = true, .msg = "Clean cut" };
        return .{ .handled = true, .msg = "Need $20" };
    }
    if (laundry.near(p.*)) {
        if (laundry.wash(eco, d)) return .{ .handled = true, .msg = "Laundry cools heat" };
        return .{ .handled = true, .msg = "Need $30" };
    }
    if (perfume.near(p.*)) {
        if (perfume.gift(eco, emp)) return .{ .handled = true, .msg = "Gift for the family" };
        return .{ .handled = true, .msg = "Need $75" };
    }
    if (cigar.near(p.*)) {
        if (cigar.smoke(eco, emp)) return .{ .handled = true, .msg = "Cigar lounge" };
        return .{ .handled = true, .msg = "Need $40" };
    }
    if (postoffice.near(p.*)) {
        return .{ .handled = true, .msg = postoffice.checkMail(eco, seed) };
    }
    if (alley_deal.nearAlley(p.*)) {
        return .{ .handled = true, .msg = alley_deal.deal(eco, d, seed) };
    }
    if (scene.nearSafehouse(p.*) and safehouse_cd.* <= 0) {
        player.heal(p, 25);
        if (d.heat > 12) d.heat -= 12 else d.heat = 0;
        if (p.wanted_level > 0) p.wanted_level -= 1;
        safehouse_cd.* = 30.0;
        return .{ .handled = true, .msg = "Safehouse healed" };
    }
    return .{};
}

pub fn drawMarkers(gfx: backend.Backend) void {
    gfx.drawBox(.{ .x = fence.FENCE_X, .y = 0.8, .z = fence.FENCE_Z }, 1.2, 1.6, 1.2, backend.Color.rgb(120, 90, 40));
    gfx.drawBox(.{ .x = stash_mod.STASH_X, .y = 0.4, .z = stash_mod.STASH_Z }, 1.0, 0.8, 1.0, backend.Color.rgb(60, 50, 40));
    gfx.drawBox(.{ .x = doc.DOC_X, .y = 0.9, .z = doc.DOC_Z }, 1.4, 1.8, 1.4, backend.Color.rgb(200, 200, 210));
    gfx.drawBox(.{ .x = numbers.BANK_X, .y = 0.7, .z = numbers.BANK_Z }, 1.5, 1.4, 1.5, backend.Color.rgb(90, 70, 110));
    gfx.drawBox(.{ .x = bartender.BAR_X, .y = 0.6, .z = bartender.BAR_Z }, 1.2, 1.2, 1.2, backend.Color.rgb(100, 60, 40));
    gfx.drawBox(.{ .x = vendor.VENDOR_X, .y = 0.5, .z = vendor.VENDOR_Z }, 1.0, 1.0, 1.0, backend.Color.rgb(180, 140, 60));
    gfx.drawBox(.{ .x = phonebooth.PHONE_X, .y = 1.0, .z = phonebooth.PHONE_Z }, 0.6, 2.0, 0.6, backend.Color.rgb(40, 50, 80));
    gfx.drawBox(.{ .x = newspaper.STAND_X, .y = 0.5, .z = newspaper.STAND_Z }, 0.8, 1.0, 0.8, backend.Color.rgb(150, 100, 50));
    gfx.drawBox(.{ .x = church.CHURCH_X, .y = 2.5, .z = church.CHURCH_Z }, 3.0, 5.0, 3.0, backend.Color.rgb(180, 175, 160));
    gfx.drawBox(.{ .x = dock.DOCK_X, .y = 0.3, .z = dock.DOCK_Z }, 4.0, 0.6, 3.0, backend.Color.rgb(90, 70, 50));
    gfx.drawBox(.{ .x = blackjack.DEN_X, .y = 0.8, .z = blackjack.DEN_Z }, 2.0, 1.6, 2.0, backend.Color.rgb(80, 40, 60));
    gfx.drawBox(.{ .x = informant.INF_X, .y = 0.7, .z = informant.INF_Z }, 0.8, 1.4, 0.8, backend.Color.rgb(70, 70, 50));
    gfx.drawBox(.{ .x = warehouse.WH_X, .y = 1.5, .z = warehouse.WH_Z }, 3.5, 3.0, 3.5, backend.Color.rgb(100, 95, 85));
    gfx.drawBox(.{ .x = arcade.ARC_X, .y = 0.6, .z = arcade.ARC_Z }, 0.8, 1.2, 0.8, backend.Color.rgb(200, 50, 80));
    gfx.drawBox(.{ .x = taxi.TAXI_X, .y = 0.5, .z = taxi.TAXI_Z }, 1.8, 1.0, 3.0, backend.Color.rgb(220, 180, 40));
    gfx.drawBox(.{ .x = bakery.BAK_X, .y = 0.7, .z = bakery.BAK_Z }, 1.6, 1.4, 1.6, backend.Color.rgb(210, 180, 120));
    gfx.drawBox(.{ .x = barber.BARB_X, .y = 0.8, .z = barber.BARB_Z }, 1.4, 1.6, 1.4, backend.Color.rgb(160, 160, 170));
    gfx.drawBox(.{ .x = laundry.LAU_X, .y = 0.6, .z = laundry.LAU_Z }, 1.5, 1.2, 1.5, backend.Color.rgb(140, 160, 180));
    gfx.drawBox(.{ .x = perfume.SHOP_X, .y = 0.7, .z = perfume.SHOP_Z }, 1.2, 1.4, 1.2, backend.Color.rgb(200, 120, 160));
    gfx.drawBox(.{ .x = cigar.CIG_X, .y = 0.6, .z = cigar.CIG_Z }, 1.0, 1.2, 1.0, backend.Color.rgb(90, 60, 40));
    gfx.drawBox(.{ .x = postoffice.PO_X, .y = 1.2, .z = postoffice.PO_Z }, 2.2, 2.4, 2.0, backend.Color.rgb(180, 50, 40));
}
