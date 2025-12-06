const std = @import("std");
const Input = @import("renderer").types.Input;
const Color = @import("renderer").types.Color;

const TRANSITION_DELAY = 5.0;

pub const Attract = struct {
    timer: f32,

    pub fn init(allocator: std.mem.Allocator) @This() {
        _ = allocator;
        return .{ .timer = 0 };
    }

    pub fn update(self: *@This(), dt: f32, input: Input) void {
        _ = input;
        self.timer += dt;
    }
    pub fn shouldTransition(self: *const @This()) bool {
        return self.timer > TRANSITION_DELAY;
    }

    pub fn draw(self: *const @This(), renderer: anytype) void {
        _ = self;
        renderer.drawText("Attract Mode", .{ .x = 10, .y = 10 }, 24, Color.white);
    }
};
