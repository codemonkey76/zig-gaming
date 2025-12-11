const std = @import("std");
const r = @import("renderer");
const Renderer = r.Renderer;
const Font = r.types.Font;
const Texture = r.types.Texture;
const Color = r.types.Color;
const Vec2 = r.types.Vec2;
const TextGrid = r.TextGrid;
const FormationGrid = r.FormationGrid;
const FormationConfig = r.FormationConfig;
const SpriteAtlas = @import("graphics/sprite.zig").SpriteAtlas;
const c = @import("constants.zig");

pub const Assets = struct {
    text_grid: TextGrid,
    formation_grid: FormationGrid,
    sprite_atlas: SpriteAtlas,

    pub fn init(renderer: *Renderer) !Assets {
        try loadAssets(renderer);

        const font = renderer.asset_manager.getAsset(Font, "main") orelse
            return error.FontNotLoaded;

        const text_grid = TextGrid.init(
            renderer.render_width,
            renderer.render_height,
            font,
            c.FONT_SIZE,
        );

        return .{
            .text_grid = text_grid,
            .formation_grid = initFormationGrid(),
            .sprite_atlas = try SpriteAtlas.init(),
        };
    }

    fn loadAssets(renderer: *Renderer) !void {
        try renderer.asset_manager.loadFont("main", "assets/fonts/arcade.ttf", c.FONT_SIZE);
        try renderer.asset_manager.loadAssetWithColorKey(Texture, "sprites", "assets/sprites/sprites.png", Color.black);
    }

    fn initFormationGrid() FormationGrid {
        const spacing = Vec2{ .x = 0.07, .y = 0.06 };
        const center = Vec2{ .x = 0.50, .y = 0.30 };
        const config = FormationConfig{};

        return FormationGrid.init(
            center,
            10,
            6,
            spacing,
            10,
            config,
        );
    }
};
