const std = @import("std");

const r = @import("renderer");
const InputManager = r.InputManager;
const Renderer = r.Renderer;
const Key = r.types.Key;
const Input = r.types.Input;
const AttractMode = @import("modes/attract.zig").Attract;
const PlayingMode = @import("modes/playing.zig").Playing;
const HighScoreMode = @import("modes/high_score.zig").HighScore;
const ScoresHud = @import("scores_hud.zig").ScoresHud;
const Font = r.types.Font;
const TextGrid = @import("renderer").TextGrid;

pub const FONT_SIZE: i32 = 18;

pub const Game = struct {
    allocator: std.mem.Allocator,
    renderer: *Renderer,
    text_grid: TextGrid,
    current_mode: GameMode,
    attract: AttractMode,
    playing: PlayingMode,
    high_score: HighScoreMode,
    scores_hud: ScoresHud,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !@This() {
        try loadAssetsStatic(renderer);

        const font = renderer.asset_manager.getAsset(Font, "main") orelse return error.FontNotLoaded;

        const text_grid = TextGrid.init(renderer.render_width, renderer.render_height, font, FONT_SIZE);

        var game = Game{
            .allocator = allocator,
            .renderer = renderer,
            .text_grid = text_grid,
            .current_mode = .attract,
            .attract = AttractMode.init(allocator),
            .playing = PlayingMode.init(allocator),
            .high_score = HighScoreMode.init(allocator),
            .scores_hud = ScoresHud.init(),
        };

        game.registerHandlers();
        errdefer {
            game.attract.deinit();
            game.playing.deinit();
            game.high_score.deinit();
        }
        return game;
    }
    pub fn deinit(self: *@This()) void {
        _ = self;
    }

    pub fn update(self: *@This(), dt: f32, input: Input) void {
        switch (self.current_mode) {
            .attract => {
                self.attract.update(dt, input);
                if (self.attract.shouldTransition()) {
                    std.debug.print("Attract mode timed out, switching to playing mode\n", .{});
                    self.current_mode = .playing;
                }
            },
            .playing => self.playing.update(dt, input),
            .high_score => self.high_score.update(dt, input),
        }
    }

    pub fn draw(self: *const @This()) void {
        self.drawGlobal();
        switch (self.current_mode) {
            .attract => self.attract.draw(self.renderer, &self.text_grid),
            .playing => self.playing.draw(self.renderer, &self.text_grid),
            .high_score => self.high_score.draw(self.renderer, &self.text_grid),
        }
    }

    pub fn drawDebug(self: *const @This()) void {
        switch (self.current_mode) {
            .attract => self.attract.drawDebug(self.renderer),
            .playing => self.playing.drawDebug(self.renderer),
            .high_score => self.high_score.drawDebug(self.renderer),
        }
    }

    fn drawGlobal(self: *const @This()) void {
        self.scores_hud.draw(self.renderer, &self.text_grid);
    }

    fn registerHandlers(self: *@This()) void {
        self.renderer.input_manager.registerKey(Key.left);
        self.renderer.input_manager.registerKey(Key.right);
    }

    fn loadAssetsStatic(renderer: *Renderer) !void {
        try renderer.asset_manager.loadFont("main", "assets/fonts/arcade.ttf", FONT_SIZE);
    }
};

pub const GameMode = enum {
    attract,
    playing,
    high_score,
};
