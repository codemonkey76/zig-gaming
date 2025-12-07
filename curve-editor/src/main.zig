const std = @import("std");
const Editor = @import("editor.zig").Editor;
const Renderer = @import("renderer").Renderer;

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    var r = try Renderer.init(allocator, .{
        .title = "Bezier Curve Editor",
    });
    defer r.deinit();

    r.registerInput(Editor.registerInput);

    var editor = Editor.init();
    defer {
        editor.exportPoints();
        editor.deinit();
    }

    while (!r.shouldQuit()) {
        const dt = r.getDelta();
        const input = r.getInput();
        r.handleGlobalInput(input);

        editor.update(dt, input, r.viewport);

        {
            r.begin();
            defer r.end();

            editor.draw(&r);

            r.endRenderTarget();
            editor.drawUi(&r);
        }
    }
}
