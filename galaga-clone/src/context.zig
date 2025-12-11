const engine = @import("arcade_engine");
const Window = engine.core.Window;
const Renderer = engine.core.Renderer;
const InputManager = engine.input.InputManager;
const AssetManager = engine.core.AssetManager;
const TextGrid = engine.spatial.TextGrid;
const FormationGrid = engine.spatial.FormationGrid;
const SpriteAtlas = @import("graphics/sprite.zig").SpriteAtlas;
const GameState = @import("game_state.zig").GameState;

pub const GameContext = struct {
    window: *const Window,
    renderer: *const Renderer,
    input_manager: *const InputManager,
    assets_manager: *const AssetManager,
    text_grid: *const TextGrid,
    formation_grid: *const FormationGrid,
    sprite_atlas: *const SpriteAtlas,
    game_state: *const GameState,
};

pub const MutableGameContext = struct {
    window: *Window,
    renderer: *const Renderer,
    input_manager: *InputManager,
    assets_manager: *AssetManager,
    text_grid: *TextGrid,
    formation_grid: *FormationGrid,
    sprite_atlas: *SpriteAtlas,
    game_state: *GameState,
};
