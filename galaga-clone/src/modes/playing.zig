const std = @import("std");
const r = @import("renderer");

const LevelDefinition = @import("../level/level_definition.zig");
const LevelManager = @import("../level/level_manager.zig").LevelManager;
const SpawnResult = LevelDefinition.SpawnResult;
const PatternType = LevelDefinition.PatternType;
const Input = r.types.Input;
const Color = r.types.Color;
const Vec2 = r.types.Vec2;
const TextGrid = r.TextGrid;
const Texture = r.types.Texture;
const FormationGrid = r.FormationGrid;
const SpriteType = @import("../graphics/sprite.zig").SpriteType;
const MutableGameContext = @import("../context.zig").MutableGameContext;
const GameContext = @import("../context.zig").GameContext;
const Key = r.types.Key;
const LevelIndicator = @import("../ui/level_indicator.zig").LevelIndicator;
const LifeIndicator = @import("../ui/life_indicator.zig").LifeIndicator;
const common = @import("common.zig");
const Enemy = @import("../entities/enemy.zig").Enemy;
const Player = @import("../entities/player.zig").Player;
const Bullet = @import("../entities/bullet.zig").Bullet;
const BulletOwner = @import("../entities/bullet.zig").BulletOwner;
const Explosion = @import("../entities/explosion.zig").Explosion;
const ExplosionType = @import("../entities/explosion.zig").ExplosionType;

