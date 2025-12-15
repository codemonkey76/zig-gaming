const std = @import("std");
const rl = @import("raylib");

const ui_mod = @import("../ui.zig");
const Ui = ui_mod.Ui;

const button = @import("../button.zig");
const text_input = @import("../text_input.zig");
const ids = @import("../ids.zig");

pub const Action = enum { None, Create, Cancel };

pub const Result = struct {
    action: Action = .None,
    name: []const u8 = "",
    name_changed: bool = false,
};

pub fn draw(
    ui: *Ui,
    font: rl.Font,
    input_state: *text_input.State,
    buf: []u8,
    len: *usize,
    name_ok: bool,
    err_msg: ?[:0]const u8,
    scale: f32,
) Result {
    const sw = @as(f32, @floatFromInt(rl.getScreenWidth()));
    const sh = @as(f32, @floatFromInt(rl.getScreenHeight()));

    rl.drawRectangle(0, 0, @intFromFloat(sw), @intFromFloat(sh), rl.fade(rl.Color.black, 0.45));

    const dlg_w: f32 = 520 * scale;
    const dlg_h: f32 = 220 * scale;
    const dlg = rl.Rectangle{
        .x = (sw - dlg_w) * 0.5,
        .y = (sh - dlg_h) * 0.5,
        .width = dlg_w,
        .height = dlg_h,
    };

    rl.drawRectangleRec(dlg, rl.Color.light_gray);
    rl.drawRectangleLinesEx(dlg, 1, rl.Color.gray);

    rl.drawTextEx(font, "Create new path", .{ .x = dlg.x + 18 * scale, .y = dlg.y + 16 * scale }, 20 * scale, 0, rl.Color.black);
    rl.drawTextEx(font, "Name:", .{ .x = dlg.x + 18 * scale, .y = dlg.y + 60 * scale }, 18 * scale, 0, rl.Color.dark_gray);

    const input_rect = rl.Rectangle{
        .x = dlg.x + 90 * scale,
        .y = dlg.y + 52 * scale,
        .width = dlg.width - 108 * scale,
        .height = 44 * scale,
    };

    const ti = text_input.textInput(
        ui,
        input_state,
        ids.Id.modal_create,
        input_rect,
        font,
        buf,
        len,
        40,
        .{
            .font_px = 18.0 * scale,
            .pad_x = 10.0 * scale,
            .pad_y = 8.0 * scale,
        },
    );

    var out: Result = .{
        .name = buf[0..len.*],
        .name_changed = ti.changed,
    };

    if (ti.canceled) out.action = .Cancel;
    if (ti.submitted and name_ok) out.action = .Create;

    if (err_msg) |e| {
        rl.drawTextEx(font, e, .{ .x = dlg.x + 18 * scale, .y = dlg.y + 110 * scale }, 16 * scale, 0, rl.Color.maroon);
    }

    const row = rl.Rectangle{
        .x = dlg.x + 18 * scale,
        .y = dlg.y + dlg.height - 56 * scale,
        .width = dlg.width - 36 * scale,
        .height = 40 * scale,
    };

    const bw: f32 = 130 * scale;
    const gap: f32 = 10 * scale;

    const r_create = rl.Rectangle{ .x = row.x, .y = row.y, .width = bw, .height = row.height };
    const r_cancel = rl.Rectangle{ .x = row.x + bw + gap, .y = row.y, .width = bw, .height = row.height };

    if (button.button(ui, ids.Id.modal_create_ok, r_create, font, "Create", name_ok, .{
        .font_px = 18.0 * scale,
        .pad_x = 12.0 * scale,
        .pad_y = 8.0 * scale,
    }).clicked) out.action = .Create;
    if (button.button(ui, ids.Id.modal_create_cancel, r_cancel, font, "Cancel", true, .{
        .font_px = 18.0 * scale,
        .pad_x = 12.0 * scale,
        .pad_y = 8.0 * scale,
    }).clicked) out.action = .Cancel;

    return out;
}
