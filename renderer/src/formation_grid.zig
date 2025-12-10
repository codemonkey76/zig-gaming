const std = @import("std");

const Vec2 = @import("types.zig").Vec2;

pub const FormationMode = enum {
    /// Formation moves side-to-side, stays compact while ships are joining
    sway,

    /// Formation pulses (expands/contracts)
    pulse,
};

pub const FormationConfig = struct {
    sway_speed: f32 = 0.1, // cycles per second
    sway_amplitude: f32 = 0.06,

    pulse_speed: f32 = 0.2,
    pulse_amplitude: f32 = 0.15,
};
pub const FormationGrid = struct {
    cols: u32,
    rows: u32,

    base_spacing: Vec2,
    base_center: Vec2,
    center_offset: f32 = 0.0,

    mode: FormationMode = .sway,

    sway_phase: f32 = 0.0,
    sway_speed: f32 = 0.5,
    sway_amplitude: f32 = 0.05,

    pulse_phase: f32 = 0.0,
    pulse_speed: f32 = 0.5,
    pulse_amplitude: f32 = 0.08,

    ships_in_formation: u32 = 0,
    total_ships: u32,

    pub fn init(
        center: Vec2,
        cols: u32,
        rows: u32,
        base_spacing: Vec2,
        total_ships: u32,
        config: FormationConfig,
    ) @This() {
        return .{
            .cols = cols,
            .rows = rows,
            .base_center = center,
            .base_spacing = base_spacing,
            .total_ships = total_ships,

            .sway_speed = config.sway_speed,
            .sway_amplitude = config.sway_amplitude,
            .pulse_speed = config.pulse_speed,
            .pulse_amplitude = config.pulse_amplitude,
        };
    }

    pub fn update(self: *@This(), dt: f32) void {
        if (self.mode == .sway) {
            self.sway_phase += dt * (self.sway_speed * 2.0 * std.math.pi);
            const sway_offset = std.math.sin(self.sway_phase) * self.sway_amplitude;
            self.center_offset = sway_offset;
        } else {
            self.center_offset = 0.0;
        }

        if (self.mode == .pulse) {
            self.pulse_phase += dt * (self.pulse_speed * 2.0 * std.math.pi);
        }

        if (self.mode == .sway and self.ships_in_formation >= self.total_ships) {
            self.mode = .pulse;
            self.pulse_phase = 0.0;
            self.center_offset = 0.0;
        }
    }

    pub fn addShip(self: *@This()) void {
        if (self.ships_in_formation < self.total_ships) {
            self.ships_in_formation += 1;
        }
    }

    pub fn reset(self: *@This()) void {
        self.mode = .sway;
        self.ships_in_formation = 0;
        self.sway_phase = 0.0;
        self.pulse_phase = 0.0;
        self.center_offset = 0.0; // ✅ FIXED TYPO
    }

    pub fn getPulseFactor(self: *const @This()) f32 {
        if (self.mode == .sway) {
            return 1.0;
        }

        const base: f32 = 1.0;
        return base + self.pulse_amplitude * std.math.sin(self.pulse_phase);
    }

    pub fn getCurrentCenter(self: *const @This()) Vec2 {
        return Vec2{
            .x = self.base_center.x + self.center_offset,
            .y = self.base_center.y,
        };
    }

    pub fn getPosition(
        self: *const @This(),
        col: u32,
        row: u32,
    ) Vec2 {
        const pulse = self.getPulseFactor();
        const center = self.getCurrentCenter();

        // Clamp pulse a bit so nothing collapses or explodes.
        const p = if (pulse < 0.5) 0.5 else if (pulse > 1.5) 1.5 else pulse;

        if (self.cols == 0 or self.rows == 0) {
            return center;
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

        const start_x = center.x - total_w / 2.0;
        const start_y = center.y - total_h / 2.0;

        return .{
            .x = start_x + col_f * sx,
            .y = start_y + row_f * sy,
        };
    }
};
