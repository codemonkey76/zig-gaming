const std = @import("std");
const Input = @import("renderer").types.Input;
const Color = @import("renderer").types.Color;
const Vec2 = @import("renderer").types.Vec2;
const TextGrid = @import("renderer").TextGrid;
const Texture = @import("renderer").Texture;
const FormationGrid = @import("renderer").FormationGrid;
const SpriteType = @import("../sprite.zig").SpriteType;

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
    formation_grid: FormationGrid,

    pub fn init(allocator: std.mem.Allocator, renderer: anytype) @This() {
        const sprite_size: f32 = 16.0 * renderer.config.ssaa_scale;
        const sprite_size_norm = sprite_size / renderer.render_width;

        const spacing_x_norm = sprite_size_norm * 1.2;
        const spacing_y_norm = (sprite_size / renderer.render_height) * 1.00;

        const formation_center = Vec2{
            .x = 0.5, // Center horizontally (50%)
            .y = 0.30, // 30% down from top
        };

        const formation_spacing = Vec2{
            .x = spacing_x_norm,
            .y = spacing_y_norm,
        };
        _ = allocator;
        return .{
            .formation_grid = FormationGrid.init(formation_center, 10, 6, formation_spacing, 40),
        };
    }

    pub fn deinit(self: *@This()) void {
        _ = self;
    }

    pub fn update(self: *@This(), dt: f32, input: Input) void {
        _ = self;
        _ = dt;
        _ = input;
    }
    pub fn draw(self: *const @This(), ctx: anytype) void {
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
