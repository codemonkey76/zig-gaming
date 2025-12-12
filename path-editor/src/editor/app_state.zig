const std = @import("std");
const engine = @import("arcade_engine");

const PathEditor = @import("path_editor.zig").PathEditor;
const PathRegistry = engine.level.PathRegistry;
const Input = engine.types.Input;

pub const EditorMode = enum {
    viewing,
    editing,
    creating_new,
};

pub const AppState = struct {
    allocator: std.mem.Allocator,
    mode: EditorMode,
    path_editor: PathEditor,
    current_path_name: [64]u8 = undefined,
    current_path_name_len: usize = 0,

    pub fn init(allocator: std.mem.Allocator) AppState {
        return .{
            .allocator = allocator,
            .mode = .viewing,
            .path_editor = PathEditor.init(allocator),
        };
    }

    pub fn deinit(self: *AppState) void {
        self.path_editor.deinit();
    }

    pub fn startEditing(self: *AppState, path_name: []const u8, path: engine.level.PathDefinition) !void {
        try self.path_editor.loadPath(path);
        self.mode = .editing;
        self.current_path_name_len = @min(path_name.len, self.current_path_name.len - 1);
        @memcpy(self.current_path_name[0..self.current_path_name_len], path_name[0..self.current_path_name_len]);
    }

    pub fn startCreatingNew(self: *AppState) void {
        self.path_editor.clear();
        self.mode = .creating_new;
        self.current_path_name_len = 0;
    }

    pub fn returnToViewing(self: *AppState) void {
        self.path_editor.clear();
        self.mode = .viewing;
        self.current_path_name_len = 0;
    }

    pub fn getCurrentPathName(self: *const AppState) []const u8 {
        return self.current_path_name[0..self.current_path_name_len];
    }

    pub fn isEditing(self: *const AppState) bool {
        return self.mode == .editing or self.mode == .creating_new;
    }
};
