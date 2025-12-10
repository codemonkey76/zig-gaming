const Rect = @import("renderer").types.Rect;
const Texture = @import("renderer").types.Texture;

const std = @import("std");

pub const SpriteType = enum {
    // Player
    player,
    player_alt,

    // Enemies
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

    // Projectiles
    bullet,

    level_1,
    level_5,
    level_10,
    level_20,
    level_30,
    level_50,
};

pub const Flip = enum {
    none,
    x,
    y,
    both,
};

pub const MAX_IDLE_FRAMES: usize = 4;
pub const MAX_ROT_FRAMES: usize = 6;
pub const SpriteFrame = Rect;
pub const SpriteResult = struct {
    frame: SpriteFrame,
    flip: Flip,
};

pub const Sprite = struct {
    type: SpriteType,

    idle_frames: [MAX_IDLE_FRAMES]SpriteFrame, // switch between these when idle
    idle_count: usize,

    rotation_frames: [MAX_ROT_FRAMES]SpriteFrame, // 0-6, 0 = rotated -90 degrees, 0 = 0degrees
    rotation_count: usize,

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

        sprites.set(
            .goei,
            try createSprite(.goei, &[_]SpriteFrame{
                cell(6, 4),
                cell(7, 4),
            }, &[_]SpriteFrame{
                cell(0, 4),
                cell(1, 4),
                cell(2, 4),
                cell(3, 4),
                cell(4, 4),
                cell(5, 4),
            }),
        );

        sprites.set(
            .zako,
            try createSprite(.zako, &[_]SpriteFrame{
                cell(6, 5),
                cell(7, 5),
            }, &[_]SpriteFrame{
                cell(0, 5),
                cell(1, 5),
                cell(2, 5),
                cell(3, 5),
                cell(4, 5),
                cell(5, 5),
            }),
        );

        sprites.set(
            .scorpion,
            try createSprite(.scorpion, &[_]SpriteFrame{
                cell(6, 6),
            }, &[_]SpriteFrame{
                cell(0, 6),
                cell(1, 6),
                cell(2, 6),
                cell(3, 6),
                cell(4, 6),
                cell(5, 6),
            }),
        );

        sprites.set(
            .midori,
            try createSprite(.midori, &[_]SpriteFrame{
                cell(6, 7),
            }, &[_]SpriteFrame{
                cell(0, 7),
                cell(1, 7),
                cell(2, 7),
                cell(3, 7),
                cell(4, 7),
                cell(5, 7),
            }),
        );

        sprites.set(
            .galaxian,
            try createSprite(.galaxian, &[_]SpriteFrame{
                cell(6, 8),
            }, &[_]SpriteFrame{
                cell(0, 8),
                cell(1, 8),
                cell(2, 8),
                cell(3, 8),
                cell(4, 8),
                cell(5, 8),
            }),
        );

        sprites.set(
            .tombow,
            try createSprite(.tombow, &[_]SpriteFrame{
                cell(6, 9),
            }, &[_]SpriteFrame{
                cell(0, 9),
                cell(1, 9),
                cell(2, 9),
                cell(3, 9),
                cell(4, 9),
                cell(5, 9),
            }),
        );
        sprites.set(
            .momji,
            try createSprite(.momji, &[_]SpriteFrame{
                cell(0, 10),
                cell(1, 10),
                cell(2, 10),
            }, &[_]SpriteFrame{}),
        );

        sprites.set(
            .enterprise,
            try createSprite(.enterprise, &[_]SpriteFrame{
                cell(6, 11),
            }, &[_]SpriteFrame{
                cell(0, 11),
                cell(1, 11),
                cell(2, 11),
                cell(3, 11),
                cell(4, 11),
                cell(5, 11),
            }),
        );

        sprites.set(.level_1, try createSprite(.level_1, &[_]SpriteFrame{.{ .x = 307, .y = 172, .width = 8, .height = 16 }}, &[_]SpriteFrame{}));
        sprites.set(.level_5, try createSprite(.level_5, &[_]SpriteFrame{.{ .x = 317, .y = 172, .width = 8, .height = 16 }}, &[_]SpriteFrame{}));
        sprites.set(.level_10, try createSprite(.level_10, &[_]SpriteFrame{.{ .x = 327, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));
        sprites.set(.level_20, try createSprite(.level_20, &[_]SpriteFrame{.{ .x = 345, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));
        sprites.set(.level_30, try createSprite(.level_30, &[_]SpriteFrame{.{ .x = 363, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));
        sprites.set(.level_50, try createSprite(.level_50, &[_]SpriteFrame{.{ .x = 381, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));

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
