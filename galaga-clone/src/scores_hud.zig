const Font = @import("renderer").types.Font;
const TextGrid = @import("renderer").TextGrid;
const Color = @import("renderer").types.Color;
const GameContext = @import("game.zig").GameContext;
const MutableGameContext = @import("game.zig").MutableGameContext;
const std = @import("std");

pub const ScoresHud = struct {
    flash_timer: f32 = 0,
    flash_on: bool = true,

    pub fn init() @This() {
        return .{};
    }
    pub fn update(self: *@This(), dt: f32, _: MutableGameContext) void {
        self.flash_timer += dt;

        if (self.flash_timer > 0.5) {
            self.flash_on = !self.flash_on;
            self.flash_timer = 0;
        }
    }

    pub fn draw(self: *const @This(), ctx: GameContext) void {
        const r = ctx.renderer;
        const text_grid = ctx.text_grid;

        const arcade_font = r.asset_manager.getAsset(Font, "main");

        const pos_1up = text_grid.getPosition(0, 0);
        r.drawText("  1UP", pos_1up, text_grid.font_size, Color.red, arcade_font);

        if (ctx.game_state.active and ctx.game_state.current_player == 1 and self.flash_on) {
            const pos_1up_score = text_grid.getPosition(0, 1);
            var buf: [32]u8 = undefined;
            const score_text = std.fmt.bufPrintZ(&buf, "    {d}0", .{ctx.game_state.p1_score / 10}) catch "    00";
            r.drawText(score_text, pos_1up_score, text_grid.font_size, Color.white, arcade_font);
        }

        const hs_label = "HIGH SCORE";
        const hs_label_pos = text_grid.getCenteredPosition(hs_label, 0);
        r.drawText(hs_label, hs_label_pos, text_grid.font_size, Color.red, arcade_font);

        const hs = "20000";
        const hs_pos = text_grid.getCenteredPosition(hs, 1);
        r.drawText(hs, hs_pos, text_grid.font_size, Color.white, arcade_font);

        const label_2up = "   2UP ";
        const pos_label_2up = text_grid.getRightAlignedPosition(label_2up, 0);
        r.drawText(label_2up, pos_label_2up, text_grid.font_size, Color.red, arcade_font);

        if (ctx.game_state.active and ctx.game_state.current_player == 2 and self.flash_on) {
            var buf: [32]u8 = undefined;
            const score_text = std.fmt.bufPrintZ(&buf, "    {d}0", .{ctx.game_state.p2_score / 10}) catch "    00";
            const pos_label_2up_score = text_grid.getRightAlignedPosition(score_text, 1);
            r.drawText(score_text, pos_label_2up_score, text_grid.font_size, Color.white, arcade_font);
        }

        if (!ctx.game_state.active) {
            var buf: [32]u8 = undefined;
            const credits = std.fmt.bufPrintZ(&buf, "CREDIT {d}", .{ctx.game_state.credits}) catch "CREDIT 0";
            const pos_credits = text_grid.getBottomPosition(0, 0);
            r.drawText(credits, pos_credits, text_grid.font_size, Color.white, arcade_font);
        }
    }
};
