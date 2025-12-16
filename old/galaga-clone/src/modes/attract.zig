const std = @import("std");
const engine = @import("arcade_engine");
const Input = engine.types.Input;
const Color = engine.types.Color;
const Font = engine.types.Font;
const Key = engine.types.Key;
const TextGrid = engine.spatial.TextGrid;
const GameContext = @import("../context.zig").GameContext;
const MutableGameContext = @import("../context.zig").MutableGameContext;

const TRANSITION_DELAY = 5.0;
const FONT_SIZE = 16.0;

pub const Attract = struct {
    timer: f32,

    pub fn init(allocator: std.mem.Allocator) @This() {
        _ = allocator;
        return .{
            .timer = 0,
        };
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }

    pub fn onEnter(_: *@This(), _: MutableGameContext) void {}

    pub fn onExit(_: *@This(), _: MutableGameContext) void {}

    pub fn update(self: *@This(), dt: f32, input: *Input, ctx: MutableGameContext) void {
        _ = input;
        _ = ctx;
        self.timer += dt;
    }

    pub fn shouldTransition(self: *const @This()) bool {
        return self.timer > TRANSITION_DELAY;
    }

    pub fn draw(self: *const @This(), ctx: GameContext) void {
        _ = self;
        _ = ctx;
    }

    pub fn drawDebug(self: *const @This(), ctx: anytype) void {
        _ = self;
        ctx.renderer.drawText("Attract Mode", .{ .x = 10, .y = 10 }, 24, Color.white, null);
    }
};
