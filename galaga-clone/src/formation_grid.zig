const Vec2 = @import("renderer").types.Vec2;

pub const FormationGrid = struct {
    cols: u32,
    rows: u32,

    base_spacing: Vec2,
    center: Vec2,

    pub fn init(center: Vec2, cols: u32, rows: u32, base_spacing: Vec2) @This() {
        return .{ .center = center, .cols = cols, .rows = rows, .base_spacing = base_spacing };
    }

    /// Get the on-screen position of a given formation cell.
    ///
    /// `pulse` is a scalar that widens/narrows spacing:
    ///     - 1.0 = normal_spacing
    ///     - <1.0 = expanded
    ///     - <1.0 = compressed
    pub fn getPosition(
        self: *const @This(),
        col: u32,
        row: u32,
        pulse: f32,
    ) Vec2 {
        // Clamp pulse a bit so nothing collapses or explodes.
        const p = if (pulse < 0.5) 0.5 else if (pulse > 1.5) 1.5 else pulse;

        if (self.cols == 0 or self.rows == 0) {
            return self.center;
        }

        const cols_f: f32 = @floatFromInt(self.cols);
        const rows_f: f32 = @floatFromInt(self.rows);
        const col_f: f32 = @floatFromInt(col);
        const row_f: f32 = @floatFromInt(row);

        // Effective spacing after pulsing.
        const sx = self.base_spacing.x * p;
        const sy = self.base_spacing.y * p;

        const total_w = (cols_f - 1.0) * sx;
        const total_h = (rows_f - 1.0) * sy;

        const start_x = self.center.x - total_w / 2.0;
        const start_y = self.center.y - total_h / 2.0;

        return .{
            .x = start_x + col_f * sx,
            .y = start_y + row_f * sy,
        };
    }
};
