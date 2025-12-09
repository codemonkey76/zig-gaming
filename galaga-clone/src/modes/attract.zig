const std = @import("std");
const Input = @import("renderer").types.Input;
const Color = @import("renderer").types.Color;
const Font = @import("renderer").types.Font;

const TextGrid = @import("renderer").TextGrid;

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

    pub fn update(self: *@This(), dt: f32, input: Input) void {
        _ = input;
        self.timer += dt;
    }
    pub fn shouldTransition(self: *const @This()) bool {
        return self.timer > TRANSITION_DELAY;
    }

    pub fn draw(self: *const @This(), ctx: anytype) void {
        _ = self;
        _ = ctx;
    }
    pub fn drawDebug(self: *const @This(), ctx: anytype) void {
        _ = self;
        ctx.renderer.drawText("Attract Mode", .{ .x = 10, .y = 10 }, 24, Color.white, null);
    }
};
