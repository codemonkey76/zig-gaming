const rl = @import("raylib");
const std = @import("std");
const arcade = @import("arcade_lib");
const Vec2 = arcade.Vec2;
const ui_mod = @import("ui.zig");
const Ui = ui_mod.Ui;
const WidgetId = ui_mod.WidgetId;

pub const State = struct {
    hovered: bool = false,

    // dragging
    drag_index: ?usize = null,
    drag_off: arcade.Vec2 = .{ .x = 0, .y = 0 },

    drag_handle: ?DragHandle = null,

    selected_anchor: ?usize = null,
};

const DragHandle = struct {
    anchor_index: usize,
    is_out: bool,
    offset: arcade.Vec2,
};

pub const Params = struct {
    pad: f32 = 10.0,
    font_px: f32 = 18.0,

    viewport_w: f32 = 224,
    viewport_h: f32 = 288,
    viewport_margin: f32 = 40,

    point_radius: f32 = 7.0,
    hit_radius: f32 = 10.0,
};

pub const Result = struct {
    hovered: bool,
    vp: rl.Rectangle,
    changed: bool,
};

pub fn canvasEditor(
    allocator: std.mem.Allocator,
    ui: *Ui,
    state: *State,
    id: WidgetId,
    bounds: rl.Rectangle,
    font: rl.Font,
    anchors: *std.ArrayList(arcade.AnchorPoint),
    p: Params,
) !Result {
    const hovered = ui.hit(id, bounds);
    state.hovered = hovered;

    // background + border
    rl.drawRectangleRec(bounds, rl.Color.black);
    rl.drawRectangleLinesEx(bounds, 1, rl.Color.gray);

    const vp = fitAspectCenter(bounds, p.viewport_w, p.viewport_h, p.viewport_margin);
    rl.drawRectangleLinesEx(vp, 2, rl.Color.green);

    const control_points = try arcade.PathDefinition.fromAnchorPoints(allocator, anchors.items);
    defer allocator.free(control_points);

    drawCurve(vp, anchors.items, control_points, state.selected_anchor, p.point_radius);

    var changed = false;

    if (hovered) {
        const m = rl.getMousePosition();

        // check if we hit a handle first (if an anchor is selected)
        if (state.selected_anchor) |sel_idx| {
            if (sel_idx < anchors.items.len) {
                const hit_handle = hitHandle(vp, anchors.items[sel_idx], m, p.hit_radius);

                if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                    if (hit_handle) |is_out| {
                        // Start dragging handle
                        const mp = mouseToPath(vp, m);
                        const handle = if (is_out)
                            anchors.items[sel_idx].handle_out
                        else
                            anchors.items[sel_idx].handle_in;

                        state.drag_handle = DragHandle{
                            .anchor_index = sel_idx,
                            .is_out = is_out,
                            .offset = if (handle) |h|
                                Vec2{ .x = mp.x - (anchors.items[sel_idx].pos.x + h.x), .y = mp.y - (anchors.items[sel_idx].pos.y + h.y) }
                            else
                                Vec2{ .x = 0, .y = 0 },
                        };
                    }
                }
            }
        }

        if (state.drag_handle == null) {
            const hit = hitAnchor(vp, anchors.items, m, p.hit_radius);

            // Right click removes anchor
            if (rl.isMouseButtonPressed(rl.MouseButton.right)) {
                if (hit) |idx| {
                    _ = anchors.orderedRemove(idx);
                    state.drag_index = null;
                    state.selected_anchor = null;
                    changed = true;
                }
            }

            // Left click: select/drag anchor or add new
            if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
                if (hit) |idx| {
                    state.selected_anchor = idx;
                    state.drag_index = idx;

                    const mp = mouseToPath(vp, m);
                    const anchor = anchors.items[idx];
                    state.drag_off = .{ .x = mp.x - anchor.pos.x, .y = mp.y - anchor.pos.y };
                } else {
                    // Add new anchor point
                    const mp = mouseToPath(vp, m);
                    const new_idx = anchors.items.len;

                    try anchors.append(allocator, arcade.AnchorPoint{
                        .pos = mp,
                        .handle_in = null,
                        .handle_out = null,
                        .mode = .smooth,
                    });
                    state.selected_anchor = new_idx;

                    // Start dragging the outgoing handle immediately
                    state.drag_handle = DragHandle{
                        .anchor_index = new_idx,
                        .is_out = true,
                        .offset = arcade.Vec2{ .x = 0, .y = 0 },
                    };
                    changed = true;
                }
            }
        }
    }

    // Handle dragging
    if (state.drag_handle) |dh| {
        if (rl.isMouseButtonDown(rl.MouseButton.left)) {
            const m = rl.getMousePosition();
            const mp = mouseToPath(vp, m);

            const anchor_pos = anchors.items[dh.anchor_index].pos;
            const handle_pos = Vec2{
                .x = mp.x - dh.offset.x,
                .y = mp.y - dh.offset.y,
            };
            const handle_relative = Vec2{
                .x = handle_pos.x - anchor_pos.x,
                .y = handle_pos.y - anchor_pos.y,
            };

            if (dh.is_out) {
                anchors.items[dh.anchor_index].setHandleOut(handle_relative);
            } else {
                anchors.items[dh.anchor_index].setHandleIn(handle_relative);
            }
            changed = true;
        } else {
            state.drag_handle = null;
        }
    }

    // Anchor dragging
    if (state.drag_index) |idx| {
        if (state.drag_handle == null and rl.isMouseButtonDown(rl.MouseButton.left)) {
            const m = rl.getMousePosition();
            const mp = mouseToPath(vp, m);
            anchors.items[idx].pos = .{
                .x = mp.x - state.drag_off.x,
                .y = mp.y - state.drag_off.y,
            };
            changed = true;
        } else if (!rl.isMouseButtonDown(rl.MouseButton.left)) {
            state.drag_index = null;
        }
    }
    // Handle mode cycling with M key
    if (hovered and rl.isKeyPressed(rl.KeyboardKey.m)) {
        if (state.selected_anchor) |sel_idx| {
            if (sel_idx < anchors.items.len) {
                const current_mode = anchors.items[sel_idx].mode;
                anchors.items[sel_idx].mode = switch (current_mode) {
                    .corner => .smooth,
                    .smooth => .aligned,
                    .aligned => .corner,
                };

                // Debug output
                const mode_name = switch (anchors.items[sel_idx].mode) {
                    .corner => "Corner",
                    .smooth => "Smooth",
                    .aligned => "Aligned",
                };
                std.debug.print("Anchor {} mode: {s}\n", .{ sel_idx, mode_name });

                changed = true;
            }
        }
    }
    // coords overlay (optional)
    if (hovered) {
        const m = rl.getMousePosition();
        const mp = mouseToPath(vp, m);
        var buf: [128:0]u8 = undefined;
        const s = std.fmt.bufPrintZ(&buf, "x: {d:.3}  y: {d:.3}", .{ mp.x, mp.y }) catch "x:? y:?";
        rl.drawTextEx(font, s, .{ .x = bounds.x + p.pad, .y = bounds.y + p.pad }, p.font_px, 0.0, rl.Color.dark_gray);
    }

    return .{ .hovered = hovered, .vp = vp, .changed = changed };
}

