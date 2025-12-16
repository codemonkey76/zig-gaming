const engine = @import("arcade_engine");
const Sprite = engine.graphics.Sprite;
const SpriteFrame = engine.graphics.SpriteFrame;
const SpriteResult = engine.graphics.SpriteResult;
const Flip = engine.graphics.Flip;
const MAX_IDLE_FRAMES = engine.graphics.MAX_IDLE_FRAMES;
const MAX_ROT_FRAMES = engine.graphics.MAX_ROT_FRAMES;
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
    bullet_player,
    bullet_enemy,

    // Explosions
    explosion_player,
    explosion_enemy,

    level_1,
    level_5,
    level_10,
    level_20,
    level_30,
    level_50,
};

pub const SpriteAtlas = struct {
    atlas: engine.graphics.SpriteAtlas(SpriteType),

    pub fn init() !@This() {
        var atlas = engine.graphics.SpriteAtlas(SpriteType).init();

        atlas.set(
            .player,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .player_alt,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .boss,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .boss_alt,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .goei,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .zako,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .scorpion,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .midori,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .galaxian,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .tombow,
            try Sprite.init(&[_]SpriteFrame{
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
        atlas.set(
            .momji,
            try Sprite.init(&[_]SpriteFrame{
                cell(0, 10),
                cell(1, 10),
                cell(2, 10),
            }, &[_]SpriteFrame{}),
        );

        atlas.set(
            .enterprise,
            try Sprite.init(&[_]SpriteFrame{
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

        atlas.set(
            .bullet_player,
            try Sprite.init(&[_]SpriteFrame{
                .{ .x = 307, .y = 118, .width = 16, .height = 16 },
            }, &[_]SpriteFrame{}),
        );

        atlas.set(
            .bullet_enemy,
            try Sprite.init(&[_]SpriteFrame{
                .{ .x = 307, .y = 136, .width = 16, .height = 16 },
            }, &[_]SpriteFrame{}),
        );

        atlas.set(
            .explosion_player,
            try Sprite.init(&[_]SpriteFrame{
                .{ .x = 145, .y = 1, .width = 32, .height = 32 },
                .{ .x = 179, .y = 1, .width = 32, .height = 32 },
                .{ .x = 213, .y = 1, .width = 32, .height = 32 },
                .{ .x = 247, .y = 1, .width = 32, .height = 32 },
            }, &[_]SpriteFrame{}),
        );

        atlas.set(
            .explosion_enemy,
            try Sprite.init(&[_]SpriteFrame{
                .{ .x = 289, .y = 1, .width = 32, .height = 32 },
                .{ .x = 323, .y = 1, .width = 32, .height = 32 },
                .{ .x = 357, .y = 1, .width = 32, .height = 32 },
                .{ .x = 391, .y = 1, .width = 32, .height = 32 },
                .{ .x = 425, .y = 1, .width = 32, .height = 32 },
            }, &[_]SpriteFrame{}),
        );

        atlas.set(.level_1, try Sprite.init(&[_]SpriteFrame{.{ .x = 307, .y = 172, .width = 8, .height = 16 }}, &[_]SpriteFrame{}));
        atlas.set(.level_5, try Sprite.init(&[_]SpriteFrame{.{ .x = 317, .y = 172, .width = 8, .height = 16 }}, &[_]SpriteFrame{}));
        atlas.set(.level_10, try Sprite.init(&[_]SpriteFrame{.{ .x = 327, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));
        atlas.set(.level_20, try Sprite.init(&[_]SpriteFrame{.{ .x = 345, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));
        atlas.set(.level_30, try Sprite.init(&[_]SpriteFrame{.{ .x = 363, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));
        atlas.set(.level_50, try Sprite.init(&[_]SpriteFrame{.{ .x = 381, .y = 172, .width = 16, .height = 16 }}, &[_]SpriteFrame{}));

        return .{
            .atlas = atlas,
        };
    }
    pub fn getSprite(self: *const @This(), sprite_type: SpriteType) Sprite {
        return self.atlas.get(sprite_type);
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
        idle_src: []const SpriteFrame,
        rot_src: []const SpriteFrame,
    ) !Sprite {
        if (idle_src.len > MAX_IDLE_FRAMES) return error.TooManyIdleFrames;
        if (rot_src.len > MAX_ROT_FRAMES) return error.TooManyRotationFrames;

        var sprite = Sprite{
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
