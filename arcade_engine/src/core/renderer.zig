const rl = @import("raylib");
const std = @import("std");

const types = @import("../types.zig");
const Color = types.Color;
const Vec2 = types.Vec2;
const Font = types.Font;

pub const Renderer = struct {
    render_width: f32,
    render_height: f32,
    ssaa_scale: f32,

    pub fn init(render_width: f32, render_height: f32, ssaa_scale: f32) Renderer {
        return .{
            .render_width = render_width,
            .render_height = render_height,
            .ssaa_scale = ssaa_scale,
        };
    }

    pub fn drawCircle(center: Vec2, radius: f32, color: Color) void {
        rl.drawCircleV(center, radius, color);
    }

    pub fn drawLine(p1: Vec2, p2: Vec2, color: Color) void {
        rl.drawLineV(p1, p2, color);
    }

    pub fn drawText(text: [:0]const u8, pos: Vec2, font_size: i32, color: Color, font: ?Font) void {
        if (font) |f| {
            rl.drawTextEx(f, text, .{ .x = pos.x, .y = pos.y }, @floatFromInt(font_size), 1.0, color);
        } else {
            rl.drawText(text, @intFromFloat(pos.x), @intFromFloat(pos.y), font_size, color);
        }
    }

    pub fn drawSprite(scale: f32, texture: rl.Texture, src: rl.Rectangle, center: Vec2, tint: Color) void {
        const dest_w = src.width * scale;
        const dest_h = src.height * scale;

        const dest = rl.Rectangle{
            .x = center.x - dest_w / 2.0,
            .y = center.y - dest_h / 2.0,
            .width = dest_w,
            .height = dest_h,
        };

        const origin = rl.Vector2{ .x = 0, .y = 0 };

        rl.drawTexturePro(texture, src, dest, origin, 0.0, tint);
    }

    pub fn drawRectangle(
        posX: i32,
        posY: i32,
        width: i32,
        height: i32,
        color: Color,
    ) void {
        rl.drawRectangle(posX, posY, width, height, color);
    }

    pub fn drawRectangleRec(
        rect: types.Rect,
        color: Color,
    ) void {
        rl.drawRectangleRec(rect, color);
    }

    pub fn drawRectangleLines(
        rect: types.Rect,
        thickness: f32,
        color: Color,
    ) void {
        rl.drawRectangleLinesEx(rect, thickness, color);
    }

    pub fn normToRender(self: *const Renderer, norm: Vec2) Vec2 {
        return .{
            .x = norm.x * self.render_width,
            .y = norm.y * self.render_height,
        };
    }
};
