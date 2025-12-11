const PathDefinition = @import("path_definition.zig").PathDefinition;
const Vec2 = @import("renderer").types.Vec2;

/// Registry of all predefined patterns
pub const PatternRegistry = struct {
    /// Swoop from left side with arc
    pub const swoop_left: PathDefinition = .{
        .control_points = &[_]Vec2{
            // Segment 1: Enter from left with upward arc
            .{ .x = -0.1, .y = 0.5 }, // p0 - start off-screen left
            .{ .x = 0.1, .y = 0.3 }, // p1 - control point (curves up)
            .{ .x = 0.3, .y = 0.1 }, // p2 - control point (curves right)
            .{ .x = 0.5, .y = 0.15 }, // p3 - end of segment 1

            // Segment 2: Loop around (reuses previous p3 as p0)
            .{ .x = 0.7, .y = 0.2 }, // p1 - control point
            .{ .x = 0.8, .y = 0.4 }, // p2 - control point
            .{ .x = 0.7, .y = 0.5 }, // p3 - end of segment 2

            // Segment 3: Move to formation area
            .{ .x = 0.6, .y = 0.6 }, // p1 - control point
            .{ .x = 0.5, .y = 0.6 }, // p2 - control point
            .{ .x = 0.5, .y = 0.5 }, // p3 - end near formation
        },
        .total_duration = 3.0,
    };

    /// Swoop from right side with arc
    pub const swoop_right: PathDefinition = .{
        .control_points = &[_]Vec2{
            // Segment 1: Enter from right with upward arc
            .{ .x = 1.1, .y = 0.5 }, // p0 - start off-screen right
            .{ .x = 0.9, .y = 0.3 }, // p1 - control point (curves up)
            .{ .x = 0.7, .y = 0.1 }, // p2 - control point (curves left)
            .{ .x = 0.5, .y = 0.15 }, // p3 - end of segment 1

            // Segment 2: Loop around
            .{ .x = 0.3, .y = 0.2 }, // p1 - control point
            .{ .x = 0.2, .y = 0.4 }, // p2 - control point
            .{ .x = 0.3, .y = 0.5 }, // p3 - end of segment 2

            // Segment 3: Move to formation area
            .{ .x = 0.4, .y = 0.6 }, // p1 - control point
            .{ .x = 0.5, .y = 0.6 }, // p2 - control point
            .{ .x = 0.5, .y = 0.5 }, // p3 - end near formation
        },
        .total_duration = 3.0,
    };

    /// Figure-8 pattern
    pub const figure_eight: PathDefinition = .{
        .control_points = &[_]Vec2{
            // Start from top
            .{ .x = 0.5, .y = -0.1 }, // p0
            .{ .x = 0.3, .y = 0.1 }, // p1
            .{ .x = 0.3, .y = 0.3 }, // p2
            .{ .x = 0.5, .y = 0.4 }, // p3

            // Right loop
            .{ .x = 0.7, .y = 0.5 }, // p1
            .{ .x = 0.7, .y = 0.3 }, // p2
            .{ .x = 0.5, .y = 0.2 }, // p3

            // Left loop
            .{ .x = 0.3, .y = 0.1 }, // p1
            .{ .x = 0.4, .y = 0.3 }, // p2
            .{ .x = 0.5, .y = 0.35 }, // p3 - end position
        },
        .total_duration = 4.0,
    };

    /// Dive bomb - straight down then curve up
    pub const dive_bomb: PathDefinition = .{
        .control_points = &[_]Vec2{
            // Dive down
            .{ .x = 0.5, .y = -0.1 }, // p0 - start above screen
            .{ .x = 0.5, .y = 0.2 }, // p1
            .{ .x = 0.5, .y = 0.5 }, // p2
            .{ .x = 0.5, .y = 0.7 }, // p3 - bottom of dive

            // Pull up
            .{ .x = 0.5, .y = 0.6 }, // p1
            .{ .x = 0.5, .y = 0.5 }, // p2
            .{ .x = 0.5, .y = 0.4 }, // p3 - end position
        },
        .total_duration = 2.5,
    };

    /// Straight down (simple entry)
    pub const straight_down: PathDefinition = .{
        .control_points = &[_]Vec2{
            .{ .x = 0.5, .y = -0.1 }, // p0 - start above screen
            .{ .x = 0.5, .y = 0.1 }, // p1
            .{ .x = 0.5, .y = 0.3 }, // p2
            .{ .x = 0.5, .y = 0.5 }, // p3 - end position
        },
        .total_duration = 2.0,
    };
};

/// Pattern reference - enum that maps to actual path data
pub const PatternType = enum {
    swoop_left,
    swoop_right,
    figure_eight,
    dive_bomb,
    straight_down,

    /// Get the full path definition for this pattern
    pub fn getPath(self: @This()) PathDefinition {
        return switch (self) {
            .swoop_left => PatternRegistry.swoop_left,
            .swoop_right => PatternRegistry.swoop_right,
            .figure_eight => PatternRegistry.figure_eight,
            .dive_bomb => PatternRegistry.dive_bomb,
            .straight_down => PatternRegistry.straight_down,
        };
    }
};
