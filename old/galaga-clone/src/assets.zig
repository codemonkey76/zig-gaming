const std = @import("std");
const engine = @import("arcade_engine");
const Window = engine.core.Window;
const Renderer = engine.core.Renderer;
const AssetManager = engine.core.AssetManager;
const Font = engine.types.Font;
const Texture = engine.types.Texture;
const Color = engine.types.Color;
const Vec2 = engine.types.Vec2;
const TextGrid = engine.spatial.TextGrid;
const FormationGrid = engine.spatial.FormationGrid;
const FormationConfig = engine.spatial.FormationConfig;
const SpriteAtlas = @import("graphics/sprite.zig").SpriteAtlas;
const c = @import("constants.zig");

pub const Assets = struct {
    text_grid: TextGrid,
    formation_grid: FormationGrid,
    sprite_atlas: SpriteAtlas,

    pub fn init(
        _: *const Window,
        renderer: *const Renderer,
        assets_manager: *AssetManager,
    ) !Assets {
        try loadAssets(assets_manager);

        const font = assets_manager.getAsset(Font, "main") orelse
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

    fn loadAssets(assets_manager: *AssetManager) !void {
        try assets_manager.loadFont("main", "assets/fonts/arcade.ttf", c.FONT_SIZE);
        try assets_manager.loadAssetWithColorKey(
            Texture,
            "sprites",
            "assets/sprites/sprites.png",
            Color.black,
        );
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
