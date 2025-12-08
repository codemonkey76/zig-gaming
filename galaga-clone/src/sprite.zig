const Rect = @import("renderer").types.Rect;
const Texture = @import("renderer").types.Texture;

const std = @import("std");

pub const SpriteType = enum {
    player,
    player_alt,
    boss,
    boss_alt,
    goei,
    zako,
    scorpion,
    midori,
    galaxian,
    tombow,
    momji,
    enterprise,
};

pub const Flip = enum {
    none,
    x,
    y,
    both,
};

pub const MAX_IDLE_FRAMES: usize = 4;
pub const MAX_ROT_FRAMES: usize = 6;
pub const SpriteFrame = struct {
    src: Rect,
    flip: Flip = .none,
};

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

        sprites.set(
            .player,
            try createSprite(.player, &[_]SpriteFrame{
                cell(6, 0),
            }, &[_]SpriteFrame{
                cell(0, 0),
                cell(1, 0),
                cell(2, 0),
                cell(3, 0),
                cell(4, 0),
                cell(5, 0),
            }),
        );

        sprites.set(
            .player_alt,
            try createSprite(.player_alt, &[_]SpriteFrame{
                cell(6, 1),
            }, &[_]SpriteFrame{
                cell(0, 1),
                cell(1, 1),
                cell(2, 1),
                cell(3, 1),
                cell(4, 1),
                cell(5, 1),
            }),
        );

        sprites.set(
            .boss,
            try createSprite(.boss, &[_]SpriteFrame{
                cell(6, 2),
                cell(7, 2),
            }, &[_]SpriteFrame{
                cell(0, 2),
                cell(1, 2),
                cell(2, 2),
                cell(3, 2),
                cell(4, 2),
                cell(5, 2),
            }),
        );

        sprites.set(
            .boss_alt,
            try createSprite(.boss, &[_]SpriteFrame{
                cell(6, 3),
                cell(7, 3),
            }, &[_]SpriteFrame{
                cell(0, 3),
                cell(1, 3),
                cell(2, 3),
                cell(3, 3),
                cell(4, 3),
                cell(5, 3),
            }),
        );
        return .{
            .sprites = sprites,
        };
    }

    const TILE = 16;
    const SPACING = 2;
    const OFFSET = 1;

    fn cell(x: usize, y: usize) SpriteFrame {
        return .{
            .x = col(x),
            .y = row(y),
            .width = TILE,
            .height = TILE,
        };
    }

    fn col(x: usize) f32 {
        return @as(f32, @floatFromInt(x * (TILE + SPACING) + OFFSET));
    }
    fn row(y: usize) f32 {
        return @as(f32, @floatFromInt(y * (TILE + SPACING) + OFFSET));
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
