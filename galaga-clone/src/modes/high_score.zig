const std = @import("std");
const Input = @import("renderer").types.Input;
const Color = @import("renderer").types.Color;
const Key = @import("renderer").types.Key;
const TextGrid = @import("renderer").TextGrid;
const MutableGameContext = @import("../context.zig").MutableGameContext;
const GameContext = @import("../context.zig").GameContext;
const common = @import("common.zig");

pub const HighScore = struct {
    pub const keys = [_]Key{
        .left,
        .right,
        .space,
    };
    pub fn init(allocator: std.mem.Allocator) @This() {
        _ = allocator;
        return .{};
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }

    pub fn onEnter(_: *@This(), ctx: MutableGameContext) void {
        common.registerKeys(ctx, &keys);
    }
    pub fn shouldTransition(_: *@This()) bool {
        return true;
    }

    pub fn onExit(_: *@This(), ctx: MutableGameContext) void {
        common.unregisterKeys(ctx, &keys);
    }

    pub fn update(self: *@This(), dt: f32, input: *Input, ctx: MutableGameContext) void {
        _ = self;
        _ = dt;
        _ = input;
        _ = ctx;
    }
    pub fn draw(self: *const @This(), ctx: GameContext) void {
        _ = self;
        _ = ctx;
    }

    pub fn drawDebug(self: *const @This(), ctx: anytype) void {
        _ = self;
        ctx.renderer.drawText("HighScore Mode", .{ .x = 10, .y = 10 }, 24, Color.white, null);
    }
};
