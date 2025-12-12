const std = @import("std");
const engine = @import("arcade_engine");

const Viewport = engine.core.Viewport;
const Vec2 = engine.types.Vec2;
const Color = engine.types.Color;
const Rect = engine.types.Rect;
const Input = engine.types.Input;
const Font = engine.types.Font;
const Renderer = engine.core.Renderer;

pub const PathListUI = struct {
    screen_rect: Rect,
    scroll_offset: f32 = 0,
    selected_index: ?usize = null,
    item_height: f32 = 30,
    padding: f32 = 10,

    pub fn init() PathListUI {
        return .{
            .screen_rect = .{ .x = 0, .y = 0, .width = 250, .height = 600 },
        };
    }

    pub fn updateLayout(self: *PathListUI, viewport: Viewport, screen_width: i32, screen_height: i32) void {
        const vp_rect = viewport.toRect();

        // Place list on the left side of the screen, outside viewport
        const list_width: f32 = 250;
        const margin: f32 = 20;

        // If there's space on the left
        if (vp_rect.x > list_width + margin * 2) {
            self.screen_rect = .{
                .x = margin,
                .y = margin,
                .width = list_width,
                .height = @as(f32, @floatFromInt(screen_height)) - margin * 2,
            };
        } else {
            // Otherwise place it on the right
            const screen_w: f32 = @floatFromInt(screen_width);
            const screen_h: f32 = @floatFromInt(screen_height);
            const right_space = screen_w - (vp_rect.x + vp_rect.width);

            if (right_space > list_width + margin * 2) {
                self.screen_rect = .{
                    .x = vp_rect.x + vp_rect.width + margin,
                    .y = margin,
                    .width = list_width,
                    .height = screen_h - margin * 2,
                };
            } else {
                // Fallback: place it at the top
                self.screen_rect = .{
                    .x = margin,
                    .y = margin,
                    .width = list_width,
                    .height = 200,
                };
            }
        }
    }

    pub fn handleInput(self: *PathListUI, input: Input, path_count: usize) void {
        const mouse_x = input.mouse_pos.x;
        const mouse_y = input.mouse_pos.y;

        // Check if mouse is in list area (screen coordinates)
        if (mouse_x < self.screen_rect.x or mouse_x > self.screen_rect.x + self.screen_rect.width or
            mouse_y < self.screen_rect.y or mouse_y > self.screen_rect.y + self.screen_rect.height)
        {
            return;
        }

        // Handle click
        if (input.isMouseButtonPressed(.left)) {
            const relative_y = mouse_y - self.screen_rect.y - self.padding - 25; // Account for title
            const clicked_index = @as(usize, @intFromFloat((relative_y + self.scroll_offset) / self.item_height));

            if (clicked_index < path_count) {
                self.selected_index = clicked_index;
            }
        }
    }

    pub fn draw(
        self: *const PathListUI,
        path_names: [][]const u8,
        font: Font,
    ) void {
        // Background - using screen coordinates directly
        Renderer.drawRectangleRec(self.screen_rect, Color{ .r = 40, .g = 40, .b = 50, .a = 255 });

        // Title
        const title_pos = Vec2{ .x = self.screen_rect.x + 10, .y = self.screen_rect.y + 5 };
        Renderer.drawText("Paths", title_pos, 16, Color.white, font);

        // Draw items (start below title)
        const list_start_y = 30;
        var y_offset = list_start_y + self.padding - self.scroll_offset;
        for (path_names, 0..) |name, i| {
            const draw_y = self.screen_rect.y + y_offset;

            if (draw_y > self.screen_rect.y + self.screen_rect.height) break;
            if (draw_y + self.item_height < self.screen_rect.y + list_start_y) {
                y_offset += self.item_height;
                continue;
            }

            const is_selected = if (self.selected_index) |sel| sel == i else false;

            // Item background
            const item_rect = Rect{
                .x = self.screen_rect.x + 5,
                .y = draw_y,
                .width = self.screen_rect.width - 10,
                .height = self.item_height - 5,
            };

            Renderer.drawRectangleRec(
                item_rect,
                if (is_selected) Color{ .r = 60, .g = 120, .b = 200, .a = 255 } else Color{ .r = 50, .g = 50, .b = 60, .a = 255 },
            );

            // Text
            const text_pos = Vec2{ .x = self.screen_rect.x + 10, .y = draw_y + 8 };
            var name_buf: [256:0]u8 = undefined;
            const name_z = std.fmt.bufPrintZ(&name_buf, "{s}", .{name}) catch "???";
            Renderer.drawText(name_z, text_pos, 12, Color.white, font);

            y_offset += self.item_height;
        }

        // Border
        Renderer.drawRectangleLines(self.screen_rect, 2, Color.light_gray);
    }
};
