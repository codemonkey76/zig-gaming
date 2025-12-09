const Renderer = @import("renderer").Renderer;
const TextGrid = @import("renderer").TextGrid;
const FormationGrid = @import("renderer").FormationGrid;
const SpriteAtlas = @import("sprite.zig").SpriteAtlas;

pub const GameContext = struct {
    renderer: *Renderer,
    text_grid: *const TextGrid,
    formation_grid: *FormationGrid,
    sprite_atlas: *const SpriteAtlas,
};
