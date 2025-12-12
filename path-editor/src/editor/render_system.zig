const std = @import("std");
const engine = @import("arcade_engine");

const AppState = @import("app_state.zig").AppState;
const EditorMode = @import("app_state.zig").EditorMode;
const PathViewer = @import("path_viewer.zig").PathViewer;
const PathListUI = @import("../ui/path_list.zig").PathListUI;
const SaveDialog = @import("../ui/save_dialog.zig").SaveDialog;
const PathRegistry = engine.level.PathRegistry;
const Renderer = engine.core.Renderer;
const Font = engine.types.Font;
const Color = engine.types.Color;

pub const RenderSystem = struct {
    pub fn render(
        allocator: std.mem.Allocator,
        app_state: *const AppState,
        renderer: *const Renderer,
        path_list: *const PathListUI,
        save_dialog: *const SaveDialog,
        registry: *const PathRegistry,
        path_names: [][]const u8,
        font: Font,
    ) !void {
        // Draw path based on mode
        switch (app_state.mode) {
            .editing, .creating_new => {
                app_state.path_editor.draw(renderer);
                drawEditingInstructions(renderer, font);
            },
            .viewing => {
                if (path_list.selected_index) |idx| {
                    if (idx < path_names.len) {
                        if (registry.getPath(path_names[idx])) |path| {
                            try PathViewer.draw(renderer, allocator, path);
                        }
                    }
                }
                drawViewingInstructions(renderer, font);
            },
        }

        // Draw save dialog
        save_dialog.draw(renderer, font);

        // Draw path list UI (in letterbox area)
        path_list.draw(path_names, font);
    }

    fn drawEditingInstructions(renderer: *const Renderer, font: Font) void {
        const inst_pos = renderer.normToRender(.{ .x = 0.27, .y = 0.02 });
        var inst_buf: [256:0]u8 = undefined;
        const inst = std.fmt.bufPrintZ(&inst_buf, "LEFT CLICK: Add/Move Point | RIGHT CLICK: Delete Point", .{}) catch "???";
        Renderer.drawText(inst, inst_pos, 10, Color.white, font);

        const inst2_pos = renderer.normToRender(.{ .x = 0.27, .y = 0.05 });
        const inst2 = std.fmt.bufPrintZ(&inst_buf, "S: Save | ESC: Cancel | N: New Path", .{}) catch "???";
        Renderer.drawText(inst2, inst2_pos, 10, Color.white, font);
    }

    fn drawViewingInstructions(renderer: *const Renderer, font: Font) void {
        const inst_pos = renderer.normToRender(.{ .x = 0.27, .y = 0.02 });
        var inst_buf: [256:0]u8 = undefined;
        const inst = std.fmt.bufPrintZ(&inst_buf, "ENTER: Edit Selected | N: New Path | DELETE: Remove Selected", .{}) catch "???";
        Renderer.drawText(inst, inst_pos, 10, Color.white, font);
    }
};
