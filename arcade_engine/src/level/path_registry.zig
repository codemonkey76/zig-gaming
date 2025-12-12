const std = @import("std");
const Vec2 = @import("../types.zig").Vec2;
const PathDefinition = @import("path_definition.zig").PathDefinition;
const path_io = @import("path_io.zig");

pub const PathRegistry = struct {
    allocator: std.mem.Allocator,
    paths: std.StringHashMap(PathEntry),

    const PathEntry = struct {
        path: PathDefinition,
        control_points_owned: []Vec2,

        pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
            allocator.free(self.control_points_owned);
        }
    };

    pub fn init(allocator: std.mem.Allocator) PathRegistry {
        return .{
            .allocator = allocator,
            .paths = std.StringHashMap(PathEntry).init(allocator),
        };
    }

    pub fn deinit(self: *@This()) void {
        var it = self.paths.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit(self.allocator);
        }
        self.paths.deinit();
    }

    pub fn loadFromDirectory(self: *@This(), dir_path: []const u8) !void {
        var dir = std.fs.cwd().openDir(dir_path, .{ .iterate = true }) catch |err| {
            if (err == error.FileNotFound) {
                std.debug.print("Path directory not found: {s}\n", .{dir_path});
                return;
            }
            return err;
        };
        defer dir.close();

        var it = dir.iterate();
        while (try it.next()) |entry| {
            if (entry.kind != .file) continue;
            if (!std.mem.endsWith(u8, entry.name, ".gpath")) continue;

            var path_buf: [256]u8 = undefined;
            const full_path = try std.fmt.bufPrint(&path_buf, "{s}/{s}", .{ dir_path, entry.name });

            const loaded = path_io.PathIO.loadPath(self.allocator, full_path) catch |err| {
                std.debug.print("Failed to load path {s}: {}\n", .{ entry.name, err });
                continue;
            };

            const name_copy = try self.allocator.dupe(u8, loaded.name);
            errdefer self.allocator.free(name_copy);

            try self.paths.put(name_copy, PathEntry{
                .path = loaded.path,
                .control_points_owned = loaded.control_points_owned,
            });

            self.allocator.free(loaded.name);

            std.debug.print("Loaded path: {s}\n", .{name_copy});
        }
    }

    pub fn savePath(self: *@This(), name: []const u8, path: PathDefinition) !void {
        std.fs.cwd().makePath("assets/paths") catch {};

        var filename_buf: [256]u8 = undefined;
        const filename = try std.fmt.bufPrint(&filename_buf, "assets/paths/{s}.gpath", .{name});

        try path_io.PathIO.savePath(path, name, filename);

        const name_copy = try self.allocator.dupe(u8, name);
        errdefer self.allocator.free(name_copy);

        const points_copy = try self.allocator.dupe(Vec2, path.control_points);
        errdefer self.allocator.free(points_copy);

        const path_copy = PathDefinition{
            .control_points = points_copy,
        };

        if (self.paths.fetchRemove(name)) |kv| {
            self.allocator.free(kv.key);
            var value_copy = kv.value;
            value_copy.deinit(self.allocator);
        }

        try self.paths.put(name_copy, PathEntry{
            .path = path_copy,
            .control_points_owned = points_copy,
        });

        std.debug.print("Saved path: {s}\n", .{name_copy});
    }

    pub fn getPath(self: *const @This(), name: []const u8) ?PathDefinition {
        const entry = self.paths.get(name) orelse return null;
        return entry.path;
    }

    pub fn listPaths(self: *const @This(), allocator: std.mem.Allocator) ![][]const u8 {
        const names = try allocator.alloc([]const u8, self.paths.count());

        var it = self.paths.keyIterator();
        var i: usize = 0;
        while (it.next()) |key| {
            names[i] = key.*;
            i += 1;
        }

        return names;
    }

    pub fn deletePath(self: *@This(), name: []const u8) !void {
        var filename_buf: [256]u8 = undefined;
        const filename = try std.fmt.bufPrint(&filename_buf, "assets/paths/{s}.gpath", .{name});
        try std.fs.cwd().deleteFile(filename);

        if (self.paths.fetchRemove(name)) |kv| {
            self.allocator.free(kv.key);
            var kv_value = kv.value;
            kv_value.deinit(self.allocator);
        }

        std.debug.print("Deleted path: {s}\n", .{name});
    }

    pub fn renamePath(self: *@This(), old_name: []const u8, new_name: []const u8) !void {
        const entry = self.paths.get(old_name) orelse return error.PathNotFound;
        try self.savePath(new_name, entry.path);
        try self.deletePath(old_name);
    }
};
