pub const Config = struct {
    title: [:0]const u8 = "Game",
    width: u32 = 1280,
    height: u32 = 720,
    target_fps: u32 = 60,

    resizable: bool = true,
    fullscreen: bool = false,
    vsync: bool = true,

    asset_root: []const u8 = "assets",

    audio_enabled: bool = true,
    master_volume: f32 = 1.0,
};
