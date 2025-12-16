const std = @import("std");
const engine = @import("arcade_engine");
const Input = engine.types.Input;
const AttractMode = @import("modes/attract.zig").Attract;
const PlayingMode = @import("modes/playing.zig").Playing;
const HighScoreMode = @import("modes/high_score.zig").HighScore;
const StartMode = @import("modes/start.zig").Start;
const MutableGameContext = @import("context.zig").MutableGameContext;
const GameContext = @import("context.zig").GameContext;

pub const GameMode = enum {
    attract,
    start,
    playing,
    high_score,
};

pub const ModeManager = struct {
    current_mode: GameMode,
    attract: AttractMode,
    playing: PlayingMode,
    high_score: HighScoreMode,
    start: StartMode,

    pub fn init(allocator: std.mem.Allocator) !ModeManager {
        return .{
            .current_mode = .attract,
            .attract = AttractMode.init(allocator),
            .playing = PlayingMode.init(allocator),
            .high_score = HighScoreMode.init(allocator),
            .start = StartMode.init(),
        };
    }

    pub fn deinit(self: *@This()) void {
        self.attract.deinit();
        self.playing.deinit();
        self.high_score.deinit();
    }

    pub fn transitionTo(self: *@This(), new_mode: GameMode, ctx: MutableGameContext) void {
        if (self.current_mode == new_mode) return;

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

    pub fn update(self: *@This(), dt: f32, input: *Input, ctx: MutableGameContext) void {
        switch (self.current_mode) {
            .attract => {
                self.attract.update(dt, input, ctx);
                if (self.attract.shouldTransition()) {
                    self.current_mode = .attract;
                }
            },
            .start => {
                self.start.update(dt, input, ctx);
                if (self.start.shouldTransition()) {
                    self.transitionTo(.playing, ctx);
                }
            },
            .playing => {
                self.playing.update(dt, input, ctx);
                if (self.playing.shouldTransition()) {
                    self.transitionTo(.high_score, ctx);
                }
            },
            .high_score => {
                self.high_score.update(dt, input, ctx);
                if (self.high_score.shouldTransition()) {
                    self.transitionTo(.attract, ctx);
                }
            },
        }
    }

    pub fn draw(self: *const @This(), ctx: GameContext) void {
        switch (self.current_mode) {
            .attract => self.attract.draw(ctx),
            .start => self.start.draw(ctx),
            .playing => self.playing.draw(ctx),
            .high_score => self.high_score.draw(ctx),
        }
    }
    pub fn drawDebug(self: *const @This(), ctx: GameContext) void {
        switch (self.current_mode) {
            .attract => self.attract.drawDebug(ctx),
            .start => self.start.drawDebug(ctx),
            .playing => self.playing.drawDebug(ctx),
            .high_score => self.high_score.drawDebug(ctx),
        }
    }
};
