const Vec2 = @import("renderer").types.Vec2;
const BezierSegment = @import("bezier_segment.zig").BezierSegment;

pub const PathDefinition = struct {
    control_points: []const Vec2,
    total_duration: f32,

    pub fn getSegmentCount(self: @This()) usize {
        if (self.control_points.len < 4) return 0;

        return 1 + ((self.control_points.len - 4) / 3);
    }

    pub fn getSegment(self: @This(), index: usize) ?BezierSegment {
        const seg_count = self.getSegmentCount();
        if (index >= seg_count) return null;

        if (index == 0) {
            return BezierSegment{
                .p0 = self.control_points[0],
                .p1 = self.control_points[1],
                .p2 = self.control_points[2],
                .p3 = self.control_points[3],
            };
        } else {
            const offset = 4 + (index - 1) * 3;
            return BezierSegment{
                .p0 = self.control_points[offset - 1],
                .p1 = self.control_points[offset],
                .p2 = self.control_points[offset + 1],
                .p3 = self.control_points[offset + 2],
            };
        }
    }

    pub fn getPosition(self: @This(), t: f32) Vec2 {
        const seg_count = self.getSegmentCount();
        if (seg_count == 0) return Vec2{ .x = 0, .y = 0 };
        const clamped_t = if (t < 0.0) 0.0 else if (t > 1.0) 1.0 else t;
        const segment_count_f = @as(f32, @floatFromInt(seg_count));
        const segment_t = clamped_t * segment_count_f;
        const segment_index = @as(usize, @intFromFloat(@floor(segment_t)));
        const local_t = segment_t - @floor(segment_t);

        const index = if (segment_index >= seg_count) seg_count - 1 else segment_index;

        const segment = self.getSegment(index) orelse return Vec2{ .x = 0, .y = 0 };
        return segment.evaluate(local_t);
    }

    pub fn getStartPosition(self: @This()) Vec2 {
        if (self.control_points.len == 0) return Vec2{ .x = 0, .y = 0 };
        return self.control_points[0];
    }

    pub fn getEndPosition(self: @This()) Vec2 {
        if (self.control_points.len == 0) return Vec2{ .x = 0, .y = 0 };
        const seg_count = self.getSegmentCount();
        if (seg_count == 0) return self.control_points[0];
        if (seg_count == 1) {
            return self.control_points[3];
        } else {
            return self.control_points[self.control_points.len - 1];
        }
    }
};
