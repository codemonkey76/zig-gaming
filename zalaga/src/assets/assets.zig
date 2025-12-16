const std = @import("std");
const engine = @import("engine");

pub const Assets = struct {
    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, ctx: *engine.Context) !void {
        _ = allocator;
        _ = ctx;
    }

    pub fn deinit(self: *Self) void {
        _ = self;
    }
};
