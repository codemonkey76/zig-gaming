const std = @import("std");

const r = @import("renderer");
const InputManager = r.InputManager;
const Renderer = r.Renderer;
const Key = r.types.Key;
const Input = r.types.Input;
const AttractMode = @import("modes/attract.zig").Attract;
const PlayingMode = @import("modes/playing.zig").Playing;
const HighScoreMode = @import("modes/high_score.zig").HighScore;

pub const Game = struct {
    allocator: std.mem.Allocator,
    renderer: *Renderer,
    current_mode: GameMode,
    attract: AttractMode,
    playing: PlayingMode,
    high_score: HighScoreMode,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) @This() {
        var game = Game{
            .allocator = allocator,
            .renderer = renderer,
            .current_mode = .attract,
            .attract = AttractMode.init(allocator),
            .playing = PlayingMode.init(allocator),
            .high_score = HighScoreMode.init(allocator),
        };

        game.registerHandlers();
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
        switch (self.current_mode) {
            .attract => self.attract.draw(self.renderer),
            .playing => self.playing.draw(self.renderer),
            .high_score => self.high_score.draw(self.renderer),
        }
    }

    fn registerHandlers(self: *@This()) void {
        self.renderer.input_manager.registerKey(Key.left);
        self.renderer.input_manager.registerKey(Key.right);
    }
};

pub const GameMode = enum {
    attract,
    playing,
    high_score,
};
