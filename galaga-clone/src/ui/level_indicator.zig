const GameContext = @import("../context.zig").GameContext;
const SpriteType = @import("../graphics/sprite.zig").SpriteType;
const engine = @import("arcade_engine");
const Vec2 = engine.types.Vec2;
const Texture = engine.types.Texture;
const Color = engine.types.Color;
const c = @import("../constants.zig");

pub const LevelIndicator = struct {
    current_stage: u32 = 1,

    pub fn init() @This() {
        return .{};
    }

    pub fn setStage(self: *@This(), stage: u32) void {
        self.current_stage = @mod(stage, 255);
    }

    pub fn draw(self: *const @This(), ctx: GameContext) void {
        const markers = LevelMarkers.init(self.current_stage);
        const total_width = ((@as(f32, @floatFromInt(markers.level_1 + markers.level_5)) * c.TILE_SIZE / 2) +
            (@as(f32, @floatFromInt(markers.level_10 + markers.level_20 + markers.level_30 + markers.level_50)) * c.TILE_SIZE)) *
            ctx.renderer.ssaa_scale;

        const total_width_norm = total_width / ctx.renderer.render_width;

        const start_x: f32 = 1.0 - total_width_norm;
        const start_y: f32 = 1.0 - c.TILE_SIZE / ctx.renderer.render_height;

        var x = start_x;
        var i: u32 = 0;
        while (i < markers.level_50) : (i += 1) {
            self.drawLevelMarker(ctx, .level_50, Vec2{ .x = x, .y = start_y });
            x += c.TILE_SIZE * ctx.renderer.ssaa_scale / ctx.renderer.render_width;
        }

        i = 0;
        while (i < markers.level_30) : (i += 1) {
            self.drawLevelMarker(ctx, .level_30, Vec2{ .x = x, .y = start_y });
            x += c.TILE_SIZE * ctx.renderer.ssaa_scale / ctx.renderer.render_width;
        }

        i = 0;
        while (i < markers.level_20) : (i += 1) {
            self.drawLevelMarker(ctx, .level_20, Vec2{ .x = x, .y = start_y });
            x += c.TILE_SIZE * ctx.renderer.ssaa_scale / ctx.renderer.render_width;
        }

        i = 0;
        while (i < markers.level_10) : (i += 1) {
            self.drawLevelMarker(ctx, .level_10, Vec2{ .x = x, .y = start_y });
            x += c.TILE_SIZE * ctx.renderer.ssaa_scale / ctx.renderer.render_width;
        }

        i = 0;
        while (i < markers.level_5) : (i += 1) {
            self.drawLevelMarker(ctx, .level_5, Vec2{ .x = x, .y = start_y });
            x += c.TILE_SIZE * ctx.renderer.ssaa_scale / 2 / ctx.renderer.render_width;
        }

        i = 0;
        while (i < markers.level_1) : (i += 1) {
            self.drawLevelMarker(ctx, .level_1, Vec2{ .x = x, .y = start_y });
            x += c.TILE_SIZE * ctx.renderer.ssaa_scale / 2 / ctx.renderer.render_width;
        }
    }

    fn drawLevelMarker(_: *const @This(), ctx: GameContext, marker: SpriteType, pos: Vec2) void {
        const tex = ctx.assets_manager.getAsset(Texture, "sprites") orelse return;
        const sprite = ctx.sprite_atlas.getSprite(marker);
        if (sprite.idle_count == 0) return;

        const frame = sprite.idle_frames[0];
        const screen_pos = ctx.renderer.normToRender(pos);
        ctx.renderer.drawSprite(tex, frame, screen_pos, Color.white);
    }
};

const LevelMarkers = struct {
    level_50: u32 = 0,
    level_30: u32 = 0,
    level_20: u32 = 0,
    level_10: u32 = 0,
    level_5: u32 = 0,
    level_1: u32 = 0,

    fn init(stage: u32) LevelMarkers {
        var remaining = stage;
        var markers = LevelMarkers{};

        markers.level_50 = @divFloor(remaining, 50);
        remaining = @mod(remaining, 50);

        markers.level_30 = @divFloor(remaining, 30);
        remaining = @mod(remaining, 30);

        markers.level_20 = @divFloor(remaining, 20);
        remaining = @mod(remaining, 20);

        markers.level_10 = @divFloor(remaining, 10);
        remaining = @mod(remaining, 10);

        markers.level_5 = @divFloor(remaining, 5);
        remaining = @mod(remaining, 5);

        markers.level_1 = @divFloor(remaining, 1);

        return markers;
    }
};
