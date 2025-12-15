const std = @import("std");
const engine = @import("engine");

pub const GameState = struct {
    const Self = @This();

    pub fn init(self: *Self, allocator: std.mem.Allocator, ctx: *engine.Context) !void {
        _ = self;
        _ = allocator;
        _ = ctx;
    }
    pub fn update(self: *Self, ctx: *engine.Context, dt: f32) !void {
        _ = self;
        _ = ctx;
        _ = dt;
    }
    pub fn draw(self: *Self, ctx: *engine.Context) !void {
        _ = self;
        _ = ctx;
    }
    pub fn shutdown(self: *Self, ctx: *engine.Context) void {
        _ = self;
        _ = ctx;
    }
};
