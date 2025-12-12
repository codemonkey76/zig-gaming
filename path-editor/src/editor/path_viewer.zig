const std = @import("std");
const engine = @import("arcade_engine");

const Bezier = engine.math.Bezier;
const PathDefinition = engine.level.PathDefinition;
const Renderer = engine.core.Renderer;
const Vec2 = engine.types.Vec2;
const Color = engine.types.Color;

pub const PathViewer = struct {
    pub fn draw(
        renderer: *const Renderer,
        allocator: std.mem.Allocator,
        path: PathDefinition,
    ) !void {
        var bezier = try Bezier.fromPoints(allocator, path.control_points);
        defer bezier.deinit();

        if (bezier.pointCount() < 2) return;

        // Draw curve
        engine.drawing.drawBezierCurve(renderer, &bezier, Color.green, 50);

        // Draw control polygon
        const gray = Color{ .r = 100, .g = 100, .b = 100, .a = 255 };
        engine.drawing.drawControlPolygon(renderer, bezier.points.items, gray);

        // Draw control points
        for (bezier.points.items) |point| {
            engine.drawing.drawControlPoint(renderer, point, 6, Color.blue, Color.white);
        }
    }
};
