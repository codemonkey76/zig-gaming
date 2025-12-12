const std = @import("std");
const Vec2 = @import("renderer").types.Vec2;

pub const MAGIC: [4]u8 = .{ 'G', 'P', 'T', 'H' };
pub const VERSION: u8 = 1;

pub const PathHeader = packed struct {
    magic: u32,
    version: u8,
    name_length: u8,
    duration_bits: u32,
    point_count: u16,
    reserved: u64,

    pub fn getDuration(self: @This()) f32 {
        return @bitCast(self.duration_bits);
    }

    pub fn setDuration(self: *@This(), value: f32) void {
        self.duration_bits = @bitCast(value);
    }
    pub fn setMagic(self: *@This()) void {
        self.magic = @bitCast(MAGIC);
    }

    pub fn checkMagic(self: @This()) bool {
        const magic_bytes: [4]u8 = @bitCast(self.magic);
        return std.mem.eql(u8, &magic_bytes, &MAGIC);
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

    pub fn fromVec2(vec: Vec2) @This() {
        return .{
            .x_bits = @bitCast(vec.x),
            .y_bits = @bitCast(vec.y),
        };
    }
};
