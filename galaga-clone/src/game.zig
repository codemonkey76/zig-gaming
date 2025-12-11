const std = @import("std");
const engine = @import("arcade_engine");

const Window = engine.core.Window;
const Renderer = engine.core.Renderer;
const InputManager = engine.input.InputManager;
const AssetManager = engine.core.AssetManager;
const Input = engine.types.Input;

const GameState = @import("game_state.zig").GameState;
const Context = @import("context.zig");
const ModeManager = @import("mode_manager.zig").ModeManager;
const Assets = @import("assets.zig").Assets;
const ScoresHud = @import("ui/scores_hud.zig").ScoresHud;
const Starfield = @import("graphics/starfield.zig").Starfield;

pub const Game = struct {
    allocator: std.mem.Allocator,
    window: *Window,
    renderer: *const Renderer,
    input_manager: *InputManager,
    assets_manager: *AssetManager,

    game_state: GameState,
    assets: Assets,
    mode_manager: ModeManager,

    scores_hud: ScoresHud,
    starfield: Starfield,

    pub fn init(
        allocator: std.mem.Allocator,
        window: *Window,
        renderer: *const Renderer,
        input_manager: *InputManager,
        assets_manager: *AssetManager,
    ) !Game {
        const assets = try Assets.init(window, renderer, assets_manager);

        var mode_manager = try ModeManager.init(allocator);
        errdefer mode_manager.deinit();

        var starfield = try Starfield.init(
            allocator,
            renderer.render_width,
            renderer.render_height,
            .{},
        );
        errdefer starfield.deinit();

        var game = Game{
            .allocator = allocator,
            .window = window,
            .renderer = renderer,
            .input_manager = input_manager,
            .assets_manager = assets_manager,
            .game_state = GameState.init(),
            .assets = assets,
            .mode_manager = mode_manager,
            .scores_hud = ScoresHud.init(),
            .starfield = starfield,
        };

        game.registerHandlers();
        const ctx = game.getMutableContext();
        game.mode_manager.attract.onEnter(ctx);

        return game;
    }

    pub fn deinit(self: *Game) void {
        const ctx = self.getMutableContext();

        switch (self.mode_manager.current_mode) {
            inline else => |mode| {
                const mode_ptr = &@field(self.mode_manager, @tagName(mode));
                mode_ptr.onExit(ctx);
            },
        }

        self.starfield.deinit();
        self.mode_manager.deinit();
    }

    pub fn update(self: *Game, dt: f32, input: *Input) void {
        self.handleInput(input);
        const ctx = self.getMutableContext();

        self.starfield.update(dt, ctx);
        self.scores_hud.update(dt, ctx);
        self.assets.formation_grid.update(dt);
        self.mode_manager.update(dt, input, ctx);
    }

    pub fn draw(self: *const Game) void {
        const ctx = self.getContext();
        self.scores_hud.draw(ctx);
        self.starfield.draw(ctx);
        self.mode_manager.draw(ctx);
        self.drawDebug(ctx);
    }

    fn drawDebug(self: *const Game, ctx: Context.GameContext) void {
        self.mode_manager.drawDebug(ctx);
    }

    fn getContext(self: *const Game) Context.GameContext {
        return .{
            .window = self.window,
            .renderer = self.renderer,
            .input_manager = self.input_manager,
            .assets_manager = self.assets_manager,
            .text_grid = &self.assets.text_grid,
            .formation_grid = &self.assets.formation_grid,
            .sprite_atlas = &self.assets.sprite_atlas,
            .game_state = &self.game_state,
        };
    }

    fn getMutableContext(self: *Game) Context.MutableGameContext {
        return .{
            .window = self.window,
            .renderer = self.renderer,
            .input_manager = self.input_manager,
            .assets_manager = self.assets_manager,
            .text_grid = &self.assets.text_grid,
            .formation_grid = &self.assets.formation_grid,
            .sprite_atlas = &self.assets.sprite_atlas,
            .game_state = &self.game_state,
        };
    }

    fn handleInput(self: *Game, input: *Input) void {
        if (input.isKeyPressed(.five)) {
            self.insertCoin();
        }
    }

    fn insertCoin(self: *Game) void {
        self.game_state.credits += 1;
        std.debug.print("Coin inserted, credits: {}\n", .{self.game_state.credits});

        if (self.mode_manager.current_mode == .attract and self.game_state.credits > 0) {
            self.mode_manager.transitionTo(.start, self.getMutableContext());
        }
    }

    fn registerHandlers(self: *Game) void {
        self.input_manager.registerKey(engine.types.Key.one);
        self.input_manager.registerKey(engine.types.Key.two);
        self.input_manager.registerKey(engine.types.Key.five);
    }
};
