const std = @import("std");
const Input = @import("renderer").types.Input;
const Color = @import("renderer").types.Color;
const TextGrid = @import("renderer").TextGrid;

pub const HighScore = struct {
    pub fn init(allocator: std.mem.Allocator) @This() {
        _ = allocator;
        return .{};
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }

    pub fn update(self: *@This(), dt: f32, input: Input) void {
        _ = self;
        _ = dt;
        _ = input;
    }
    pub fn draw(self: *const @This(), ctx: anytype) void {
        _ = self;
        _ = ctx;
    }

    pub fn drawDebug(self: *const @This(), ctx: anytype) void {
        _ = self;
        ctx.renderer.drawText("HighScore Mode", .{ .x = 10, .y = 10 }, 24, Color.white, null);
    }
};
