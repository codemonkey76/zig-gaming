const std = @import("std");
const engine = @import("arcade_engine");
const Window = engine.core.Window;
const WindowConfig = engine.core.WindowConfig;
const Renderer = engine.core.Renderer;
const InputManager = engine.input.InputManager;
const Color = engine.types.Color;
const Game = @import("game.zig").Game;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    var window = try Window.init(.{
        .width = 1280,
        .height = 720,
        .title = "Galaga Clone",
        .game_width = 224,
        .game_height = 288,
        .margin_percent = 0.0,
        .ssaa_scale = 2.0,
        .letterbox_color = Color.dark_gray,
        .show_viewport_border = false,
        .show_fps = false,
    });
    defer window.deinit();

    const renderer = Renderer.init(
        window.render_width,
        window.render_height,
        window.config.ssaa_scale,
    );

    var input_manager = InputManager.init(allocator);
    defer input_manager.deinit();

    var assets = engine.core.AssetManager.init(allocator);
    defer assets.deinit();

    var game = try Game.init(allocator, &window, &renderer, &input_manager, &assets);
    defer game.deinit();

    while (!window.shouldClose()) {
        const dt = window.getDelta();
        var input = input_manager.poll();

        game.update(dt, &input);

        window.beginFrame();
        game.draw();
        window.endFrame();
    }
}
