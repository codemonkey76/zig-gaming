const std = @import("std");
const Input = @import("renderer").types.Input;
const Color = @import("renderer").types.Color;

pub const Playing = struct {
    pub fn init(allocator: std.mem.Allocator) @This() {
        _ = allocator;
        return .{};
    }

    pub fn update(self: *@This(), dt: f32, input: Input) void {
        _ = self;
        _ = dt;
        _ = input;
    }

    pub fn draw(self: *const @This(), renderer: anytype) void {
        _ = self;
        renderer.drawText("Playing Mode", .{ .x = 10, .y = 10 }, 24, Color.white);
    }
};
