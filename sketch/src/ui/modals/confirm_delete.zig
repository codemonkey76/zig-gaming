const rl = @import("raylib");
const std = @import("std");
const sketch = @import("../../root.zig");

const Ui = sketch.ui.Ui;
const button = sketch.ui.button;
const Id = sketch.ui.ids.Id;

pub const Action = enum {
    None,
    Yes,
    No,
};

pub fn draw(
    ui: *Ui,
    font: rl.Font,
    label: []const u8,
    scale: f32,
) Action {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));

    // dim background
    rl.drawRectangle(0, 0, @intFromFloat(sw), @intFromFloat(sh), rl.fade(rl.Color.black, 0.45));

    const w: f32 = 420 * scale;
    const h: f32 = 160 * scale;

    const dlg = rl.Rectangle{
        .x = (sw - w) * 0.5,
        .y = (sh - h) * 0.5,
        .width = w,
        .height = h,
    };

    rl.drawRectangleRec(dlg, rl.Color.light_gray);
    rl.drawRectangleLinesEx(dlg, 1, rl.Color.gray);

    var buf: [128:0]u8 = undefined;
    const msg = std.fmt.bufPrintZ(&buf, "Delete \"{s}\"?", .{label}) catch "Delete path?";

    rl.drawTextEx(
        font,
        msg,
        .{ .x = dlg.x + 16 * scale, .y = dlg.y + 20 * scale },
        20 * scale,
        0,
        rl.Color.black,
    );

    const row = rl.Rectangle{
        .x = dlg.x + 16 * scale,
        .y = dlg.y + dlg.height - 52 * scale,
        .width = dlg.width - 32 * scale,
        .height = 36 * scale,
    };

    const bw: f32 = 110 * scale;
    const gap: f32 = 10 * scale;

    const yes_r = rl.Rectangle{ .x = row.x, .y = row.y, .width = bw, .height = row.height };
    const no_r = rl.Rectangle{ .x = row.x + bw + gap, .y = row.y, .width = bw, .height = row.height };

    if (button.button(ui, Id.modal_delete_yes, yes_r, font, "Yes", true, .{
        .font_px = 18.0 * scale,
        .pad_x = 12.0 * scale,
        .pad_y = 8.0 * scale,
    }).clicked) {
        return .Yes;
    }
    if (button.button(ui, Id.modal_delete_no, no_r, font, "No", true, .{
        .font_px = 18.0 * scale,
        .pad_x = 12.0 * scale,
        .pad_y = 8.0 * scale,
    }).clicked) {
        return .No;
    }

    return .None;
}
