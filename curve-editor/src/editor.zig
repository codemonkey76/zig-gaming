const std = @import("std");
const types = @import("renderer").types;
const InputManager = @import("renderer").InputManager;
const Vec2 = types.Vec2;
const Key = types.Key;
const MouseButton = types.MouseButton;
const Color = types.Color;
const Input = types.Input;
const Viewport = types.Viewport;
const Bezier = @import("renderer").Bezier;
const bezier_draw = @import("renderer").bezier_draw;

const MAX_POINTS = 100;
const POINT_RADIUS: f32 = 8.0;
const SELECTION_THRESHOLD: f32 = 0.03;

pub const Editor = struct {
    const DragPoint = struct { bezier: usize, point: usize };
    beziers: std.ArrayList(Bezier),
    active_bezier_index: ?usize,
    drag_point: ?DragPoint,
    allocator: std.mem.Allocator,

    pub fn init() @This() {
        const allocator = std.heap.page_allocator;
        var beziers = std.ArrayList(Bezier).empty;

        beziers.append(allocator, Bezier.init(allocator)) catch unreachable;

        return .{
            .beziers = beziers,
            .active_bezier_index = 0,
            .drag_point = null,
            .allocator = allocator,
        };
    }
    pub fn deinit(self: *@This()) void {
        for (self.beziers.items) |*bezier| {
            bezier.deinit();
        }

        self.beziers.deinit(self.allocator);
    }

    pub fn registerInput(input_manager: *InputManager) void {
        input_manager.registerKey(Key.e);
        input_manager.registerKey(Key.enter);
        input_manager.registerMouseButton(MouseButton.left);
        input_manager.registerMouseButton(MouseButton.right);
    }

    pub fn update(self: *@This(), dt: f32, input: Input, viewport: Viewport) void {
        _ = dt;

        if (input.isKeyPressed(Key.e)) {
            self.exportPoints();
        }

        if (input.isKeyPressed(Key.enter)) {
            self.createNewBezier();
        }

        const norm_mouse = viewport.toNormalized(input.mouse_pos);

        self.handleLeftMouseButton(input, norm_mouse);
        self.handleMouseDragging(input, norm_mouse);
        self.handleLeftMouseRelease(input);
        self.handleRightMouseButton(input, norm_mouse);
    }

    fn createNewBezier(self: *@This()) void {
        self.beziers.append(self.allocator, Bezier.init(self.allocator)) catch {
            std.debug.print("Failed to create new bezier\n", .{});
            return;
        };
        self.active_bezier_index = self.beziers.items.len - 1;
        self.drag_point = null;
    }

    pub fn drawOverlayHandles(self: *const @This(), r: anytype) void {
        const vp = r.viewport;

        for (self.beziers.items, 0..) |bezier, b_idx| {
            const is_active = if (self.active_bezier_index) |active| active == b_idx else false;

            for (bezier.points.items, 0..) |norm_point, p_idx| {
                const screen_pos = vp.toScreen(norm_point);
                const color = self.getPointColor(b_idx, p_idx, is_active);

                r.drawCircle(screen_pos, POINT_RADIUS, color);
                r.drawCircle(screen_pos, POINT_RADIUS - 2, Color.white);
            }
        }
    }
    fn handleLeftMouseButton(self: *@This(), input: Input, norm_mouse: Vec2) void {
        if (!input.isMouseButtonPressed(MouseButton.left)) return;

        if (self.getPointAtMouse(norm_mouse)) |hit| {
            self.drag_point = hit;
            self.active_bezier_index = hit.bezier;
        } else {
            self.addPointToActiveBezier(norm_mouse);
        }
    }
    fn addPointToActiveBezier(self: *@This(), norm_mouse: Vec2) void {
        if (self.active_bezier_index) |active_idx| {
            if (active_idx < self.beziers.items.len) {
                var bezier = &self.beziers.items[active_idx];
                if (bezier.pointCount() < MAX_POINTS) { // Use pointCount()
                    bezier.addPoint(norm_mouse) catch { // Use addPoint()
                        std.debug.print("Failed to add point\n", .{});
                    };
                }
            }
        }
    }

    fn handleMouseDragging(self: *@This(), input: Input, norm_mouse: Vec2) void {
        if (!input.isMouseButtonDown(MouseButton.left)) return;

        if (self.drag_point) |drag| {
            if (drag.bezier < self.beziers.items.len) {
                var bezier = &self.beziers.items[drag.bezier];
                if (drag.point < bezier.pointCount()) { // Use pointCount()
                    bezier.points.items[drag.point] = norm_mouse;
                }
            }
        }
    }

    fn removePoint(self: *@This(), hit: DragPoint) void {
        if (hit.bezier >= self.beziers.items.len) return;

        var bezier = &self.beziers.items[hit.bezier];
        bezier.removePoint(hit.point); // Use removePoint()

        if (bezier.isEmpty()) { // Use isEmpty()
            self.removeEmptyBezier(hit.bezier);
        } else {
            self.adjustDragPointAfterRemoval(hit);
        }
    }
    fn handleLeftMouseRelease(self: *@This(), input: Input) void {
        if (input.isMouseButtonReleased(MouseButton.left)) {
            self.drag_point = null;
        }
    }

    fn handleRightMouseButton(self: *@This(), input: Input, norm_mouse: Vec2) void {
        if (!input.isMouseButtonPressed(MouseButton.right)) return;

        if (self.getPointAtMouse(norm_mouse)) |hit| {
            self.removePoint(hit);
        }
    }

    fn removeEmptyBezier(self: *@This(), bezier_idx: usize) void {
        var removed = self.beziers.orderedRemove(bezier_idx);
        removed.deinit();

        if (self.beziers.items.len == 0) {
            // No beziers left, create a new one
            self.beziers.append(self.allocator, Bezier.init(self.allocator)) catch {
                std.debug.print("Failed to create new bezier\n", .{});
            };
            self.active_bezier_index = 0;
        } else if (bezier_idx == 0) {
            // Removed first bezier, stay at index 0
            self.active_bezier_index = 0;
        } else {
            // Switch to previous bezier
            self.active_bezier_index = bezier_idx - 1;
        }

        self.drag_point = null;
    }

    fn adjustDragPointAfterRemoval(self: *@This(), hit: DragPoint) void {
        if (self.drag_point) |drag| {
            if (drag.bezier == hit.bezier and drag.point == hit.point) {
                self.drag_point = null;
            } else if (drag.bezier == hit.bezier and drag.point > hit.point) {
                self.drag_point = .{ .bezier = drag.bezier, .point = drag.point - 1 };
            }
        }
    }

    fn getPointAtMouse(self: *const @This(), norm_mouse: Vec2) ?DragPoint {
        var closest: ?DragPoint = null;
        var closest_dist_sq: f32 = SELECTION_THRESHOLD * SELECTION_THRESHOLD;

        for (self.beziers.items, 0..) |bezier, b_idx| {
            for (bezier.points.items, 0..) |point, p_idx| {
                const dx = norm_mouse.x - point.x;
                const dy = norm_mouse.y - point.y;
                const dist_sq = dx * dx + dy * dy;

                if (dist_sq < closest_dist_sq) {
                    closest_dist_sq = dist_sq;
                    closest = DragPoint{ .bezier = b_idx, .point = p_idx };
                }
            }
        }

        return closest;
    }

    pub fn draw(self: *const @This(), r: anytype) void {
        for (self.beziers.items, 0..) |*bezier, b_idx| {
            const is_active = if (self.active_bezier_index) |active| active == b_idx else false;

            if (bezier.pointCount() >= 2) {
                const curve_color = if (is_active) types.cyan else Color.gray;
                const polygon_color = if (is_active) Color.gray else Color.dark_gray;

                bezier_draw.drawBezierCurve(r, bezier, curve_color, 100);
                bezier_draw.drawControlPolygon(r, bezier.points.items, polygon_color);
            }

            for (bezier.points.items, 0..) |norm_point, p_idx| {
                const color = self.getPointColor(b_idx, p_idx, is_active);
                bezier_draw.drawControlPoint(r, norm_point, POINT_RADIUS, color, Color.white);
            }
        }
    }

    fn getPointColor(self: *const @This(), b_idx: usize, p_idx: usize, is_active: bool) Color {
        if (self.drag_point) |drag| {
            if (drag.bezier == b_idx and drag.point == p_idx) {
                return Color.yellow;
            }
        }
        return if (is_active) Color.red else types.dark_red;
    }

    pub fn drawUi(self: *const @This(), r: anytype) void {
        r.drawText(
            "Click: Add | Drag: Move | Right: Remove | E: Export | Enter: New Bezier",
            Vec2{ .x = 10, .y = 10 },
            16,
            Color.white,
            null,
        );

        if (self.active_bezier_index) |active_idx| {
            var buf: [256]u8 = undefined;
            const info_text = std.fmt.bufPrintZ(&buf, "Active Bezier: {} ({} points)", .{
                active_idx,
                self.beziers.items[active_idx].pointCount(),
            }) catch return;

            r.drawText(info_text, Vec2{ .x = 10, .y = 30 }, 16, Color.orange, null);
        }
    }

    pub fn exportPoints(self: *const @This()) void {
        std.debug.print("\n", .{});
        for (self.beziers.items, 0..) |bezier, b_idx| {
            std.debug.print("// Bezier {}: {} points\n", .{ b_idx, bezier.pointCount() });
            std.debug.print(".{{\n", .{});
            for (bezier.points.items, 0..) |point, i| {
                std.debug.print("    .{{ .x = {d:.4}, .y = {d:.4} }}", .{ point.x, point.y });
                if (i < bezier.pointCount() - 1) {
                    std.debug.print(",\n", .{});
                } else {
                    std.debug.print("\n", .{});
                }
            }
            std.debug.print("}}\n", .{});
        }
        std.debug.print("\n", .{});
    }
};
