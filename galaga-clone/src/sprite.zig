const Rect = @import("renderer").types.Rect;
const Texture = @import("renderer").types.Texture;

const std = @import("std");

pub const SpriteType = enum {
    player,
    boss,
    goei,
    zako,
    scorpion,
    midori,
    galaxian,
    tombow,
    momji,
    enterprise,
};

pub const MAX_IDLE_FRAMES: usize = 4;
pub const MAX_ROT_FRAMES: usize = 6;
pub const SpriteFrame = Rect;
pub const Sprite = struct {
    type: SpriteType,

    idle_frames: [MAX_IDLE_FRAMES]SpriteFrame, // switch between these when idle
    idle_count: usize,

    rotation_frames: [MAX_ROT_FRAMES]SpriteFrame, // 0-6, 0 = rotated -90 degrees, 0 = 0degrees
    rotation_count: usize,
};

pub const SpriteAtlas = struct {
    sprites: std.EnumArray(SpriteType, Sprite),

    pub fn getSprite(self: *const @This(), t: SpriteType) Sprite {
        return self.sprites.get(t);
    }

    pub fn init() !@This() {
        var sprites = std.EnumArray(SpriteType, Sprite).initUndefined();

        // Initialize all enum entries with a safe default
        inline for (std.meta.tags(SpriteType)) |tag| {
            sprites.set(tag, emptySprite(tag));
        }

        const player_idle_src = [_]SpriteFrame{
            .{ .x = 6 * (16 + 2) + 1, .y = 1, .width = 16, .height = 16 },
        };

        const player_rot_src = [_]SpriteFrame{
            .{ .x = 0, .y = 0, .width = 16, .height = 16 },
        };

        sprites.set(
            .player,
            try createSprite(
                .player,
                &player_idle_src,
                &player_rot_src,
            ),
        );

        return .{
            .sprites = sprites,
        };
    }

    fn emptySprite(t: SpriteType) Sprite {
        return .{
            .type = t,
            .idle_frames = std.mem.zeroes([MAX_IDLE_FRAMES]SpriteFrame),
            .idle_count = 0,
            .rotation_frames = std.mem.zeroes([MAX_ROT_FRAMES]SpriteFrame),
            .rotation_count = 0,
        };
    }

    pub fn createSprite(
        sprite_type: SpriteType,
        idle_src: []const SpriteFrame,
        rot_src: []const SpriteFrame,
    ) !Sprite {
        if (idle_src.len > MAX_IDLE_FRAMES) return error.TooManyIdleFrames;
        if (rot_src.len > MAX_ROT_FRAMES) return error.TooManyRotationFrames;

        var sprite = Sprite{
            .type = sprite_type,
            .idle_frames = std.mem.zeroes([MAX_IDLE_FRAMES]SpriteFrame),
            .idle_count = idle_src.len,
            .rotation_frames = std.mem.zeroes([MAX_ROT_FRAMES]SpriteFrame),
            .rotation_count = rot_src.len,
        };

        @memcpy(sprite.idle_frames[0..idle_src.len], idle_src);
        @memcpy(sprite.rotation_frames[0..rot_src.len], rot_src);

        return sprite;
    }
};
