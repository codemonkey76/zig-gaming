const rl = @import("raylib");
const Vec2 = @import("types.zig").Vec2;
const Font = @import("types.zig").Font;

pub const TextGrid = struct {
    cols: u32,
    rows: u32,
    char_width: f32,
    char_height: f32,
    line_height: f32,
    viewport_width: f32,
    viewport_height: f32,
    margin_x: f32,
    margin_y: f32,
    font_size: i32,

    pub fn init(
        viewport_width: f32,
        viewport_height: f32,
        font: Font,
        font_size: i32,
    ) TextGrid {
        const sample_text = "M";
        const text_size = rl.measureTextEx(font, sample_text, @as(f32, @floatFromInt(font_size)), 1.0);

        const char_width = text_size.x;
        const char_height = text_size.y;

        const line_spacing: f32 = 1.025;
        const line_height = char_height * line_spacing;

        const margin_x = char_width * 0.05;
        const margin_y = char_height * 0.05;

        const usable_w = viewport_width - margin_x * 2;
        const usable_h = viewport_height - margin_y * 2;

        return .{
            .cols = @intFromFloat(usable_w / char_width),
            .rows = @intFromFloat(usable_h / line_height),
            .char_width = char_width,
            .char_height = char_height,
            .line_height = line_height,
            .viewport_width = viewport_width,
            .viewport_height = viewport_height,
            .margin_x = margin_x,
            .margin_y = margin_y,
            .font_size = font_size,
        };
    }

    pub fn getPosition(self: *const @This(), col: u32, row: u32) Vec2 {
        return .{
            .x = self.margin_x + @as(f32, @floatFromInt(col)) * self.char_width,
            .y = self.margin_y + @as(f32, @floatFromInt(row)) * self.line_height,
        };
    }

    pub fn getCenteredPosition(self: *const @This(), text: [:0]const u8, row: u32) Vec2 {
        const text_width = @as(f32, @floatFromInt(text.len)) * self.char_width;
        const x = (self.viewport_width - text_width) / 2.0;

        return .{
            .x = x,
            .y = self.margin_y + @as(f32, @floatFromInt(row)) * self.line_height,
        };
    }

    pub fn getRightAlignedPosition(
        self: *const @This(),
        text: [:0]const u8,
        row: u32,
    ) Vec2 {
        const text_cols: u32 = @intCast(text.len);
        const start_col: u32 = if (text_cols >= self.cols)
            0
        else
            self.cols - text_cols;

        return self.getPosition(start_col, row);
    }

    pub fn getBottomRow(self: *const @This(), rows_from_bottom: u32) u32 {
        if (self.rows == 0) return 0;
        const max_row = self.rows - 1;
        return if (rows_from_bottom > max_row)
            0
        else
            max_row - rows_from_bottom;
    }

    pub fn getBottomPosition(
        self: *const @This(),
        col: u32,
        rows_from_bottom: u32,
    ) Vec2 {
        const row = self.getBottomRow(rows_from_bottom);
        return self.getPosition(col, row);
    }

    pub fn getBottomCenteredPosition(
        self: *const @This(),
        text: [:0]const u8,
        rows_from_bottom: u32,
    ) Vec2 {
        const row = self.getBottomRow(rows_from_bottom);
        return self.getCenteredPosition(text, row);
    }

    pub fn getBottomRightAlignedPosition(
        self: *const @This(),
        text: [:0]const u8,
        rows_from_bottom: u32,
    ) Vec2 {
        const row = self.getBottomRow(rows_from_bottom);
        return self.getRightAlignedPosition(text, row);
    }
};