fn hitPoint(vp: rl.Rectangle, pts: []const arcade.Vec2, m: rl.Vector2, hit_r: f32) ?usize {
    const hit_r2 = hit_r * hit_r;
    var best_i: ?usize = null;
    var best_d2: f32 = 0;

    for (pts, 0..) |pt, i| {
        const s = pathToScreen(vp, pt);
        const dx = m.x - s.x;
        const dy = m.y - s.y;
        const d2 = dx * dx + dy * dy;
        if (d2 <= hit_r2 and (best_i == null or d2 < best_d2)) {
            best_i = i;
            best_d2 = d2;
        }
    }
    return best_i;
}

fn pathToScreen(vp: rl.Rectangle, p: arcade.Vec2) rl.Vector2 {
    return .{
        .x = vp.x + p.x * vp.width,
        .y = vp.y + p.y * vp.height,
    };
}

fn mouseToPath(vp: rl.Rectangle, m: rl.Vector2) arcade.Vec2 {
    return .{
        .x = (m.x - vp.x) / vp.width,
        .y = (m.y - vp.y) / vp.height,
    };
}

fn drawCurve(vp: rl.Rectangle, anchors: []const arcade.AnchorPoint, control_points: []const arcade.Vec2, selected_anchor: ?usize, r: f32) void {
    // 1) Draw the bezier curve
    drawBezierCurve(vp, control_points, r);

    // 2) Draw anchor connection lines (simplified control polygon)
    drawAnchorLines(vp, anchors, r);

    // 3) Draw handles for selected anchor
    if (selected_anchor) |sel_idx| {
        if (sel_idx < anchors.len) {
            drawHandles(vp, anchors[sel_idx], r);
        }
    }

    // 4) Draw anchor points
    for (anchors, 0..) |anchor, i| {
        const s = pathToScreen(vp, anchor.pos);
        const is_selected = if (selected_anchor) |sel| sel == i else false;

        const color = if (is_selected) rl.Color.orange else rl.Color.sky_blue;
        rl.drawCircleV(s, r, color);
        rl.drawCircleLines(@intFromFloat(s.x), @intFromFloat(s.y), r, rl.Color.black);
    }
}

