const std = @import("std");
const engine = @import("arcade_engine");

const AppState = @import("app_state.zig").AppState;
const EditorMode = @import("app_state.zig").EditorMode;
const PathListUI = @import("../ui/path_list.zig").PathListUI;
const SaveDialog = @import("../ui/save_dialog.zig").SaveDialog;
const PathRegistry = engine.level.PathRegistry;
const Input = engine.types.Input;

pub const InputHandler = struct {
    pub fn handleGlobalInput(
        app_state: *AppState,
        input: Input,
        path_list: *PathListUI,
        save_dialog: *SaveDialog,
        registry: *PathRegistry,
        path_names: [][]const u8,
    ) !void {
        // Handle save dialog input first
        if (save_dialog.visible) {
            if (save_dialog.handleInput(input)) |path_name| {
                const path_def = app_state.path_editor.toPathDefinition();
                try registry.savePath(path_name, path_def);
                save_dialog.hide();
                app_state.returnToViewing();
            }
            return; // Don't process other input when dialog is open
        }

        // Handle mode-specific input
        switch (app_state.mode) {
            .viewing => {
                try handleViewingInput(app_state, input, path_list, registry, path_names);
            },
            .editing, .creating_new => {
                try handleEditingInput(app_state, input, save_dialog);
            },
        }
    }

    fn handleViewingInput(
        app_state: *AppState,
        input: Input,
        path_list: *PathListUI,
        registry: *PathRegistry,
        path_names: [][]const u8,
    ) !void {
        // Enter - edit selected path
        if (input.isKeyPressed(.enter)) {
            if (path_list.selected_index) |idx| {
                if (idx < path_names.len) {
                    if (registry.getPath(path_names[idx])) |path| {
                        try app_state.startEditing(path_names[idx], path);
                    }
                }
            }
        }

        // N - create new path
        if (input.isKeyPressed(.n)) {
            app_state.startCreatingNew();
        }

        // Delete - remove selected path
        if (input.isKeyPressed(.delete)) {
            if (path_list.selected_index) |idx| {
                if (idx < path_names.len) {
                    try registry.deletePath(path_names[idx]);
                    path_list.selected_index = null;
                }
            }
        }
    }

    fn handleEditingInput(
        app_state: *AppState,
        input: Input,
        save_dialog: *SaveDialog,
    ) !void {
        // S - show save dialog
        if (input.isKeyPressed(.s)) {
            save_dialog.show(app_state.getCurrentPathName());
        }

        // N - create new path (discard current)
        if (input.isKeyPressed(.n)) {
            app_state.startCreatingNew();
        }

        // Escape - cancel and return to viewing
        if (input.isKeyPressed(.escape)) {
            app_state.returnToViewing();
        }
    }
};
