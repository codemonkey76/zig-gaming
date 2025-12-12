const Bezier = @import("../math/bezier.zig").Bezier;
const types = @import("../types.zig");
const Vec2 = types.Vec2;
const Color = types.Color;
const Renderer = @import("../core/renderer.zig").Renderer;

/// Draw a bezier curve with the given number of line segments
pub fn drawBezierCurve(
    renderer: *const Renderer,
    bezier: *const Bezier,
    color: Color,
    num_segments: usize,
) void {
    if (bezier.pointCount() < 2) return;

    var i: usize = 0;
    while (i < num_segments) : (i += 1) {
        const t1: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(num_segments));
        const t2: f32 = @as(f32, @floatFromInt(i + 1)) / @as(f32, @floatFromInt(num_segments));

        const norm_p1 = bezier.evaluate(t1);
        const norm_p2 = bezier.evaluate(t2);

        const p1 = renderer.normToRender(norm_p1);
        const p2 = renderer.normToRender(norm_p2);

        Renderer.drawLine(p1, p2, color);
    }
}

/// Draw the control polygon (lines connecting control points)
pub fn drawControlPolygon(
    renderer: *const Renderer,
    points: []const Vec2,
    color: Color,
) void {
    if (points.len < 2) return;

    for (0..points.len - 1) |j| {
        const p1 = renderer.normToRender(points[j]);
        const p2 = renderer.normToRender(points[j + 1]);
        Renderer.drawLine(p1, p2, color);
    }
}

/// Draw a control point with border
pub fn drawControlPoint(
    renderer: *const Renderer,
    norm_point: Vec2,
    radius: f32,
    color: Color,
    border_color: Color,
) void {
    const screen_point = renderer.normToRender(norm_point);
    Renderer.drawCircle(screen_point, radius, color);
    Renderer.drawCircle(screen_point, radius - 2, border_color);
}
