const std = @import("std");
const Vec2 = @import("vec2.zig").Vec2;
const AnchorPoint = @import("anchor_point.zig").AnchorPoint;
const PathDefinition = @import("path_definition.zig").PathDefinition;
const PathIO = @import("path_io.zig").PathIO;

pub const PathRegistry = struct {
    allocator: std.mem.Allocator,
    paths: std.StringHashMap(PathEntry),

    const Self = @This();

    const PathEntry = struct {
        anchors: []AnchorPoint,

        pub fn deinit(self: *PathEntry, allocator: std.mem.Allocator) void {
            allocator.free(self.anchors);
        }
    };

    pub fn init(allocator: std.mem.Allocator) PathRegistry {
        return .{
            .allocator = allocator,
            .paths = std.StringHashMap(PathEntry).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        var it = self.paths.iterator();
        while (it.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            entry.value_ptr.deinit(self.allocator);
        }
        self.paths.deinit();
    }

    fn stripNul(s: []const u8) []const u8 {
        if (std.mem.indexOfScalar(u8, s, 0)) |i| return s[0..i];
        return s;
    }

    fn validName(s: []const u8) bool {
        if (s.len == 0) return false;
        if (std.mem.indexOfScalar(u8, s, 0) != null) return false;
        return true;
    }

    fn stemFromEntryName(entry_name: []const u8) []const u8 {
        const ext = ".gpath";
        return entry_name[0 .. entry_name.len - ext.len];
    }

    pub fn loadFromDirectory(self: *Self, dir_path: []const u8) !void {
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

            const loaded = PathIO.loadPath(self.allocator, full_path) catch |err| {
                std.debug.print("Failed to load path {s}: {}\n", .{ entry.name, err });
                continue;
            };
            errdefer {
                self.allocator.free(loaded.name);
                self.allocator.free(loaded.anchors);
            }

            const key = stemFromEntryName(entry.name);
            const key_copy = try self.allocator.dupe(u8, key);
            errdefer self.allocator.free(key_copy);

            // optionally warn if embedded name differs / is bad
            if (!validName(loaded.name) or !std.mem.eql(u8, loaded.name, key)) {
                std.debug.print(
                    "Warning: {s} has embedded name '{s}' (len={}), using filename stem '{s}'\n",
                    .{ entry.name, loaded.name, loaded.name.len, key },
                );
            }

            try self.paths.put(key_copy, PathEntry{
                .anchors = loaded.anchors,
            });

            self.allocator.free(loaded.name);

            std.debug.print("Loaded path: {s}\n", .{entry.name});
            std.debug.print("Struct: {}\n", .{entry});
        }
    }

    pub fn savePath(self: *Self, name: []const u8, anchors: []const AnchorPoint) !void {
        std.fs.cwd().makePath("assets/paths") catch {};

        var filename_buf: [256]u8 = undefined;
        const filename = try std.fmt.bufPrint(&filename_buf, "assets/paths/{s}.gpath", .{name});

        try PathIO.savePath(anchors, name, filename);

        const name_copy = try self.allocator.dupe(u8, name);
        errdefer self.allocator.free(name_copy);

        const anchors_copy = try self.allocator.dupe(AnchorPoint, anchors);
        errdefer self.allocator.free(anchors_copy);

        if (self.paths.fetchRemove(name)) |kv| {
            self.allocator.free(kv.key);
            var value_copy = kv.value;
            value_copy.deinit(self.allocator);
        }

        try self.paths.put(name_copy, PathEntry{
            .anchors = anchors_copy,
        });

        std.debug.print("Saved path: {s}\n", .{name_copy});
    }

    pub fn getPath(self: *const Self, name: []const u8) ?[]const AnchorPoint {
        const entry = self.paths.get(name) orelse return null;
        return entry.anchors;
    }

    pub fn listPaths(self: *const Self, allocator: std.mem.Allocator) ![][]const u8 {
        const names = try allocator.alloc([]const u8, self.paths.count());

        var it = self.paths.keyIterator();
        var i: usize = 0;
        while (it.next()) |key| {
            names[i] = stripNul(key.*);
            i += 1;
        }

        return names;
    }

    pub fn deletePath(self: *Self, name_in: []const u8) !void {
        const name = stripNul(name_in);
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

    pub fn renamePath(self: *Self, old_name: []const u8, new_name: []const u8) !void {
        const entry = self.paths.get(old_name) orelse return error.PathNotFound;
        try self.savePath(new_name, entry.path);
        try self.deletePath(old_name);
    }
};
