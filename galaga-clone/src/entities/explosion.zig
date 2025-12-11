const engine = @import("arcade_engine");
const Vec2 = engine.types.Vec2;
const SpriteType = @import("../graphics/sprite.zig").SpriteType;

pub const ExplosionType = enum {
    player,
    enemy,
};

pub const Explosion = struct {
    position: Vec2,
    explosion_type: ExplosionType,
    frame_index: usize = 0,
    frame_timer: f32 = 0.0,
    frame_duration: f32 = 0.05,
    is_dead: bool = false,

    pub fn init(position: Vec2, explosion_type: ExplosionType) Explosion {
        return .{
            .position = position,
            .explosion_type = explosion_type,
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        self.frame_timer += dt;

        if (self.frame_timer >= self.frame_duration) {
            self.frame_timer = 0.0;
            self.frame_index += 1;

            const max_frames: usize = switch (self.explosion_type) {
                .player => 4,
                .enemy => 5,
            };

            if (self.frame_index >= max_frames) {
                self.is_dead = true;
            }
        }
    }

    pub fn getSpriteType(self: *const @This()) SpriteType {
        return switch (self.explosion_type) {
            .player => .explosion_player,
            .enemy => .explosion_enemy,
        };
    }
};
