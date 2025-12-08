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
    texture: Texture,
    sprites: std.EnumArray(SpriteType, Sprite),

    pub fn getSprite(self: *const @This(), t: SpriteType) *const Sprite {
        return &self.sprites.get(t);
    }

    pub fn init(texture: Texture) !@This() {
        var sprites = std.EnumArray(SpriteType, Sprite).initUndefined();

        const player_idle_src = [_]SpriteFrame{
            .{ .x = 0, .y = 0, .width = 16, .height = 16 },
        };

        const player_rot_src = [_]SpriteFrame{
            .{ .x = 0, .y = 0, .width = 16, .height = 16 },
        };

        sprites.set(
            .player,
            createSprite(
                .player,
                &player_idle_src,
                &player_rot_src,
            ),
        );

        return .{
            .texture = texture,
            .sprites = sprites,
        };
    }

    pub fn createSprite(
        sprite_type: SpriteType,
        idle_src: []const SpriteFrame,
        rot_src: []const SpriteFrame,
    ) Sprite {
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
