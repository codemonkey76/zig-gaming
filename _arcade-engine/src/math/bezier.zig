const std = @import("std");
const Vec2 = @import("../types.zig").Vec2;

pub const Bezier = struct {
    points: std.ArrayList(Vec2),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .points = std.ArrayList(Vec2).empty,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.points.deinit(self.allocator);
    }

    pub fn addPoint(self: *@This(), point: Vec2) !void {
        try self.points.append(self.allocator, point);
    }

    pub fn removePoint(self: *@This(), index: usize) void {
        _ = self.points.orderedRemove(index);
    }

    pub fn isEmpty(self: *const @This()) bool {
        return self.points.items.len == 0;
    }

    pub fn pointCount(self: *const @This()) usize {
        return self.points.items.len;
    }

    /// Evaluate bezier curve at parameter t (0.0 to 1.0) using De Casteljau's algorithm
    pub fn evaluate(self: *const @This(), t: f32) Vec2 {
        const n = self.points.items.len;

        if (n == 0) return Vec2{ .x = 0, .y = 0 };
        if (n == 1) return self.points.items[0];

        var temp = std.ArrayList(Vec2).empty;
        defer temp.deinit(self.allocator);

        temp.appendSlice(self.allocator, self.points.items) catch return self.points.items[0];

        var current_n = n;
        while (current_n > 1) {
            var j: usize = 0;
            while (j < current_n - 1) : (j += 1) {
                temp.items[j] = Vec2{
                    .x = (1.0 - t) * temp.items[j].x + t * temp.items[j + 1].x,
                    .y = (1.0 - t) * temp.items[j].y + t * temp.items[j + 1].y,
                };
            }
            current_n -= 1;
        }

        return temp.items[0];
    }

    // Create a bezier from a slice of points
    pub fn fromPoints(allocator: std.mem.Allocator, points: []const Vec2) !@This() {
        var bezier = init(allocator);
        try bezier.points.appendSlice(allocator, points);
        return bezier;
    }

    /// Get the total length of the curve (approximate)
    pub fn length(self: *const @This(), segments: usize) f32 {
        if (self.pointCount() < 2) return 0;

        var total: f32 = 0;
        var i: usize = 0;
        while (i < segments) : (i += 1) {
            const t1 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(segments));
            const t2 = @as(f32, @floatFromInt(i + 1)) / @as(f32, @floatFromInt(segments));

            const p1 = self.evaluate(t1);
            const p2 = self.evaluate(t2);

            const dx = p2.x - p1.x;
            const dy = p2.y - p1.y;
            total += @sqrt(dx * dx + dy * dy);
        }

        return total;
    }
};

test "bezier evaluation" {
    const allocator = std.testing.allocator;

    var bezier = Bezier.init(allocator);
    defer bezier.deinit();

    try bezier.addPoint(.{ .x = 0, .y = 0 });
    try bezier.addPoint(.{ .x = 1, .y = 1 });

    const mid = bezier.evaluate(0.5);
    try std.testing.expectEqual(0.5, mid.x);
    try std.testing.expectEqual(0.5, mid.y);
}
