const std = @import("std");
const Input = @import("renderer").types.Input;
const Color = @import("renderer").types.Color;
const Vec2 = @import("renderer").types.Vec2;
const TextGrid = @import("renderer").TextGrid;
const Texture = @import("renderer").Texture;
const FormationGrid = @import("renderer").FormationGrid;
const SpriteType = @import("../sprite.zig").SpriteType;
const MutableGameContext = @import("../game.zig").MutableGameContext;
const GameContext = @import("../game.zig").GameContext;
const Key = @import("renderer").types.Key;

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
    pub const keys = [_]Key{
        .left,
        .right,
        .space,
    };
    pub fn init(allocator: std.mem.Allocator) @This() {
        _ = allocator;
        return .{};
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }

    pub fn onEnter(_: *@This(), ctx: MutableGameContext) void {
        for (keys) |key| {
            ctx.renderer.input_manager.registerKey(key);
        }
    }

    pub fn onExit(_: *@This(), ctx: MutableGameContext) void {
        for (keys) |key| {
            ctx.renderer.input_manager.unregisterKey(key);
        }
    }

    pub fn shouldTransition(_: *const @This()) bool {
        return true;
    }

    pub fn update(self: *@This(), dt: f32, input: *Input, ctx: MutableGameContext) void {
        _ = self;
        _ = dt;
        _ = input;
        _ = ctx;
    }
    pub fn draw(self: *const @This(), ctx: GameContext) void {
        _ = self;
        _ = ctx;
    }

    fn drawFormationEnemies(self: *const @This()) void {
        const tex = self.renderer.asset_manager.getAsset(Texture, "sprites") orelse return;

        var row: u32 = 0;
        while (row < self.formation_grid.rows) : (row += 1) {
            var col: u32 = 0;
            while (col < self.formation_grid.cols) : (col += 1) {
                // Check if there's an enemy at this position
                const maybe_sprite_type = EnemyFormation[row][col];
                if (maybe_sprite_type == null) continue;

                const sprite_type = maybe_sprite_type.?;

                // Get normalized position (0.0-1.0)
                const norm_pos = self.formation_grid.getPosition(col, row);

                // ✅ Convert to screen coordinates
                const screen_pos = self.renderer.normToRender(norm_pos);

                const sprite = self.sprite_atlas.getSprite(sprite_type);
                if (sprite.idle_count == 0) continue;

                const idx = self.formation_idle_frame_index % sprite.idle_count;
                const frame = sprite.idle_frames[idx];

                self.renderer.drawSprite(tex, frame, screen_pos, Color.white);
            }
        }
    }

    pub fn drawDebug(self: *const @This(), ctx: anytype) void {
        _ = self;
        ctx.renderer.drawText("Playing Mode", .{ .x = 10, .y = 10 }, 24, Color.white, null);
    }
};