pub const Playing = struct {
    level_manager: LevelManager,
    level_indicator: LevelIndicator,
    life_indicator: LifeIndicator,
    enemies: std.ArrayList(Enemy),
    bullets: std.ArrayList(Bullet),
    explosions: std.ArrayList(Explosion),
    allocator: std.mem.Allocator,
    player: Player,

    pub const keys = [_]Key{
        .left,
        .right,
        .space,
        .a,
        .up,
    };

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .level_manager = LevelManager.init(),
            .level_indicator = LevelIndicator.init(),
            .life_indicator = LifeIndicator.init(),
            .enemies = std.ArrayList(Enemy).empty,
            .bullets = std.ArrayList(Bullet).empty,
            .explosions = std.ArrayList(Explosion).empty,
            .allocator = allocator,
            .player = Player.init(0.5, 0.9),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.enemies.deinit(self.allocator);
        self.bullets.deinit(self.allocator);
        self.explosions.deinit(self.allocator);
    }

    // Add this function!
    fn spawnEnemy(self: *@This(), spawn_result: SpawnResult, ctx: MutableGameContext) void {
        _ = ctx;
        const enemy = Enemy.init(spawn_result);
        self.enemies.append(self.allocator, enemy) catch {
            std.debug.print("Failed to spawn enemy\n", .{});
        };
    }

    // Add this function!
    fn onLevelComplete(self: *@This(), ctx: MutableGameContext) void {
        const next_stage = ctx.game_state.current_stage + 1;
        std.debug.print("Stage {} complete! Starting stage {}\n", .{
            ctx.game_state.current_stage,
            next_stage,
        });

        ctx.game_state.current_stage = next_stage;
        self.level_manager.startLevel(next_stage);
        self.enemies.clearRetainingCapacity();
    }

    pub fn onEnter(self: *@This(), ctx: MutableGameContext) void {
        common.registerKeys(ctx, &keys);
        self.level_manager.startLevel(ctx.game_state.current_stage);
        self.enemies.clearRetainingCapacity();
        self.bullets.clearRetainingCapacity();
        self.explosions.clearRetainingCapacity();
        self.player = Player.init(0.5, 0.9);
    }

    pub fn onExit(_: *@This(), ctx: MutableGameContext) void {
        common.unregisterKeys(ctx, &keys);
    }

    pub fn shouldTransition(_: *const @This()) bool {
        return false;
    }

    pub fn update(self: *@This(), dt: f32, input: *Input, ctx: MutableGameContext) void {
        self.handlePlayerMovement(dt, input);
        self.player.update(dt);

        if (input.isKeyPressed(.space) and self.player.canShoot()) {
            if (self.countPlayerBullets() < 2) {
                self.spawnBullet(self.player.position, .player);
                self.player.shoot();
            }
        }

        for (self.bullets.items) |*bullet| {
            bullet.update(dt);
        }

        if (self.level_manager.update(dt)) |spawn_result| {
            self.spawnEnemy(spawn_result, ctx);
        }

        for (self.enemies.items) |*enemy| {
            enemy.update(dt, ctx);
        }

        for (self.explosions.items) |*explosion| {
            explosion.update(dt);
        }

        self.checkCollisions();

        var i: usize = 0;
        while (i < self.bullets.items.len) {
            if (self.bullets.items[i].is_dead) {
                _ = self.bullets.swapRemove(i);
            } else {
                i += 1;
            }
        }

        i = 0;
        while (i < self.explosions.items.len) {
            if (self.explosions.items[i].is_dead) {
                _ = self.explosions.swapRemove(i);
            } else {
                i += 1;
            }
        }

        i = 0;
        while (i < self.enemies.items.len) {
            if (self.enemies.items[i].is_dead) {
                const enemy = self.enemies.swapRemove(i);

                if (!enemy.is_transient) {
                    self.level_manager.onFormationEnemyDestroyed();
                }
            } else {
                i += 1;
            }
        }

        if (self.level_manager.isCurrentWaveFinishedSpawning() and !self.level_manager.isSpawningComplete() and self.allFormationEnemiesSettled()) {
            self.level_manager.advanceWave();
        }

        if (self.level_manager.isLevelComplete()) {
            self.onLevelComplete(ctx);
        }

        self.handleKeys(input, ctx);
    }

    fn spawnExplosion(self: *@This(), position: Vec2, explosion_type: ExplosionType) void {
        const explosion = Explosion.init(position, explosion_type);
        self.explosions.append(self.allocator, explosion) catch {
            std.debug.print("Failed to spawn explosion\n", .{});
        };
    }

    fn countPlayerBullets(self: *const @This()) usize {
        var count: usize = 0;
        for (self.bullets.items) |*bullet| {
            if (!bullet.is_dead and bullet.owner == .player) {
                count += 1;
            }
        }
        return count;
    }

    fn spawnBullet(self: *@This(), position: Vec2, owner: BulletOwner) void {
        const bullet = Bullet.init(position, owner);
        self.bullets.append(self.allocator, bullet) catch {
            std.debug.print("Failed to spawn bullet\n", .{});
        };
    }

    fn checkCollisions(self: *@This()) void {
        for (self.bullets.items) |*bullet| {
            if (bullet.is_dead) continue;

            if (bullet.owner == .player) {
                for (self.enemies.items) |*enemy| {
                    if (enemy.is_dead) continue;

                    if (checkBoundsCollision(bullet.getBounds(), enemy.getCollisionBounds())) {
                        bullet.is_dead = true;
                        enemy.takeDamage(1);
                        if (enemy.is_dead) {
                            self.spawnExplosion(enemy.position, .enemy);
                            std.debug.print("Enemy hit!\n", .{});
                        }
                        break;
                    }
                }
            } else {
                if (checkBoundsCollision(bullet.getBounds(), self.player.getCollisionBounds())) {
                    bullet.is_dead = true;
                    self.spawnExplosion(self.player.position, .player);
                    std.debug.print("Player hit!\n", .{});
                }
            }
        }
    }

    fn allFormationEnemiesSettled(self: *const @This()) bool {
        for (self.enemies.items) |*enemy| {
            if (enemy.is_dead) continue;

            if (enemy.target_col != null and enemy.target_row != null) {
                switch (enemy.state) {
                    .entering, .entering_formation => return false,
                    else => {},
                }
            }
        }
        return true;
    }

    fn checkBoundsCollision(a: anytype, b: anytype) bool {
        return !(a.max_x < b.min_x or a.min_x > b.max_x or a.max_y < b.min_y or a.min_y > b.max_y);
    }

    fn handlePlayerMovement(self: *@This(), dt: f32, input: *Input) void {
        if (input.isKeyDown(.left)) {
            self.player.moveLeft(dt);
        }
        if (input.isKeyDown(.right)) {
            self.player.moveRight(dt);
        }
    }
    fn handleKeys(self: *@This(), input: *Input, ctx: MutableGameContext) void {
        if (input.isKeyPressed(.a)) {
            ctx.formation_grid.addShip();
        }
        if (input.isKeyPressed(.up)) {
            ctx.game_state.current_stage += 1;
            self.level_indicator.setStage(ctx.game_state.current_stage);
        }
    }

    pub fn draw(self: *const @This(), ctx: GameContext) void {
        self.drawPlayer(ctx);
        self.drawEnemies(ctx);
        self.drawBullets(ctx);
        self.drawExplosions(ctx);
        self.level_indicator.draw(ctx);
        self.life_indicator.draw(ctx);
    }

    fn drawPlayer(self: *const @This(), ctx: GameContext) void {
        const tex = ctx.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;
        const sprite = ctx.sprite_atlas.getSprite(.player);
        if (sprite.idle_count > 0) {
            const frame = sprite.idle_frames[0];
            const screen_pos = ctx.renderer.normToRender(self.player.position);
            ctx.renderer.drawSprite(tex, frame, screen_pos, Color.white);
        }
    }
    // Add this function!
    fn drawEnemies(self: *const @This(), ctx: GameContext) void {
        const tex = ctx.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;

        for (self.enemies.items) |*enemy| {
            const sprite = ctx.sprite_atlas.getSprite(enemy.enemy_type);
            if (sprite.idle_count > 0) {
                const frame = sprite.idle_frames[0];
                const screen_pos = ctx.renderer.normToRender(enemy.position);
                ctx.renderer.drawSprite(tex, frame, screen_pos, Color.white);
            }
        }
    }

    fn drawBullets(self: *const @This(), ctx: GameContext) void {
        const tex = ctx.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;

        for (self.bullets.items) |*bullet| {
            const sprite_type: SpriteType = switch (bullet.owner) {
                .player => .bullet_player,
                .enemy => .bullet_enemy,
            };

            const sprite = ctx.sprite_atlas.getSprite(sprite_type);
            if (sprite.idle_count > 0) {
                const frame = sprite.idle_frames[0];
                const screen_pos = ctx.renderer.normToRender(bullet.position);
                ctx.renderer.drawSprite(tex, frame, screen_pos, Color.white);
            }
        }
    }

    fn drawExplosions(self: *const @This(), ctx: GameContext) void {
        const tex = ctx.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;

        for (self.explosions.items) |*explosion| {
            const sprite = ctx.sprite_atlas.getSprite(explosion.getSpriteType());
            if (explosion.frame_index < sprite.idle_count) {
                const frame = sprite.idle_frames[explosion.frame_index];
                const screen_pos = ctx.renderer.normToRender(explosion.position);
                ctx.renderer.drawSprite(tex, frame, screen_pos, Color.white);
            }
        }
    }

    pub fn drawDebug(self: *const @This(), ctx: anytype) void {
        _ = self;
        ctx.renderer.drawText("Playing Mode", .{ .x = 10, .y = 10 }, 24, Color.white, null);
        var buf: [32]u8 = undefined;
        const ships = std.fmt.bufPrintZ(&buf, "Ships: {d}/{d}", .{ ctx.formation_grid.ships_in_formation, ctx.formation_grid.total_ships }) catch "0";
        ctx.renderer.drawText(ships, .{ .x = 10, .y = 40 }, 18, Color.yellow, null);
    }
};
