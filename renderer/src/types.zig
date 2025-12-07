const rl = @import("raylib");
const std = @import("std");

pub const Vec2 = rl.Vector2;
pub const Color = rl.Color;
pub const Rect = rl.Rectangle;
pub const cyan = rl.Color{ .r = 0, .g = 255, .b = 255, .a = 255 };
pub const dark_red = rl.Color{ .r = 128, .g = 0, .b = 0, .a = 255 };
pub const Viewport = @import("viewport.zig").Viewport;

pub const Texture = rl.Texture2D;
pub const Sound = rl.Sound;
pub const Font = rl.Font;

pub const MouseButton = enum {
    left,
    right,
    middle,
};

pub const Key = rl.KeyboardKey;

pub const Input = struct {
    mouse_pos: Vec2,
    mouse_buttons_pressed: std.EnumSet(MouseButton),
    mouse_buttons_down: std.EnumSet(MouseButton),
    mouse_buttons_released: std.EnumSet(MouseButton),
    keys_pressed: [512]bool,

    pub fn isMouseButtonPressed(self: @This(), button: MouseButton) bool {
        return self.mouse_buttons_pressed.contains(button);
    }

    pub fn isMouseButtonDown(self: @This(), button: MouseButton) bool {
        return self.mouse_buttons_down.contains(button);
    }

    pub fn isMouseButtonReleased(self: Input, button: MouseButton) bool {
        return self.mouse_buttons_released.contains(button);
    }

    pub fn isKeyPressed(self: @This(), key: Key) bool {
        const index: usize = @intCast(@intFromEnum(key));
        return if (index < self.keys_pressed.len) self.keys_pressed[index] else false;
    }
};
