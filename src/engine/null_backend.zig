const std = @import("std");
const backend = @import("backend.zig");

/// Headless / console backend — keeps simulation runnable without a window.
/// Replace with Magister/Arcis/RealCity implementation of the same VTable.

var frame_count: u64 = 0;
var close_after_frames: u64 = 90; // auto-quit demo loop
var accumulated_log: bool = false;

fn initImpl(title: []const u8, width: u32, height: u32) !void {
    _ = width;
    _ = height;
    std.debug.print("[NullBackend] init: {s}\n", .{title});
    frame_count = 0;
}

fn shutdownImpl() void {
    std.debug.print("[NullBackend] shutdown after {d} frames\n", .{frame_count});
}

fn beginFrameImpl() void {
    frame_count += 1;
}

fn endFrameImpl() void {}

fn pollInputImpl() backend.InputState {
    // No real input — mild forward drift for demo
    if (frame_count < 40) {
        return .{ .move_x = 0.5, .move_y = 0.1 };
    }
    if (frame_count == 50) {
        return .{ .pause = true };
    }
    return .{};
}

fn deltaTimeImpl() f64 {
    return 1.0 / 30.0; // fixed 30 Hz step
}

fn shouldCloseImpl() bool {
    return frame_count >= close_after_frames;
}

fn drawTextImpl(text: []const u8, x: i32, y: i32, color: backend.Color) void {
    _ = x;
    _ = y;
    _ = color;
    // Log occasionally to avoid spam
    if (frame_count % 30 == 1) {
        std.debug.print("[draw] {s}\n", .{text});
    }
}

fn clearImpl(color: backend.Color) void {
    _ = color;
}

pub fn getBackend() backend.Backend {
    return .{
        .vtable = .{
            .init = initImpl,
            .shutdown = shutdownImpl,
            .beginFrame = beginFrameImpl,
            .endFrame = endFrameImpl,
            .pollInput = pollInputImpl,
            .deltaTime = deltaTimeImpl,
            .shouldClose = shouldCloseImpl,
            .drawText = drawTextImpl,
            .clear = clearImpl,
        },
    };
}
