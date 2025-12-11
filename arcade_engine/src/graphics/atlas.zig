const std = @import("std");
const Sprite = @import("sprite.zig").Sprite;

pub fn SpriteAtlas(comptime EnumType: type) type {
    return struct {
        sprites: std.EnumArray(EnumType, Sprite),

        pub fn init() @This() {
            return .{
                .sprites = std.EnumArray(EnumType, Sprite).initUndefined(),
            };
        }

        pub fn set(self: *@This(), sprite_type: EnumType, sprite: Sprite) void {
            self.sprites.set(sprite_type, sprite);
        }

        pub fn get(self: *const @This(), sprite_type: EnumType) Sprite {
            return self.sprites.get(sprite_type);
        }
    };
}
