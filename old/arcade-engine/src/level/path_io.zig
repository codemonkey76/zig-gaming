const std = @import("std");
const Vec2 = @import("../types.zig").Vec2;
const PathDefinition = @import("path_definition.zig").PathDefinition;
const path_format = @import("path_format.zig");

pub const PathIO = struct {
    pub fn savePath(path: PathDefinition, name: []const u8, filename: []const u8) !void {
        const file = try std.fs.cwd().createFile(filename, .{});
        defer file.close();

        var header = path_format.PathHeader{
            .magic = undefined,
            .version = path_format.VERSION,
            .name_length = @intCast(name.len),
            .point_count = @intCast(path.control_points.len),
            .reserved = 0,
        };
        header.setMagic();

        try file.writeAll(std.mem.asBytes(&header));
        try file.writeAll(name);

        for (path.control_points) |point| {
            const point_binary = path_format.PathPoint.fromVec2(point);
            try file.writeAll(std.mem.asBytes(&point_binary));
        }
    }

    pub const LoadedPath = struct {
        name: []u8,
        path: PathDefinition,
        control_points_owned: []Vec2,

        pub fn deinit(self: *@This(), allocator: std.mem.Allocator) void {
            allocator.free(self.name);
            allocator.free(self.control_points_owned);
        }
    };

    pub fn loadPath(allocator: std.mem.Allocator, filename: []const u8) !LoadedPath {
        const file = try std.fs.cwd().openFile(filename, .{});
        defer file.close();

        var header: path_format.PathHeader = undefined;
        const header_bytes = try file.readAll(std.mem.asBytes(&header));
        if (header_bytes != @sizeOf(path_format.PathHeader)) return error.InvalidFile;

        if (!header.checkMagic()) return error.InvalidMagic;
        if (header.version != path_format.VERSION) return error.UnsupportedVersion;

        const name = try allocator.alloc(u8, header.name_length);
        errdefer allocator.free(name);

        const name_bytes = try file.readAll(name);
        if (name_bytes != header.name_length) return error.InvalidName;

        const control_points = try allocator.alloc(Vec2, header.point_count);
        errdefer allocator.free(control_points);

        for (control_points) |*point| {
            var point_binary: path_format.PathPoint = undefined;
            const point_bytes = try file.readAll(std.mem.asBytes(&point_binary));
            if (point_bytes != @sizeOf(path_format.PathPoint)) return error.InvalidPoint;
            point.* = point_binary.getVec2();
        }

        return LoadedPath{
            .name = name,
            .path = PathDefinition{
                .control_points = control_points,
            },
            .control_points_owned = control_points,
        };
    }
};
