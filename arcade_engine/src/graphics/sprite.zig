const Rect = @import("../types.zig").Rect;
const Texture = @import("../types.zig").Texture;

const std = @import("std");

pub const Flip = enum {
    none,
    x,
    y,
    both,
};

pub const MAX_IDLE_FRAMES: usize = 6;
pub const MAX_ROT_FRAMES: usize = 6;
pub const SpriteFrame = Rect;
pub const SpriteResult = struct {
    frame: SpriteFrame,
    flip: Flip,
};

pub const Sprite = struct {
    idle_frames: [MAX_IDLE_FRAMES]SpriteFrame,
    idle_count: usize,

    rotation_frames: [MAX_ROT_FRAMES]SpriteFrame,
    rotation_count: usize,

    pub fn init(idle_src: []const SpriteFrame, rotation_src: []const SpriteFrame) !Sprite {
        if (idle_src.len > MAX_IDLE_FRAMES) return error.TooManyIdleFrames;
        if (rotation_src.len > MAX_ROT_FRAMES) return error.TooManyRotationFrames;

        var sprite = Sprite{
            .idle_frames = std.mem.zeroes([MAX_IDLE_FRAMES]SpriteFrame),
            .idle_count = idle_src.len,
            .rotation_frames = std.mem.zeroes([MAX_ROT_FRAMES]SpriteFrame),
            .rotation_count = rotation_src.len,
        };

        @memcpy(sprite.idle_frames[0..idle_src.len], idle_src);
        @memcpy(sprite.rotation_frames[0..rotation_src.len], rotation_src);

        return sprite;
    }

    pub fn getRotated(self: *const @This(), angle: f32) SpriteResult {
        var normalized = @mod(angle, 360.0);
        if (normalized < 0) normalized += 360.0;

        const flip = switch (@as(u32, @intFromFloat(normalized))) {
            0...89 => Flip.x,
            90...179 => Flip.both,
            180...269 => Flip.y,
            270...359 => Flip.none,
            else => Flip.none,
        };

        const flip_h = normalized < 180.0;
        var mapped = if (flip_h) 360.0 - normalized else normalized;
        if (mapped < 270.0) mapped = 540.0 - mapped;

        const frame_angle = @round((mapped - 270.0) / 15.0);
        const frame_index = @as(usize, @intFromFloat(@min(frame_angle, @as(f32, @floatFromInt(self.rotation_count - 1)))));

        return SpriteResult{
            .frame = self.rotation_frames[frame_index],
            .flip = flip,
        };
    }
};
