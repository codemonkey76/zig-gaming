const std = @import("std");
const engine = @import("engine");

const Starfield = @import("graphics/starfield.zig").Starfield;

pub const GameState = struct {
    starfield: Starfield,

    const Self = @This();

    pub fn init(self: *Self, allocator: std.mem.Allocator, ctx: *engine.Context) !void {
        self.starfield = try Starfield.init(allocator, ctx, .{});
    }
    pub fn update(self: *Self, ctx: *engine.Context, dt: f32) !void {
        self.starfield.update(dt, ctx);
    }
    pub fn draw(self: *Self, ctx: *engine.Context) !void {
        self.starfield.draw(ctx);
    }
    pub fn shutdown(self: *Self, ctx: *engine.Context) void {
        self.starfield.deinit();
        _ = ctx;
    }
};
