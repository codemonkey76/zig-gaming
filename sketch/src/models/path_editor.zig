const std = @import("std");
const arcade = @import("arcade_lib");

pub const PathEditor = struct {
    allocator: std.mem.Allocator,
    current_name: ?[]u8 = null,
    points: std.ArrayList(arcade.AnchorPoint),
    dirty: bool = false,

    pub fn init(allocator: std.mem.Allocator) PathEditor {
        return .{
            .allocator = allocator,
            .points = std.ArrayList(arcade.AnchorPoint).empty,
        };
    }

    pub fn deinit(self: *PathEditor) void {
        if (self.current_name) |n| self.allocator.free(n);
        self.points.deinit(self.allocator);
    }

    pub fn load(self: *PathEditor, name: []const u8, anchors: []const arcade.AnchorPoint) !void {
        if (self.current_name) |n| self.allocator.free(n);
        self.current_name = try self.allocator.dupe(u8, name);

        self.points.clearRetainingCapacity();
        try self.points.appendSlice(self.allocator, anchors);

        self.dirty = false;
    }

    pub fn markDirty(self: *PathEditor) void {
        self.dirty = true;
    }

    pub fn clear(self: *PathEditor) void {
        if (self.current_name) |n| self.allocator.free(n);
        self.current_name = null;
        self.points.clearRetainingCapacity();
        self.dirty = false;
    }

    pub fn definition(self: *PathEditor) []const arcade.AnchorPoint {
        return self.points.items;
    }

    fn controlPointsToAnchors(self: *PathEditor, control_points: []const arcade.Vec2) !void {
        if (control_points.len == 0) return;

        // For now, create simple anchors from control points
        // Each set of 4 control points becomes 2 anchors (sharing the middle point)

        if (control_points.len < 4) {
            // Just create simple anchors with no handles
            for (control_points) |pt| {
                try self.points.append(self.allocator, arcade.AnchorPoint{
                    .pos = pt,
                    .handle_in = null,
                    .handle_out = null,
                    .mode = .corner,
                });
            }
            return;
        }

        // First anchor
        try self.points.append(self.allocator, arcade.AnchorPoint{
            .pos = control_points[0],
            .handle_in = null,
            .handle_out = arcade.Vec2{
                .x = control_points[1].x - control_points[0].x,
                .y = control_points[1].y - control_points[0].y,
            },
            .mode = .smooth,
        });

        // Middle and end anchors
        const segment_count = (control_points.len - 1) / 3;
        var i: usize = 0;
        while (i < segment_count) : (i += 1) {
            const base = i * 3;
            const anchor_pos = control_points[base + 3];
            const handle_in = arcade.Vec2{
                .x = control_points[base + 2].x - anchor_pos.x,
                .y = control_points[base + 2].y - anchor_pos.y,
            };

            const handle_out = if (i + 1 < segment_count)
                arcade.Vec2{
                    .x = control_points[base + 4].x - anchor_pos.x,
                    .y = control_points[base + 4].y - anchor_pos.y,
                }
            else
                null;

            try self.points.append(self.allocator, arcade.AnchorPoint{
                .pos = anchor_pos,
                .handle_in = handle_in,
                .handle_out = handle_out,
                .mode = .smooth,
            });
        }
    }
};
