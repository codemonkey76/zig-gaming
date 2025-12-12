const std = @import("std");
const engine = @import("arcade_engine");
const Vec2 = engine.types.Vec2;
const PathRegistry = engine.level.PathRegistry;
const PathDefinition = engine.level.PathDefinition;

pub const Command = enum {
    create,
    list,
    delete,
    rename,
    info,
    help,
};

pub fn createPath(allocator: std.mem.Allocator, registry: *PathRegistry, args: [][:0]u8) !void {
    if (args.len < 2) {
        std.debug.print("Usage: path_gen create <name> [points...]\n", .{});
        std.debug.print("Example: path_gen create my_path 0.1,0.5 0.3,0.3 0.7,0.3 0.9,0.5\n", .{});
        return error.InvalidUsage;
    }

    const name = args[2];

    if (args.len < 4) {
        std.debug.print("Creating path: {s}\n", .{name});
        std.debug.print("\nEnter control points (format: x,y) - type 'done' when finished:\n", .{});
        var points = std.ArrayList(Vec2).empty;
        defer points.deinit(allocator);
        var read_buf: [100]u8 = undefined;
        var write_buf: [100]u8 = undefined;
        var stdin_reader = std.fs.File.stdin().reader(&read_buf);
        const stdin = &stdin_reader.interface;

        var point_num: usize = 0;
        while (true) {
            const msg = try std.fmt.bufPrintZ(&write_buf, "Point: {d}: ", .{point_num});
            _ = try std.fs.File.stdout().write(msg);
            const line = try stdin.takeDelimiter('\n') orelse break;
            const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);

            if (std.mem.eql(u8, trimmed, "done")) break;

            const point = parsePoint(trimmed) catch |err| {
                std.debug.print("Invalid point format: {} (expected x,y)\n", .{err});
                continue;
            };

            try points.append(allocator, point);
            std.debug.print("   Added: ({d:.3}, {d:.3})\n", .{ point.x, point.y });
            point_num += 1;
        }
    } else {
        var points = std.ArrayList(Vec2).empty;
        defer points.deinit(allocator);

        for (args[3..]) |arg| {
            const point = try parsePoint(arg);
            try points.append(allocator, point);
        }

        if (points.items.len < 4) {
            std.debug.print("Error: Need at least 4 control points\n", .{});
            return error.InsufficientPoints;
        }

        const path = PathDefinition{
            .control_points = points.items,
        };
        try registry.savePath(name, path);

        std.debug.print("Path '{s}' created with {d} points\n", .{
            name,
            points.items.len,
        });
    }
}

fn parsePoint(str: []const u8) !Vec2 {
    var iter = std.mem.splitScalar(u8, str, ',');

    const x_str = iter.next() orelse return error.InvalidFormat;
    const y_str = iter.next() orelse return error.InvalidFormat;

    if (iter.next() != null) return error.InvalidFormat;

    return Vec2{
        .x = try std.fmt.parseFloat(f32, x_str),
        .y = try std.fmt.parseFloat(f32, y_str),
    };
}

pub fn listPaths(registry: *PathRegistry) !void {
    const allocator = registry.allocator;
    const names = try registry.listPaths(allocator);
    defer allocator.free(names);

    if (names.len == 0) {
        std.debug.print("No paths found.\n", .{});
        return;
    }

    std.debug.print("Available paths:\n", .{});
    for (names) |name| {
        if (registry.getPath(name)) |path| {
            const segment_count = 1 + ((path.control_points.len - 4) / 3);
            std.debug.print("  • {s}\n", .{name});
            std.debug.print("      Points: {d}, Segments: {d}\n", .{
                path.control_points.len,
                segment_count,
            });
        }
    }
}

pub fn deletePath(registry: *PathRegistry, args: [][:0]u8) !void {
    if (args.len < 3) {
        std.debug.print("Usage: path_cli delete <name>\n", .{});
        return error.InvalidUsage;
    }

    const name = args[2];

    if (registry.getPath(name) == null) {
        std.debug.print("Path '{s}' not found.\n", .{name});
        return error.PathNotFound;
    }

    // // Confirm deletion
    // const stdout = std.io.getStdOut().writer();
    // const stdin = std.io.getStdIn().reader();
    //
    // try stdout.print("Delete path '{s}'? (y/n): ", .{name});
    //
    // var buf: [10]u8 = undefined;
    // const line = (try stdin.readUntilDelimiterOrEof(&buf, '\n')) orelse return;
    // const trimmed = std.mem.trim(u8, line, &std.ascii.whitespace);
    //
    // if (!std.mem.eql(u8, trimmed, "y") and !std.mem.eql(u8, trimmed, "Y")) {
    //     std.debug.print("Deletion cancelled.\n", .{});
    //     return;
    // }
    //
    // try registry.deletePath(name);
    // std.debug.print("Path '{s}' deleted successfully.\n", .{name});
}

