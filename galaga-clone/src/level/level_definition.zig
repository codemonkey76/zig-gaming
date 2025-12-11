pub const SpriteType = @import("../graphics/sprite.zig").SpriteType;
pub const PatternType = @import("pattern_registry.zig").PatternType;

pub const LevelDefinition = struct {
    level_number: u8,
    stage_type: StageType,
    waves: []const Wave,
};

pub const StageType = enum {
    normal,
    challenge,
};

pub const EnemySpawn = struct {
    enemy_type: SpriteType,

    col: ?u8 = null,
    row: ?u8 = null,
};

pub const Wave = struct {
    group1: EnemyGroup,
    group2: ?EnemyGroup = null,

    delay: f32 = 0,
};

pub const EnemyGroup = struct {
    enemies: []const EnemySpawn,
    pattern: PatternType,
    spawn_interval: f32 = 0.2,
};

pub const Levels = struct {
    pub const level_1: LevelDefinition = .{
        .level_number = 1,
        .stage_type = .normal,
        .waves = &[_]Wave{
            // Wave 1: 4 x Goei from left, 4 x Zako from right (simultaneous)
            .{
                .group1 = .{
                    .enemies = &[_]EnemySpawn{
                        .{ .enemy_type = .goei, .col = 4, .row = 2 },
                        .{ .enemy_type = .goei, .col = 5, .row = 2 },
                        .{ .enemy_type = .goei, .col = 4, .row = 3 },
                        .{ .enemy_type = .goei, .col = 5, .row = 3 },
                    },
                    .pattern = .swoop_left,
                    .spawn_interval = 0.2,
                },
                .group2 = .{
                    .enemies = &[_]EnemySpawn{
                        .{ .enemy_type = .zako, .col = 4, .row = 4 },
                        .{ .enemy_type = .zako, .col = 5, .row = 4 },
                        .{ .enemy_type = .zako, .col = 4, .row = 5 },
                        .{ .enemy_type = .zako, .col = 5, .row = 5 },
                    },
                    .pattern = .swoop_right,
                    .spawn_interval = 0.2,
                },
            },
            // Wave 2: 4 x Boss, 4 x Goei (interleaved)
            .{
                .group1 = .{
                    .enemies = &[_]EnemySpawn{
                        .{ .enemy_type = .goei, .col = 3, .row = 2 },
                        .{ .enemy_type = .boss, .col = 4, .row = 1 },
                        .{ .enemy_type = .goei, .col = 6, .row = 3 },
                        .{ .enemy_type = .boss, .col = 5, .row = 1 },
                        .{ .enemy_type = .goei, .col = 6, .row = 2 },
                        .{ .enemy_type = .boss, .col = 3, .row = 1 },
                        .{ .enemy_type = .goei, .col = 3, .row = 3 },
                        .{ .enemy_type = .boss, .col = 6, .row = 1 },
                    },
                    .pattern = .swoop_left,
                    .spawn_interval = 0.2,
                },
            },
            // Wave 3: 8 x goei
            .{
                .group1 = .{
                    .enemies = &[_]EnemySpawn{
                        .{ .enemy_type = .goei, .col = 2, .row = 2 },
                        .{ .enemy_type = .goei, .col = 7, .row = 3 },
                        .{ .enemy_type = .goei, .col = 1, .row = 2 },
                        .{ .enemy_type = .goei, .col = 8, .row = 3 },
                        .{ .enemy_type = .goei, .col = 7, .row = 2 },
                        .{ .enemy_type = .goei, .col = 2, .row = 3 },
                        .{ .enemy_type = .goei, .col = 8, .row = 2 },
                        .{ .enemy_type = .goei, .col = 1, .row = 3 },
                    },
                    .pattern = .swoop_left,
                    .spawn_interval = 0.2,
                },
            },
            // Wave 4: 8 x zako
            .{
                .group1 = .{
                    .enemies = &[_]EnemySpawn{
                        .{ .enemy_type = .zako, .col = 3, .row = 4 },
                        .{ .enemy_type = .zako, .col = 6, .row = 4 },
                        .{ .enemy_type = .zako, .col = 3, .row = 5 },
                        .{ .enemy_type = .zako, .col = 6, .row = 5 },
                        .{ .enemy_type = .zako, .col = 2, .row = 4 },
                        .{ .enemy_type = .zako, .col = 7, .row = 4 },
                        .{ .enemy_type = .zako, .col = 2, .row = 5 },
                        .{ .enemy_type = .zako, .col = 7, .row = 5 },
                    },
                    .pattern = .swoop_left,
                    .spawn_interval = 0.2,
                },
            },
            // Wave 5: 8 x zako
            .{
                .group1 = .{
                    .enemies = &[_]EnemySpawn{
                        .{ .enemy_type = .zako, .col = 1, .row = 4 },
                        .{ .enemy_type = .zako, .col = 8, .row = 4 },
                        .{ .enemy_type = .zako, .col = 1, .row = 5 },
                        .{ .enemy_type = .zako, .col = 8, .row = 5 },
                        .{ .enemy_type = .zako, .col = 0, .row = 4 },
                        .{ .enemy_type = .zako, .col = 9, .row = 4 },
                        .{ .enemy_type = .zako, .col = 0, .row = 5 },
                        .{ .enemy_type = .zako, .col = 9, .row = 5 },
                    },
                    .pattern = .swoop_left,
                    .spawn_interval = 0.2,
                },
            },
        },
    };
};

pub fn getLevelDefinition(level_number: u8) ?LevelDefinition {
    return switch (level_number) {
        1 => Levels.level_1,
        else => null,
    };
}

pub const LevelPhase = enum {
    spawning,
    combat,
    complete,
};

pub const SpawnResult = struct {
    enemy: EnemySpawn,
    pattern: PatternType,
    is_transient: bool,
};
