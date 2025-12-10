const std = @import("std");
const r = @import("renderer");

const Renderer = r.Renderer;
const InputManager = r.InputManager;
const TextGrid = r.TextGrid;
const FormationGrid = r.FormationGrid;
const FormationConfig = r.FormationConfig;

const Input = r.types.Input;
const Key = r.types.Key;
const Font = r.types.Font;
const Texture = r.types.Texture;
const Color = r.types.Color;
const Vec2 = r.types.Vec2;
const Rect = r.types.Rect;

const AttractMode = @import("modes/attract.zig").Attract;
const PlayingMode = @import("modes/playing.zig").Playing;
const HighScoreMode = @import("modes/high_score.zig").HighScore;
const StartMode = @import("modes/start.zig").Start;

const ScoresHud = @import("scores_hud.zig").ScoresHud;
const Starfield = @import("starfield.zig").Starfield;
const SpriteAtlas = @import("sprite.zig").SpriteAtlas;
const SpriteType = @import("sprite.zig").SpriteType;

pub const FONT_SIZE: i32 = 18;

pub const Game = struct {
    allocator: std.mem.Allocator,
    renderer: *Renderer,

    // UI
    text_grid: TextGrid,
    scores_hud: ScoresHud,
    starfield: Starfield,

    // Game State
    current_mode: GameMode,
    game_state: GameState,

    // Modes
    attract: AttractMode,
    playing: PlayingMode,
    high_score: HighScoreMode,
    start: StartMode,

    // Assets
    formation_grid: FormationGrid,
    sprite_atlas: SpriteAtlas,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !Game {
        try loadAssets(renderer);

        const font = renderer.asset_manager.getAsset(Font, "main") orelse return error.FontNotLoaded;

        const text_grid = TextGrid.init(renderer.render_width, renderer.render_height, font, FONT_SIZE);

        const formation_grid = initFormationGrid();
        const sprite_atlas = try SpriteAtlas.init();

        var attract_mode = AttractMode.init(allocator);
        errdefer attract_mode.deinit();

        var playing_mode = PlayingMode.init(allocator);
        errdefer playing_mode.deinit();

        var high_score_mode = HighScoreMode.init(allocator);
        errdefer high_score_mode.deinit();

        const start_mode = StartMode.init();

        var starfield = try Starfield.init(
            allocator,
            renderer.render_width,
            renderer.render_height,
            .{},
        );
        errdefer starfield.deinit();

        var game = Game{
            .allocator = allocator,
            .renderer = renderer,
            .text_grid = text_grid,
            .scores_hud = ScoresHud.init(),
            .starfield = starfield,
            .current_mode = .attract,
            .game_state = .{},
            .attract = attract_mode,
            .playing = playing_mode,
            .high_score = high_score_mode,
            .start = start_mode,
            .formation_grid = formation_grid,
            .sprite_atlas = sprite_atlas,
        };

        game.registerHandlers();

        const ctx = game.getMutableContext();
        attract_mode.onEnter(ctx);

        return game;
    }
    pub fn deinit(self: *Game) void {
        const ctx = self.getMutableContext();

        switch (self.current_mode) {
            .attract => self.attract.onExit(ctx),
            .start => self.start.onExit(ctx),
            .playing => self.playing.onExit(ctx),
            .high_score => self.high_score.onExit(ctx),
        }

        self.starfield.deinit();
        self.attract.deinit();
        self.playing.deinit();
        self.high_score.deinit();
    }

    pub fn update(self: *Game, dt: f32, input: *Input) void {
        self.handleInput(input);
        const ctx = self.getMutableContext();
        self.starfield.update(dt, ctx);
        self.formation_grid.update(dt);

        switch (self.current_mode) {
            .attract => {
                self.attract.update(dt, input, ctx);
                if (self.attract.shouldTransition()) {
                    self.current_mode = .attract; // Loop attract mode
                }
            },
            .start => {
                self.start.update(dt, input, ctx);
                if (self.start.shouldTransition()) {
                    self.transitionTo(.playing);
                }
            },
            .playing => {
                self.playing.update(dt, input, ctx);
                if (self.playing.shouldTransition()) {
                    self.transitionTo(.high_score);
                }
            },
            .high_score => {
                self.high_score.update(dt, input, ctx);
                if (self.high_score.shouldTransition()) {
                    self.transitionTo(.attract);
                }
            },
        }
    }

    pub fn draw(self: *const Game) void {
        const ctx = self.getContext();

        self.drawGlobal(ctx);
        switch (self.current_mode) {
            .attract => self.attract.draw(ctx),
            .start => self.start.draw(ctx),
            .playing => self.playing.draw(ctx),
            .high_score => self.high_score.draw(ctx),
        }
    }

    pub fn drawDebug(self: *const Game) void {
        const ctx = self.getContext();

        switch (self.current_mode) {
            .attract => self.attract.drawDebug(ctx),
            .start => self.start.drawDebug(ctx),
            .playing => self.playing.drawDebug(ctx),
            .high_score => self.high_score.drawDebug(ctx),
        }
    }

    fn transitionTo(self: *Game, new_mode: GameMode) void {
        if (self.current_mode == new_mode) return;

        const ctx = self.getMutableContext();

        switch (self.current_mode) {
            .attract => self.attract.onExit(ctx),
            .start => self.start.onExit(ctx),
            .playing => self.playing.onExit(ctx),
            .high_score => self.high_score.onExit(ctx),
        }

        self.current_mode = new_mode;

        switch (new_mode) {
            .attract => self.attract.onEnter(ctx),
            .start => self.start.onEnter(ctx),
            .playing => self.playing.onEnter(ctx),
            .high_score => self.high_score.onEnter(ctx),
        }
    }

    fn getContext(self: *const Game) GameContext {
        return .{
            .renderer = @constCast(self.renderer),
            .text_grid = &self.text_grid,
            .formation_grid = &self.formation_grid,
            .sprite_atlas = &self.sprite_atlas,
            .game_state = &self.game_state,
        };
    }

    fn getMutableContext(self: *Game) MutableGameContext {
        return .{
            .renderer = self.renderer,
            .text_grid = &self.text_grid,
            .formation_grid = &self.formation_grid,
            .sprite_atlas = &self.sprite_atlas,
            .game_state = &self.game_state,
        };
    }

    fn drawGlobal(self: *const Game, ctx: GameContext) void {
        self.scores_hud.draw(ctx);
        self.starfield.draw(ctx);
    }

    fn handleInput(self: *Game, input: *Input) void {
        if (input.isKeyPressed(.five)) {
            self.insertCoin();
        }
    }

    fn insertCoin(self: *Game) void {
        self.game_state.credits += 1;
        std.debug.print("Coin inserted, credits: {}\n", .{self.game_state.credits});

        if (self.current_mode == .attract and self.game_state.credits > 0) {
            self.transitionTo(.start);
        }
    }

    fn registerHandlers(self: *Game) void {
        self.renderer.input_manager.registerKey(Key.one);
        self.renderer.input_manager.registerKey(Key.two);
        self.renderer.input_manager.registerKey(Key.five);
    }

    fn loadAssets(renderer: *Renderer) !void {
        try renderer.asset_manager.loadFont("main", "assets/fonts/arcade.ttf", FONT_SIZE);
        try renderer.asset_manager.loadAssetWithColorKey(Texture, "sprites", "assets/sprites/sprites.png", Color.black);
    }

    fn initFormationGrid() FormationGrid {
        const spacing = Vec2{
            .x = 0.07,
            .y = 0.06,
        };
        const center = Vec2{
            .x = 0.50,
            .y = 0.30,
        };
        const config = FormationConfig{};

        return FormationGrid.init(center, 10, 6, spacing, 10, config);
    }
};

pub const GameMode = enum {
    attract,
    start,
    playing,
    high_score,
};

pub const GameState = struct {
    parallax_phase: f32 = 0.0,
    credits: u32 = 0,
    num_players: u8 = 0,
    current_player: u8 = 0,
};

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
