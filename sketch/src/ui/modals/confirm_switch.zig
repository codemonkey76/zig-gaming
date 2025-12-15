const rl = @import("raylib");

const ui_mod = @import("../ui.zig");
const Ui = ui_mod.Ui;

const button = @import("../button.zig");
const ids = @import("../ids.zig");

pub const Action = enum { None, Yes, No, Cancel };

pub fn draw(ui: *Ui, font: rl.Font, scale: f32) Action {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));

    rl.drawRectangle(0, 0, @intFromFloat(sw), @intFromFloat(sh), rl.fade(rl.Color.black, 0.45));

    const dlg_w: f32 = 420 * scale;
    const dlg_h: f32 = 160 * scale;
    const dlg = rl.Rectangle{
        .x = (sw - dlg_w) * 0.5,
        .y = (sh - dlg_h) * 0.5,
        .width = dlg_w,
        .height = dlg_h,
    };

    rl.drawRectangleRec(dlg, rl.Color.light_gray);
    rl.drawRectangleLinesEx(dlg, 1, rl.Color.gray);

    const msg = "Save changes?";
    rl.drawTextEx(font, msg, .{ .x = dlg.x + 18 * scale, .y = dlg.y + 18 * scale }, 20 * scale, 0, rl.Color.black);

    const row = rl.Rectangle{
        .x = dlg.x + 18 * scale,
        .y = dlg.y + dlg.height - 56 * scale,
        .width = dlg.width - 36 * scale,
        .height = 40 * scale,
    };

    const bw: f32 = 110 * scale;
    const gap: f32 = 10 * scale;

    const r_yes = rl.Rectangle{ .x = row.x, .y = row.y, .width = bw, .height = row.height };
    const r_no = rl.Rectangle{ .x = row.x + bw + gap, .y = row.y, .width = bw, .height = row.height };
    const r_can = rl.Rectangle{ .x = row.x + (bw + gap) * 2, .y = row.y, .width = bw, .height = row.height };

    if (button.button(ui, ids.Id.modal_yes, r_yes, font, "Yes", true, .{
        .font_px = 18.0 * scale,
        .pad_x = 12.0 * scale,
        .pad_y = 8.0 * scale,
    }).clicked) return .Yes;
    if (button.button(ui, ids.Id.modal_no, r_no, font, "No", true, .{
        .font_px = 18.0 * scale,
        .pad_x = 12.0 * scale,
        .pad_y = 8.0 * scale,
    }).clicked) return .No;
    if (button.button(ui, ids.Id.modal_cancel, r_can, font, "Cancel", true, .{
        .font_px = 18.0 * scale,
        .pad_x = 12.0 * scale,
        .pad_y = 8.0 * scale,
    }).clicked) return .Cancel;

    return .None;
}
