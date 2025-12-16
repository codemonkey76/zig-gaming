const std = @import("std");
const levelDef = @import("level_definition.zig");
const LevelPhase = levelDef.LevelPhase;
const SpawnResult = levelDef.SpawnResult;

pub const LevelManager = struct {
    current_level: u8 = 1,
    current_wave: usize = 0,
    wave_timer: f32 = 0.0,
    group1_spawned: usize = 0,
    group2_spawned: usize = 0,
    phase: LevelPhase = .spawning,

    formation_enemies_spawned: u32 = 0,
    formation_enemies_alive: u32 = 0,

    pub fn init() @This() {
        return .{};
    }

    pub fn startLevel(self: *@This(), level_number: u8) void {
        self.current_level = level_number;
        self.current_wave = 0;
        self.wave_timer = 0.0;
        self.group1_spawned = 0;
        self.group2_spawned = 0;
        self.phase = .spawning;
        self.formation_enemies_spawned = 0;
        self.formation_enemies_alive = 0;
    }

    pub fn update(self: *@This(), dt: f32) ?SpawnResult {
        const getLevelDefinition = @import("level_definition.zig").getLevelDefinition;
        const level_def = getLevelDefinition(self.current_level) orelse return null;

        if (self.current_wave >= level_def.waves.len) {
            self.phase = .combat;
            return null;
        }

        const wave = level_def.waves[self.current_wave];
        self.wave_timer += dt;

        // Try to spawn from group 1
        if (self.group1_spawned < wave.group1.enemies.len) {
            const spawn_time = @as(f32, @floatFromInt(self.group1_spawned)) * wave.group1.spawn_interval;
            if (self.wave_timer >= spawn_time) {
                const enemy = wave.group1.enemies[self.group1_spawned];
                self.group1_spawned += 1;

                if (enemy.col != null and enemy.row != null) {
                    self.formation_enemies_spawned += 1;
                    self.formation_enemies_alive += 1;
                }
                return SpawnResult{
                    .enemy = enemy,
                    .pattern = wave.group1.pattern,
                    .is_transient = (enemy.col == null or enemy.row == null),
                };
            }
        }

        // Try to spawn from group 2
        if (wave.group2) |group2| {
            if (self.group2_spawned < group2.enemies.len) {
                const spawn_time = @as(f32, @floatFromInt(self.group2_spawned)) * group2.spawn_interval;
                if (self.wave_timer >= spawn_time) {
                    const enemy = group2.enemies[self.group2_spawned];
                    self.group2_spawned += 1;

                    if (enemy.col != null and enemy.row != null) {
                        self.formation_enemies_spawned += 1;
                        self.formation_enemies_alive += 1;
                    }

                    return SpawnResult{
                        .enemy = enemy,
                        .pattern = group2.pattern,
                        .is_transient = (enemy.col == null or enemy.row == null),
                    };
                }
            }
        }

        return null;
    }

    pub fn isCurrentWaveFinishedSpawning(self: *const @This()) bool {
        const getLevelDefinition = @import("level_definition.zig").getLevelDefinition;
        const level_def = getLevelDefinition(self.current_level) orelse return true;

        if (self.current_wave >= level_def.waves.len) return true;

        const wave = level_def.waves[self.current_wave];

        const group1_done = self.group1_spawned >= wave.group1.enemies.len;
        const group2_done = if (wave.group2) |g2|
            self.group2_spawned >= g2.enemies.len
        else
            true;

        return group1_done and group2_done;
    }

    pub fn advanceWave(self: *@This()) void {
        const getLevelDefinition = @import("level_definition.zig").getLevelDefinition;
        const level_def = getLevelDefinition(self.current_level) orelse return;

        std.debug.print("Level {d}: finished wave {d}\n", .{
            self.current_level,
            self.current_wave + 1,
        });

        self.current_wave += 1;
        self.wave_timer = 0.0;
        self.group1_spawned = 0;
        self.group2_spawned = 0;

        if (self.current_wave >= level_def.waves.len) {
            self.phase = .combat;
        }
    }

    pub fn onFormationEnemyDestroyed(self: *@This()) void {
        if (self.formation_enemies_alive > 0) {
            self.formation_enemies_alive -= 1;

            if (self.phase == .combat and self.formation_enemies_alive == 0) {
                self.phase = .complete;
            }
        }
    }

    pub fn isLevelComplete(self: *const @This()) bool {
        return self.phase == .complete;
    }

    pub fn isSpawningComplete(self: *const @This()) bool {
        return self.phase == .combat or self.phase == .complete;
    }

    pub fn getPhase(self: *const @This()) LevelPhase {
        return self.phase;
    }
};
