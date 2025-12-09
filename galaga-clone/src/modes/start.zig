const TextGrid = @import("renderer").TextGrid;
const Font = @import("renderer").types.Font;
const Input = @import("renderer").types.Input;
const Texture = @import("renderer").types.Texture;
const Color = @import("renderer").types.Color;
const Vec2 = @import("renderer").types.Vec2;
const cyan = @import("renderer").types.cyan;
const Sprite = @import("../sprite.zig").Sprite;
const SpriteFrame = @import("../sprite.zig").SpriteFrame;

pub const Start = struct {
    pub fn init() @This() {
        return .{};
    }
    pub fn update(self: *@This(), dt: f32, input: Input) void {
        _ = self;
        _ = dt;
        _ = input;
    }
    pub fn draw(self: *const @This(), ctx: anytype) void {
        const arcade_font = ctx.renderer.asset_manager.getAsset(Font, "main");
        const tex = ctx.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;
        const sprite: Sprite = ctx.sprite_atlas.getSprite(.player);

        const middle_row = ctx.text_grid.rows / 2;

        const push_start_label = "PUSH START BUTTON";
        const pos_push_start = ctx.text_grid.getCenteredPosition(push_start_label, middle_row - 3);
        ctx.renderer.drawText(push_start_label, pos_push_start, ctx.text_grid.font_size, cyan, arcade_font);

        const pos_bonus = ctx.text_grid.getPosition(5, middle_row);
        ctx.renderer.drawText("1ST BONUS FOR 30000 PTS", pos_bonus, ctx.text_grid.font_size, Color.yellow, arcade_font);

        const pos_bonus_2 = ctx.text_grid.getPosition(5, middle_row + 2);
        ctx.renderer.drawText("2ND BONUS FOR 100000 PTS", pos_bonus_2, ctx.text_grid.font_size, Color.yellow, arcade_font);

        const pos_bonus_3 = ctx.text_grid.getPosition(5, middle_row + 4);
        ctx.renderer.drawText("AND FOR EVERY 100000 PTS", pos_bonus_3, ctx.text_grid.font_size, Color.yellow, arcade_font);
        drawSpriteAtTextRow(ctx, tex, sprite.idle_frames[0], 3, middle_row);
        drawSpriteAtTextRow(ctx, tex, sprite.idle_frames[0], 3, middle_row + 2);
        drawSpriteAtTextRow(ctx, tex, sprite.idle_frames[0], 3, middle_row + 4);
        _ = self;
    }
    fn drawSpriteAtTextRow(ctx: anytype, tex: Texture, frame: SpriteFrame, col: u32, row: u32) void {
        const text_pos = ctx.text_grid.getPosition(col, row);
        const sprite_scale = ctx.renderer.config.ssaa_scale;
        const sprite_height = frame.height * sprite_scale;

        // Center sprite vertically with text line
        const sprite_pos = Vec2{
            .x = text_pos.x,
            .y = text_pos.y + (sprite_height / 2) * 0.4,
        };

        ctx.renderer.drawSprite(tex, frame, sprite_pos, Color.white);
    }
};
