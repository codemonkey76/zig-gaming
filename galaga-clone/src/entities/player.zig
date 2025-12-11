const Vec2 = @import("renderer").types.Vec2;
const SpriteType = @import("../graphics/sprite.zig").SpriteType;

pub const Player = struct {
    position: Vec2,
    speed: f32 = 0.3,
    bounds: Bounds = .{
        .min_x = 0.05,
        .max_x = 0.95,
    },
    shoot_cooldown: f32 = 0.0,
    shoot_delay: f32 = 0.02,

    pub const Bounds = struct {
        min_x: f32,
        max_x: f32,
    };

    pub fn init(start_x: f32, start_y: f32) Player {
        return .{
            .position = Vec2{ .x = start_x, .y = start_y },
        };
    }

    pub fn moveLeft(self: *@This(), dt: f32) void {
        self.position.x -= self.speed * dt;
        if (self.position.x < self.bounds.min_x) {
            self.position.x = self.bounds.min_x;
        }
    }

    pub fn moveRight(self: *@This(), dt: f32) void {
        self.position.x += self.speed * dt;
        if (self.position.x > self.bounds.max_x) {
            self.position.x = self.bounds.max_x;
        }
    }

    pub fn update(self: *@This(), dt: f32) void {
        if (self.shoot_cooldown > 0) {
            self.shoot_cooldown -= dt;
        }
    }

    pub fn canShoot(self: *const @This()) bool {
        return self.shoot_cooldown <= 0;
    }

    pub fn shoot(self: *@This()) void {
        self.shoot_cooldown = self.shoot_delay;
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
};
