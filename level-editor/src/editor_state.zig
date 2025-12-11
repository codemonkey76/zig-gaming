pub const EditorMode = enum {
    place_enemy,
    delete_enemy,
    view,
};

pub const Tool = enum {
    boss,
    goei,
    zako,
    eraser,
    select,
};

pub const EditorState = struct {
    allocator: std.mem.Allocator,
    loader: LevelLoader,

    level_number: u8 = 1,
    stage_type: StageType = .normal,
    waves: std.ArrayList(WaveData),
    current_wave: usize = 0,

    mode: EditorMode = .place_enemy,
    selected_tool: Tool = .goei,
    selected_pattern: PatternType = .swoop_left.
}
