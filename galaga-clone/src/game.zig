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
const Starfield = @import("starfield.zig").Starfield;
const StarfieldConfig = @import("starfield.zig").StarfieldConfig;
const Rect = r.types.Rect;
const FormationGrid = @import("formation_grid.zig").FormationGrid;
const Color = r.types.Color;
const Vec2 = r.types.Vec2;
const SpriteAtlas = @import("sprite.zig").SpriteAtlas;
const Texture = r.types.Texture;
const SpriteType = @import("sprite.zig").SpriteType;

pub const FONT_SIZE: i32 = 18;
pub const MAX_STARS: u32 = 100;

pub const Game = struct {
    allocator: std.mem.Allocator,
    renderer: *Renderer,
    text_grid: TextGrid,
    current_mode: GameMode,
    attract: AttractMode,
    playing: PlayingMode,
    high_score: HighScoreMode,
    starfield: Starfield,
    scores_hud: ScoresHud,

    parallax_phase: f32,

    formation_grid: FormationGrid,
    formation_phase: f32,

    sprite_atlas: SpriteAtlas,

    pub fn init(allocator: std.mem.Allocator, renderer: *Renderer) !@This() {
        try loadAssetsStatic(renderer);

        const font = renderer.asset_manager.getAsset(Font, "main") orelse return error.FontNotLoaded;
        try renderer.asset_manager.loadAsset(Texture, "sprites", "assets/sprites/sprites.png");

        const text_grid = TextGrid.init(renderer.render_width, renderer.render_height, font, FONT_SIZE);

        const starfield_rect = Rect{
            .x = 0,
            .y = 0,
            .width = renderer.render_width,
            .height = renderer.render_height,
        };

        const sprite_size: f32 = 16.0 * renderer.config.ssaa_scale;
        const spacing_x = sprite_size * 1.8;
        const spacing_y = sprite_size * 1.4;

        const formation_center = Vec2{
            .x = renderer.render_width / 2.0,
            .y = renderer.render_height * 0.30,
        };

        const formation_spacing = Vec2{
            .x = spacing_x,
            .y = spacing_y,
        };

        var attract_mode = AttractMode.init(allocator);
        errdefer attract_mode.deinit();

        var playing_mode = PlayingMode.init(allocator);
        errdefer playing_mode.deinit();

        var high_score_mode = HighScoreMode.init(allocator);
        errdefer high_score_mode.deinit();

        var starfield = try Starfield.init(allocator, starfield_rect, .{});
        errdefer starfield.deinit();

        const sprite_atlas = try SpriteAtlas.init();

        var game = Game{
            .allocator = allocator,
            .renderer = renderer,
            .text_grid = text_grid,
            .current_mode = .attract,
            .attract = attract_mode,
            .playing = playing_mode,
            .high_score = high_score_mode,
            .scores_hud = ScoresHud.init(),
            .starfield = starfield,
            .parallax_phase = 0.0,

            // NEW
            .formation_grid = FormationGrid.init(formation_center, 8, 5, formation_spacing),
            .formation_phase = 0.0,
            .sprite_atlas = sprite_atlas,
        };

        game.registerHandlers();
        return game;
    }
    pub fn deinit(self: *@This()) void {
        self.starfield.deinit();
        self.attract.deinit();
        self.playing.deinit();
        self.high_score.deinit();
    }

    pub fn drawPlayer(self: *const @This()) void {
        const tex = self.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;
        const sprite = self.sprite_atlas.getSprite(.player);
        if (sprite.idle_count == 0) return;

        const frame = sprite.idle_frames[0];

        const scale = self.renderer.config.ssaa_scale;
        const sprite_h = frame.height * scale;

        const center = Vec2{
            .x = self.renderer.render_width / 2.0,
            .y = self.renderer.render_height - sprite_h / 2.0,
        };

        self.renderer.drawSprite(tex, frame, center, Color.white);
    }

    pub fn update(self: *@This(), dt: f32, input: Input) void {
        const osc_speed: f32 = 0.5;
        self.parallax_phase += dt * (osc_speed * 2.0 * std.math.pi);

        // ~0.5 Hz breathing for the formation
        const formation_speed: f32 = 0.25;
        self.formation_phase += dt * (formation_speed * 2.0 * std.math.pi);

        self.starfield.update(dt);
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
        self.drawPlayer();
        self.scores_hud.draw(self.renderer, &self.text_grid);
        self.starfield.draw(self.renderer, std.math.sin(self.parallax_phase));

        // -- Formation debug visualization
        const base: f32 = 1.0;
        const amp: f32 = 0.08;
        const pulse = base + amp * std.math.sin(self.formation_phase);

        var row: u32 = 0;
        while (row < self.formation_grid.rows) : (row += 1) {
            var col: u32 = 0;
            while (col < self.formation_grid.cols) : (col += 1) {
                const pos = self.formation_grid.getPosition(col, row, pulse);
                self.renderer.drawCircle(pos, 3.0, Color.green);
            }
        }
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
