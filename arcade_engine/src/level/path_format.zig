const std = @import("std");
const Vec2 = @import("../types.zig").Vec2;

pub const MAGIC: [4]u8 = .{ 'G', 'P', 'T', 'H' };
pub const VERSION: u8 = 1;

pub const PathHeader = packed struct {
    magic: [4]u8,
    version: u8,
    name_length: u8,
    duration_bits: u32,
    point_count: u16,
    reserved: [8]u8,

    pub fn getDuration(self: @This()) f32 {
        return @bitCast(self.duration_bits);
    }

    pub fn setDuration(self: *@This(), value: f32) void {
        self.duration_bits = @bitCast(value);
    }
};

pub const PathPoint = packed struct {
    x_bits: u32,
    y_bits: u32,

    pub fn getVec2(self: @This()) Vec2 {
        return Vec2{
            .x = @bitCast(self.x_bits),
            .y = @bitCast(self.y_bits),
        };
    }

    pub fn fromVec2(vec: Vec2) PathPoint {
        return .{
            .x_bits = @bitCast(vec.x),
            .y_bits = @bitCast(vec.y),
        };
    }
};
