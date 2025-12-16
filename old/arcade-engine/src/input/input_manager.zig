const std = @import("std");
const rl = @import("raylib");

const types = @import("../types.zig");

const MouseButton = types.MouseButton;
const Key = rl.KeyboardKey;
const Input = types.Input;

pub const InputManager = struct {
    registered_keys: std.AutoHashMap(Key, void),
    registered_mouse_buttons: std.EnumSet(MouseButton),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) InputManager {
        return .{
            .registered_keys = std.AutoHashMap(Key, void).init(allocator),
            .registered_mouse_buttons = std.EnumSet(MouseButton).initEmpty(),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *InputManager) void {
        self.registered_keys.deinit();
    }

    pub fn registerKey(self: *InputManager, key: Key) void {
        self.registered_keys.put(key, {}) catch {};
    }

    pub fn unregisterKey(self: *InputManager, key: Key) void {
        _ = self.registered_keys.remove(key);
    }

    pub fn registerMouseButton(self: *InputManager, button: MouseButton) void {
        self.registered_mouse_buttons.insert(button);
    }

    pub fn unregisterMouseButton(self: *InputManager, button: MouseButton) void {
        _ = self.registered_mouse_buttons.remove(button);
    }

    pub fn poll(self: *const @This()) Input {
        var mouse_buttons_pressed = std.EnumSet(MouseButton).initEmpty();
        var mouse_buttons_down = std.EnumSet(MouseButton).initEmpty();
        var mouse_buttons_released = std.EnumSet(MouseButton).initEmpty();
        var keys_pressed = [_]bool{false} ** 512;
        var keys_down = [_]bool{false} ** 512;

        var it = self.registered_mouse_buttons.iterator();

        while (it.next()) |button| {
            const rl_button = mouseButtonToRayLib(button);

            if (rl.isMouseButtonPressed(rl_button)) {
                mouse_buttons_pressed.insert(button);
            }

            if (rl.isMouseButtonDown(rl_button)) {
                mouse_buttons_down.insert(button);
            }

            if (rl.isMouseButtonReleased(rl_button)) {
                mouse_buttons_released.insert(button);
            }
        }

        var key_it = self.registered_keys.keyIterator();
        while (key_it.next()) |key| {
            const index: usize = @intCast(@intFromEnum(key.*));
            if (index < 512) {
                if (rl.isKeyPressed(key.*)) {
                    keys_pressed[index] = true;
                }
                if (rl.isKeyDown(key.*)) { // ← Check this OUTSIDE the isKeyPressed block
                    keys_down[index] = true;
                }
            }
        }

        return Input{
            .mouse_pos = rl.getMousePosition(),
            .mouse_buttons_pressed = mouse_buttons_pressed,
            .mouse_buttons_down = mouse_buttons_down,
            .mouse_buttons_released = mouse_buttons_released,
            .keys_pressed = keys_pressed,
            .keys_down = keys_down,
        };
    }

    fn mouseButtonToRayLib(button: MouseButton) rl.MouseButton {
        return switch (button) {
            .left => rl.MouseButton.left,
            .right => rl.MouseButton.right,
            .middle => rl.MouseButton.middle,
        };
    }
};
