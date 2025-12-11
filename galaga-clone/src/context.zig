const r = @import("renderer");
const Renderer = r.Renderer;
const TextGrid = r.TextGrid;
const FormationGrid = r.FormationGrid;
const SpriteAtlas = @import("graphics/sprite.zig").SpriteAtlas;
const GameState = @import("game_state.zig").GameState;

pub const GameContext = struct {
    renderer: *const Renderer,
    text_grid: *const TextGrid,
    formation_grid: *const FormationGrid,
    sprite_atlas: *const SpriteAtlas,
    game_state: *const GameState,
};

pub const MutableGameContext = struct {
    renderer: *Renderer,
    text_grid: *TextGrid,
    formation_grid: *FormationGrid,
    sprite_atlas: *SpriteAtlas,
    game_state: *GameState,
};