pub fn renamePath(registry: *PathRegistry, args: [][:0]u8) !void {
    if (args.len < 4) {
        std.debug.print("Usage: path_cli rename <old_name> <new_name>\n", .{});
        return error.InvalidUsage;
    }

    const old_name = args[2];
    const new_name = args[3];

    if (registry.getPath(old_name) == null) {
        std.debug.print("Path '{s}' not found.\n", .{old_name});
        return error.PathNotFound;
    }

    if (registry.getPath(new_name) != null) {
        std.debug.print("Path '{s}' already exists.\n", .{new_name});
        return error.PathExists;
    }

    try registry.renamePath(old_name, new_name);
    std.debug.print("Path renamed from '{s}' to '{s}'\n", .{ old_name, new_name });
}

pub fn showPathInfo(registry: *PathRegistry, args: [][:0]u8) !void {
    if (args.len < 3) {
        std.debug.print("Usage: path_cli info <name>\n", .{});
        return error.InvalidUsage;
    }

    const name = args[2];
    const path = registry.getPath(name) orelse {
        std.debug.print("Path '{s}' not found.\n", .{name});
        return error.PathNotFound;
    };

    const segment_count = 1 + ((path.control_points.len - 4) / 3);

    std.debug.print("Path: {s}\n", .{name});
    std.debug.print("Control Points: {d}\n", .{path.control_points.len});
    std.debug.print("Segments: {d}\n\n", .{segment_count});

    std.debug.print("Control Points:\n", .{});

    for (path.control_points, 0..) |point, i| {
        std.debug.print("  [{d:2}] ({d:.3}, {d:.3})\n", .{ i, point.x, point.y });
    }

    std.debug.print("\nStart: ({d:.3}, {d:.3})\n", .{
        path.getStartPosition().x,
        path.getStartPosition().y,
    });

    std.debug.print("End:   ({d:.3}, {d:.3})\n", .{
        path.getEndPosition().x,
        path.getEndPosition().y,
    });

    std.debug.print("\nSample positions:\n", .{});

    var i: usize = 0;
    while (i <= 10) : (i += 1) {
        const t: f32 = @as(f32, @floatFromInt(i)) / 10.0;
        const pos = path.getPosition(t);
        std.debug.print("  t={d:.1}: ({d:.3}, {d:.3})\n", .{ t, pos.x, pos.y });
    }
}

pub fn printHelp() void {
    std.debug.print(
        \\Path CLI - Create and manage game paths
        \\
        \\Usage: path_gen <command> [options]
        \\
        \\Commands:
        \\  create <name> [points...]
        \\      Create a new path with control points
        \\      If points are not provided, enters interactive mode
        \\      Points format: x,y (normalized coordinates 0.0-1.0)
        \\      Example: path_cli create enemy_path 0.1,0.5 0.3,0.3 0.7,0.3 0.9,0.5
        \\
        \\  list
        \\      List all available paths
        \\
        \\  info <name>
        \\      Show detailed information about a path
        \\
        \\  delete <name>
        \\      Delete a path (with confirmation)
        \\
        \\  rename <old_name> <new_name>
        \\      Rename a path
        \\
        \\  help
        \\      Show this help message
        \\
        \\Path Format:
        \\  Paths are cubic bezier curves requiring at least 4 control points.
        \\  First segment: 4 points (p0, p1, p2, p3)
        \\  Each additional segment adds 3 points (p1, p2, p3)
        \\  Coordinates should be normalized (0.0 to 1.0)
        \\
        \\Examples:
        \\  path_gen create simple_path
        \\      (enters interactive mode)
        \\
        \\  path_gen create wave 0.0,0.5 0.3,0.2 0.7,0.8 1.0,0.5
        \\      (creates a wave pattern)
        \\
        \\  path_gen list
        \\      (shows all paths)
        \\
        \\  path_gen info wave
        \\      (shows details about the 'wave' path)
        \\
    , .{});
}