fn drawAnchorLines(vp: rl.Rectangle, anchors: []const arcade.AnchorPoint, r: f32) void {
    if (anchors.len < 2) return;

    for (anchors[0 .. anchors.len - 1], 0..) |a, i| {
        const b = anchors[i + 1];
        rl.drawLineEx(pathToScreen(vp, a.pos), pathToScreen(vp, b.pos), 1 * @min(r / 7.0, 2.0), rl.Color.init(100, 100, 100, 100));
    }
}

fn drawHandles(vp: rl.Rectangle, anchor: arcade.AnchorPoint, r: f32) void {
    const anchor_screen = pathToScreen(vp, anchor.pos);

    // Draw handle_in
    if (anchor.getHandleInPos()) |handle_pos| {
        const handle_screen = pathToScreen(vp, handle_pos);
        rl.drawLineEx(
            anchor_screen,
            handle_screen,
            1 * @min(r / 7.0, 2.0),
            rl.Color.green,
        );
        rl.drawCircleV(handle_screen, 4 * (r / 7.0), rl.Color.green);
    }

    // Draw handle_out
    if (anchor.getHandleOutPos()) |handle_pos| {
        const handle_screen = pathToScreen(vp, handle_pos);
        rl.drawLineEx(anchor_screen, handle_screen, 1 * @min(r / 7.0, 2.0), rl.Color.red);
        rl.drawCircleV(handle_screen, 4 * (r / 7.0), rl.Color.red);
    }
}

fn drawBezierCurve(vp: rl.Rectangle, control_pts: []const arcade.Vec2, r: f32) void {
    if (control_pts.len < 2) return;

    const def = arcade.PathDefinition{ .control_points = control_pts };

    const steps: usize = @max(12, @as(usize, @intFromFloat(@floor(@max(vp.width, vp.height) / 5.0))));

    var prev: ?rl.Vector2 = null;

    var i: usize = 0;
    while (i <= steps) : (i += 1) {
        const t: f32 = @as(f32, @floatFromInt(i)) / @as(f32, @floatFromInt(steps));
        const p = def.getPosition(t);
        const sp = pathToScreen(vp, p);

        if (prev) |a| {
            rl.drawLineEx(a, sp, 3 * @min(r / 7.0, 2.0), rl.Color.yellow);
        }
        prev = sp;
    }
}

fn hitAnchor(vp: rl.Rectangle, anchors: []const arcade.AnchorPoint, m: rl.Vector2, hit_r: f32) ?usize {
    const hit_r2 = hit_r * hit_r;
    var best_i: ?usize = null;
    var best_d2: f32 = 0;

    for (anchors, 0..) |anchor, i| {
        const s = pathToScreen(vp, anchor.pos);
        const dx = m.x - s.x;
        const dy = m.y - s.y;
        const d2 = dx * dx + dy * dy;
        if (d2 <= hit_r2 and (best_i == null or d2 < best_d2)) {
            best_i = i;
            best_d2 = d2;
        }
    }
    return best_i;
}

fn hitHandle(vp: rl.Rectangle, anchor: arcade.AnchorPoint, m: rl.Vector2, hit_r: f32) ?bool {
    const hit_r2 = hit_r * hit_r;

    // Check handle_out first (prioritize over handle_in)
    if (anchor.getHandleOutPos()) |handle_pos| {
        const s = pathToScreen(vp, handle_pos);
        const dx = m.x - s.x;
        const dy = m.y - s.y;
        const d2 = dx * dx + dy * dy;
        if (d2 <= hit_r2) return true; // is_out = true
    }

    // Check handle_in
    if (anchor.getHandleInPos()) |handle_pos| {
        const s = pathToScreen(vp, handle_pos);
        const dx = m.x - s.x;
        const dy = m.y - s.y;
        const d2 = dx * dx + dy * dy;
        if (d2 <= hit_r2) return false; // is_out = false
    }

    return null;
}

// Remove the old drawPoints and drawControlPolygon functions
fn fitAspectCenter(bounds: rl.Rectangle, width: f32, height: f32, margin: f32) rl.Rectangle {
    const ar = width / height;

    const avail_w = @max(0.0, bounds.width - margin * 2.0);
    const avail_h = @max(0.0, bounds.height - margin * 2.0);

    var w = avail_w;
    var h = w / ar;

    if (h > avail_h) {
        h = avail_h;
        w = h * ar;
    }

    return .{
        .x = bounds.x + (bounds.width - w) * 0.5,
        .y = bounds.y + (bounds.height - h) * 0.5,
        .width = w,
        .height = h,
    };
}
