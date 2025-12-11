const GameContext = @import("../context.zig").GameContext;
const r = @import("renderer");
const Vec2 = r.types.Vec2;
const Color = r.types.Color;
const Texture = r.types.Texture;
const TILE_SIZE: f32 = 16.0;

pub const LifeIndicator = struct {
    lives: u32 = 1,

    pub fn setLives(self: @This(), lives: u32) void {
        self.lives = lives;
    }

    pub fn init() @This() {
        return .{};
    }

    pub fn draw(_: *const @This(), ctx: GameContext) void {
        const tex = ctx.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;
        const sprite = ctx.sprite_atlas.getSprite(.player);
        if (sprite.idle_count == 0) return;

        const frame = sprite.idle_frames[0];

        const sprite_size = TILE_SIZE * ctx.renderer.config.ssaa_scale;
        const start_y = ctx.renderer.render_height - (sprite_size / 2);
        const start_x = sprite_size / 2;

        var x = start_x;

        const lives = if (ctx.game_state.current_player == 1) ctx.game_state.p1_lives else ctx.game_state.p2_lives;
        for (0..lives) |_| {
            ctx.renderer.drawSprite(tex, frame, Vec2{ .x = x, .y = start_y }, Color.white);
            x += sprite_size;
        }
    }
};
