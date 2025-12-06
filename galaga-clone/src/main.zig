const std = @import("std");
const renderer = @import("renderer");
const Renderer = renderer.Renderer;
const RendererConfig = renderer.RendererConfig;
const Color = renderer.types.Color;
const Game = @import("game.zig").Game;

pub fn main() void {
    const allocator = std.heap.page_allocator;
    var r = Renderer.init(allocator, .{
        .title = "Galaga Clone",
        .margin_percent = 0.0,
        .letterbox_color = Color.dark_gray,
        .show_viewport_border = false,
        .show_fps = false,
    });
    defer r.deinit();

    var game = Game.init(allocator, &r);
    defer game.deinit();

    while (!r.shouldQuit()) {
        const dt = r.getDelta();
        const input = r.getInput();

        game.update(dt, input);
        r.handleGlobalInput(input);

        {
            r.begin();
            defer r.end();

            game.draw();
        }
    }
}
