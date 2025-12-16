const c = @import("constants.zig");

pub const GameState = struct {
    parallax_phase: f32 = 0.0,
    credits: u32 = 0,
    num_players: u8 = 0,
    current_player: u8 = 0,
    current_stage: u8 = 1,
    p1_lives: u8 = c.NUM_LIVES,
    p2_lives: u8 = c.NUM_LIVES,
    p1_score: u32 = 0,
    p2_score: u32 = 0,
    active: bool = false,

    pub fn init() @This() {
        return .{};
    }

    pub fn reset(self: *@This()) void {
        self.* = .{};
    }

    pub fn startGame(self: *@This(), num_players: u8) void {
        self.active = true;
        self.current_player = 1;
        self.num_players = num_players;
        self.current_stage = 1;
    }
};
