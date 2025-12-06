const Vec2 = @import("types.zig").Vec2;
const Rect = @import("types.zig").Rect;

pub const Viewport = struct {
    rect: Rect,

    pub fn init(rect: Rect) @This() {
        return .{ .rect = rect };
    }

    pub fn fromScreenSize(
        screen_width: i32,
        screen_height: i32,
        game_width: f32,
        game_height: f32,
        margin_percent: f32,
    ) @This() {
        const screen_w: f32 = @floatFromInt(screen_width);
        const screen_h: f32 = @floatFromInt(screen_height);

        const margin_pixels = screen_h * margin_percent;
        const available_h = screen_h - (2.0 * margin_pixels);

        const sx = screen_w / game_width;
        const sy = available_h / game_height;
        const scale = if (sx < sy) sx else sy;

        const viewport_w = game_width * scale;
        const viewport_h = game_height * scale;

        const x = (screen_w - viewport_w) / 2.0;
        const y = margin_pixels + (available_h - viewport_h) / 2.0;

        return .{
            .rect = .{
                .x = x,
                .y = y,
                .width = viewport_w,
                .height = viewport_h,
            },
        };
    }

    pub fn toNormalized(self: *const @This(), screen_pos: Vec2) Vec2 {
        return .{
            .x = (screen_pos.x - self.rect.x) / self.rect.width,
            .y = (screen_pos.y - self.rect.y) / self.rect.height,
        };
    }

    pub fn toScreen(self: *const @This(), norm_pos: Vec2) Vec2 {
        return .{
            .x = self.rect.x + norm_pos.x * self.rect.width,
            .y = self.rect.y + norm_pos.y * self.rect.height,
        };
    }

    pub fn contains(self: *const @This(), screen_pos: Vec2) bool {
        return screen_pos.x >= self.rect.x and
            screen_pos.x <= self.rect.x + self.rect.width and
            screen_pos.y >= self.rect.y and
            screen_pos.y <= self.rect.y + self.rect.height;
    }

    pub fn width(self: *const @This()) f32 {
        return self.rect.width;
    }

    pub fn height(self: *const @This()) f32 {
        return self.rect.height;
    }

    pub fn toRect(self: @This()) Rect {
        return self.rect;
    }
};
