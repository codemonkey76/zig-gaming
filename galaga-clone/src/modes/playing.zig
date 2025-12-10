const std = @import("std");
const r = @import("renderer");

const Input = r.types.Input;
const Color = r.types.Color;
const Vec2 = r.types.Vec2;
const TextGrid = r.TextGrid;
const Texture = r.types.Texture;
const FormationGrid = r.FormationGrid;
const SpriteType = @import("../sprite.zig").SpriteType;
const MutableGameContext = @import("../game.zig").MutableGameContext;
const GameContext = @import("../game.zig").GameContext;
const Key = r.types.Key;
const LevelIndicator = @import("../level_indicator.zig").LevelIndicator;
const LifeIndicator = @import("../life_indicator.zig").LifeIndicator;
const common = @import("common.zig");

// Enemy formation layout: defines which enemy type at each grid position
// null = empty slot
const EnemyFormation = [6][10]?SpriteType{
    // Row 0: Empty - reserved for captured ships
    .{ null, null, null, null, null, null, null, null, null, null },

    // Row 1: 4 Boss in the center
    .{ null, null, null, .boss, .boss, .boss, .boss, null, null, null },

    // Rows 2-3: 16 Goei (8 per row)
    .{ null, .goei, .goei, .goei, .goei, .goei, .goei, .goei, .goei, null },
    .{ null, .goei, .goei, .goei, .goei, .goei, .goei, .goei, .goei, null },

    // Rows 4-5: 20 Zako (10 per row)
    .{ .zako, .zako, .zako, .zako, .zako, .zako, .zako, .zako, .zako, .zako },
    .{ .zako, .zako, .zako, .zako, .zako, .zako, .zako, .zako, .zako, .zako },
};

pub const Playing = struct {
    idle_frame_idx: usize = 0,
    idle_frame_timer: f32 = 0.0,
    level_indicator: LevelIndicator,
    life_indicator: LifeIndicator,

    pub const keys = [_]Key{
        .left,
        .right,
        .space,
        .a,
        .up,
    };
    pub fn init(allocator: std.mem.Allocator) @This() {
        _ = allocator;
        return .{
            .level_indicator = LevelIndicator.init(),
            .life_indicator = LifeIndicator.init(),
        };
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }

    pub fn onEnter(_: *@This(), ctx: MutableGameContext) void {
        common.registerKeys(ctx, &keys);
    }

    pub fn onExit(_: *@This(), ctx: MutableGameContext) void {
        common.unregisterKeys(ctx, &keys);
    }

    pub fn shouldTransition(_: *const @This()) bool {
        return false;
    }

    pub fn update(self: *@This(), dt: f32, input: *Input, ctx: MutableGameContext) void {
        self.handleKeys(input, ctx);
        self.idle_frame_timer += dt;

        if (self.idle_frame_timer > 0.5) {
            self.idle_frame_timer = 0.0;
            self.idle_frame_idx += 1;
        }
    }

    fn handleKeys(self: *@This(), input: *Input, ctx: MutableGameContext) void {
        if (input.isKeyPressed(.a)) {
            ctx.formation_grid.addShip();
        }
        if (input.isKeyPressed(.up)) {
            ctx.game_state.current_stage += 1;
            self.level_indicator.setStage(ctx.game_state.current_stage);
        }
    }

    pub fn draw(self: *const @This(), ctx: GameContext) void {
        self.drawFormationEnemies(ctx);
        self.level_indicator.draw(ctx);
        self.life_indicator.draw(ctx);
    }

    fn drawFormationEnemies(self: *const @This(), ctx: GameContext) void {
        const tex = ctx.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;

        var row: u32 = 0;
        while (row < ctx.formation_grid.rows) : (row += 1) {
            var col: u32 = 0;
            while (col < ctx.formation_grid.cols) : (col += 1) {
                // Check if there's an enemy at this position
                const maybe_sprite_type = EnemyFormation[row][col];
                if (maybe_sprite_type == null) continue;

                const sprite_type = maybe_sprite_type.?;

                // Get normalized position (0.0-1.0)
                const norm_pos = ctx.formation_grid.getPosition(col, row);

                // ✅ Convert to screen coordinates
                const screen_pos = ctx.renderer.normToRender(norm_pos);

                const sprite = ctx.sprite_atlas.getSprite(sprite_type);
                if (sprite.idle_count == 0) continue;

                const idx = self.idle_frame_idx % sprite.idle_count;
                const frame = sprite.idle_frames[idx];

                ctx.renderer.drawSprite(tex, frame, screen_pos, Color.white);
            }
        }
    }

    pub fn drawDebug(self: *const @This(), ctx: anytype) void {
        _ = self;
        ctx.renderer.drawText("Playing Mode", .{ .x = 10, .y = 10 }, 24, Color.white, null);
        var buf: [32]u8 = undefined;
        const ships = std.fmt.bufPrintZ(&buf, "Ships: {d}/{d}", .{ ctx.formation_grid.ships_in_formation, ctx.formation_grid.total_ships }) catch "0";
        ctx.renderer.drawText(ships, .{ .x = 10, .y = 40 }, 18, Color.yellow, null);
    }
};
