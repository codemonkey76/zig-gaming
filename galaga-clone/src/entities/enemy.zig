const std = @import("std");
const Vec2 = @import("renderer").types.Vec2;
const SpriteType = @import("../graphics/sprite.zig").SpriteType;
const PatternType = @import("../level/pattern_registry.zig").PatternType;
const PathDefinition = @import("../level/path_definition.zig").PathDefinition;
const SpawnResult = @import("../level/level_definition.zig").SpawnResult;

pub const Enemy = struct {
    enemy_type: SpriteType,
    position: Vec2,
    state: EnemyState,

    // Formation info
    target_col: ?u8,
    target_row: ?u8,
    is_transient: bool,

    // Path info
    entry_path: PathDefinition,
    path_timer: f32 = 0.0,

    // State
    is_dead: bool = false,
    health: i32 = 1,

    pub const EnemyState = enum {
        entering, // Following entry path
        entering_formation, // Transitioning to formation slot
        in_formation, // Sitting in formation
        diving, // Attacking player
        returning, // Returning to formation
        leaving, // Transient enemy leaving screen
    };

    pub fn init(spawn_result: SpawnResult) Enemy {
        const path = spawn_result.pattern.getPath();

        return .{
            .enemy_type = spawn_result.enemy.enemy_type,
            .position = path.getStartPosition(),
            .state = .entering,
            .target_col = spawn_result.enemy.col,
            .target_row = spawn_result.enemy.row,
            .is_transient = spawn_result.is_transient,
            .entry_path = path,
        };
    }
    pub fn getCollisionBounds(self: *const @This()) CollisionBounds {
        const width = 0.03;
        const height = 0.03;
        return .{
            .min_x = self.position.x - width / 2.0,
            .max_x = self.position.x + width / 2.0,
            .min_y = self.position.y - height / 2.0,
            .max_y = self.position.y + height / 2.0,
        };
    }

    pub const CollisionBounds = struct {
        min_x: f32,
        max_x: f32,
        min_y: f32,
        max_y: f32,
    };
    pub fn update(self: *@This(), dt: f32, ctx: anytype) void {
        switch (self.state) {
            .entering => self.updateEntering(dt, ctx),
            .entering_formation => self.updateEnteringFormation(dt, ctx),
            .in_formation => self.updateInFormation(dt, ctx),
            .diving => self.updateDiving(dt, ctx),
            .returning => self.updateReturning(dt, ctx),
            .leaving => self.updateLeaving(dt, ctx),
        }
    }

    fn updateEntering(self: *@This(), dt: f32, ctx: anytype) void {
        _ = ctx;
        self.path_timer += dt;

        // Calculate normalized t (0.0 to 1.0)
        const t = self.path_timer / self.entry_path.total_duration;

        if (t >= 1.0) {
            // Path complete
            if (self.is_transient) {
                self.state = .leaving;
                self.path_timer = 0.0;
            } else {
                self.state = .entering_formation;
                self.path_timer = 0.0;
            }
        } else {
            // Update position along path
            self.position = self.entry_path.getPosition(t);
        }
    }

    fn updateEnteringFormation(self: *@This(), dt: f32, ctx: anytype) void {
        const speed = 2.0;
        self.path_timer += dt * speed;

        if (self.target_col) |col| {
            if (self.target_row) |row| {
                const target = ctx.formation_grid.getPosition(col, row);

                // Lerp to formation position
                const t = @min(self.path_timer, 1.0);
                const current_pos = self.entry_path.getEndPosition();

                self.position.x = current_pos.x * (1.0 - t) + target.x * t;
                self.position.y = current_pos.y * (1.0 - t) + target.y * t;

                if (self.path_timer >= 1.0) {
                    self.state = .in_formation;
                    ctx.formation_grid.addShip();
                }
            }
        }
    }

    fn updateInFormation(self: *@This(), dt: f32, ctx: anytype) void {
        _ = dt;
        // Follow formation grid position (handles breathing)
        if (self.target_col) |col| {
            if (self.target_row) |row| {
                self.position = ctx.formation_grid.getPosition(col, row);
            }
        }

        // TODO: Randomly decide to dive attack
    }

    fn updateDiving(self: *@This(), dt: f32, ctx: anytype) void {
        _ = self;
        _ = dt;
        _ = ctx;
        // TODO: Implement dive attack pattern
    }

    fn updateReturning(self: *@This(), dt: f32, ctx: anytype) void {
        _ = self;
        _ = dt;
        _ = ctx;
        // TODO: Return to formation after dive
    }

    fn updateLeaving(self: *@This(), dt: f32, ctx: anytype) void {
        _ = ctx;
        const speed = 0.5;
        self.path_timer += dt * speed;

        // Continue in current direction off screen
        self.position.x += dt * speed * 0.5;

        if (self.position.x > 1.2 or self.position.x < -0.2) {
            self.is_dead = true;
        }
    }

    pub fn takeDamage(self: *@This(), damage: i32) void {
        self.health -= damage;
        if (self.health <= 0) {
            self.is_dead = true;
        }
    }
};
