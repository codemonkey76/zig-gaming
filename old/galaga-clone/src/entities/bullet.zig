const engine = @import("arcade_engine");
const Vec2 = engine.types.Vec2;
const SpriteType = @import("../graphics/sprite.zig").SpriteType;

pub const BulletOwner = enum {
    player,
    enemy,
};

pub const Bullet = struct {
    position: Vec2,
    velocity: Vec2,
    owner: BulletOwner,
    is_dead: bool = false,

    pub fn init(position: Vec2, owner: BulletOwner) Bullet {
        const velocity = switch (owner) {
            .player => Vec2{ .x = 0.0, .y = -0.8 },
            .enemy => Vec2{ .x = 0.0, .y = 0.5 },
        };

        return .{
            .position = position,
            .velocity = velocity,
            .owner = owner,
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.position.x += self.velocity.x * dt;
        self.position.y += self.velocity.y * dt;

        if (self.position.y < -0.1 or self.position.y > 1.1 or self.position.x < -0.1 or self.position.x > 1.1) {
            self.is_dead = true;
        }
    }

    pub fn getBounds(self: *const @This()) Bounds {
        const size = 0.01;

        return .{
            .min_x = self.position.x - size,
            .max_x = self.position.x + size,
            .min_y = self.position.y - size,
            .max_y = self.position.y + size,
        };
    }

    pub const Bounds = struct { min_x: f32, max_x: f32, min_y: f32, max_y: f32 };
};
