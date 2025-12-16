const std = @import("std");
const engine = @import("engine");

pub const Assets = struct {
    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, ctx: *engine.Context) !Assets {
        _ = allocator;
        _ = ctx;
        return .{};
    }

    pub fn deinit(self: *Self, ctx: *engine.Context) void {
        _ = self;
        _ = ctx;
    }
};
