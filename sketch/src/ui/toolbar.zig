const rl = @import("raylib");
const std = @import("std");

const sketch = @import("../root.zig");
const Ui = sketch.ui.Ui;
const button = sketch.ui.button;
const layout = sketch.ui.layout;
const Id = sketch.ui.ids.Id;
const Flow = layout.Flow;
const arcade = @import("arcade_lib");

pub const Action = enum {
    None,
    Reload,
    Save,
    New,
    Rename,
    Duplicate,
    Delete,
    FlipH,
    FlipV,
    CycleMode,
};

pub fn draw(
    ui: *Ui,
    font: rl.Font,
    bounds: rl.Rectangle,
    can_save: bool,
    has_paths: bool,
    selected_anchor_mode: ?arcade.HandleMode,
) Action {
    // Toolbar chrome
    rl.drawRectangleRec(bounds, rl.Color.light_gray);
    rl.drawRectangleLinesEx(bounds, 1, rl.Color.gray);

    var flow = layout.Flow.init(bounds);
    const params: Params = .{
        .ui = ui,
        .flow = &flow,
        .font = font,
    };

    if (toolbarButton(params, Id.toolbar_reload_btn, "Reload", true, .Reload)) |a| return a;
    if (toolbarButton(params, Id.toolbar_save_btn, "Save", can_save, .Save)) |a| return a;
    if (toolbarButton(params, Id.toolbar_new_btn, "New", true, .New)) |a| return a;
    if (toolbarButton(params, Id.toolbar_rename_btn, "Rename", has_paths, .Rename)) |a| return a;
    if (toolbarButton(params, Id.toolbar_duplicate_btn, "Duplicate", has_paths, .Duplicate)) |a| return a;
    if (toolbarButton(params, Id.toolbar_delete_btn, "Delete", has_paths, .Delete)) |a| return a;
    if (toolbarButton(params, Id.toolbar_flip_v_btn, "Flip Vertical", has_paths, .FlipV)) |a| return a;
    if (toolbarButton(params, Id.toolbar_flip_h_btn, "Flip Horizontal", has_paths, .FlipH)) |a| return a;

    if (selected_anchor_mode) |mode| {
        const mode_label = switch (mode) {
            .corner => "Corner mode: Corner",
            .smooth => "Corner mode: Smooth",
            .aligned => "Corner mode: Aligned",
        };
        var buf: [64:0]u8 = undefined;
        const label = std.fmt.bufPrintZ(&buf, "{s}", .{mode_label}) catch "Mode";
        if (toolbarButton(params, Id.toolbar_mode_btn, label, true, .CycleMode)) |a| return a;
    } else {
        if (toolbarButton(params, Id.toolbar_mode_btn, "Corner mode: (none)", false, .CycleMode)) |a| return a;
    }

    return .None;
}
const Params = struct {
    ui: *Ui,
    font: rl.Font,
    flow: *Flow,
};

fn toolbarButton(
    p: Params,
    id: u32,
    label: [:0]const u8,
    enabled: bool,
    action: Action,
) ?Action {
    const l = p.flow.nextButton(p.font, 18, label);
    if (button.button(p.ui, id, l, p.font, label, enabled, .{}).clicked) return action;

    return null;
}
