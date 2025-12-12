const std = @import("std");
const engine = @import("arcade_engine");

const Bezier = engine.math.Bezier;
const PathDefinition = engine.level.PathDefinition;
const Renderer = engine.core.Renderer;
const Viewport = engine.core.Viewport;
const Vec2 = engine.types.Vec2;
const Color = engine.types.Color;
const Input = engine.types.Input;

pub const PathEditor = struct {
    allocator: std.mem.Allocator,
    bezier: Bezier,
    selected_point_index: ?usize = null,
    dragging: bool = false,

    pub fn init(allocator: std.mem.Allocator) PathEditor {
        return .{
            .allocator = allocator,
            .bezier = Bezier.init(allocator),
        };
    }

    pub fn deinit(self: *PathEditor) void {
        self.bezier.deinit();
    }

    pub fn clear(self: *PathEditor) void {
        self.bezier.deinit();
        self.bezier = Bezier.init(self.allocator);
        self.selected_point_index = null;
        self.dragging = false;
    }

    pub fn loadPath(self: *PathEditor, path: PathDefinition) !void {
        self.bezier.deinit();
        self.bezier = try Bezier.fromPoints(self.allocator, path.control_points);
        self.selected_point_index = null;
        self.dragging = false;
    }

    pub fn toPathDefinition(self: *const PathEditor) PathDefinition {
        return PathDefinition{
            .control_points = self.bezier.points.items,
        };
    }

    pub fn handleInput(
        self: *PathEditor,
        input: Input,
        viewport: Viewport,
        renderer: *const Renderer,
    ) !void {
        const mouse_in_viewport = viewport.contains(input.mouse_pos);
        if (!mouse_in_viewport) return;

        const norm_pos = viewport.toNormalized(input.mouse_pos);

        // Only handle input in editing area (right side, past x=0.26)
        if (norm_pos.x <= 0.26) return;

        // Left click - select or add point
        if (input.isMouseButtonPressed(.left)) {
            var clicked_point = false;

            // Check if clicking existing point
            for (self.bezier.points.items, 0..) |point, i| {
                if (self.isPointNear(point, norm_pos, renderer, 10)) {
                    self.selected_point_index = i;
                    self.dragging = true;
                    clicked_point = true;
                    break;
                }
            }

            // If not clicking point, add new point
            if (!clicked_point) {
                try self.bezier.addPoint(norm_pos);
                self.selected_point_index = self.bezier.pointCount() - 1;
            }
        }

        // Drag selected point
        if (input.isMouseButtonDown(.left) and self.dragging) {
            if (self.selected_point_index) |idx| {
                if (idx < self.bezier.points.items.len) {
                    self.bezier.points.items[idx] = norm_pos;
                }
            }
        }

        // Release drag
        if (input.isMouseButtonReleased(.left)) {
            self.dragging = false;
        }

        // Right click - delete point
        if (input.isMouseButtonPressed(.right)) {
            for (self.bezier.points.items, 0..) |point, i| {
                if (self.isPointNear(point, norm_pos, renderer, 10)) {
                    self.bezier.removePoint(i);
                    if (self.selected_point_index) |sel| {
                        if (sel == i) {
                            self.selected_point_index = null;
                        } else if (sel > i) {
                            self.selected_point_index = sel - 1;
                        }
                    }
                    break;
                }
            }
        }
    }

    fn isPointNear(
        self: *const PathEditor,
        point: Vec2,
        test_point: Vec2,
        renderer: *const Renderer,
        threshold: f32,
    ) bool {
        _ = self;
        const render_point = renderer.normToRender(point);
        const render_test = renderer.normToRender(test_point);
        const dx = render_point.x - render_test.x;
        const dy = render_point.y - render_test.y;
        const dist = @sqrt(dx * dx + dy * dy);
        return dist < threshold;
    }

    pub fn draw(self: *const PathEditor, renderer: *const Renderer) void {
        if (self.bezier.pointCount() == 0) return;

        // Draw curve
        if (self.bezier.pointCount() >= 2) {
            engine.drawing.drawBezierCurve(renderer, &self.bezier, engine.types.cyan, 50);
        }

        // Draw control polygon
        if (self.bezier.pointCount() >= 2) {
            engine.drawing.drawControlPolygon(renderer, self.bezier.points.items, Color.yellow);
        }

        // Draw control points
        for (self.bezier.points.items, 0..) |point, i| {
            const is_selected = if (self.selected_point_index) |sel| sel == i else false;
            const color = if (is_selected) Color.red else Color.green;
            engine.drawing.drawControlPoint(renderer, point, 8, color, Color.white);
        }
    }
};
