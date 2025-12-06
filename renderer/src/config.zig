const Color = @import("types.zig").Color;

pub const RenderConfig = struct {
    initial_width: i32 = 1280,
    initial_height: i32 = 720,
    game_width: f32 = 224,
    game_height: f32 = 288,
    title: [:0]const u8 = "Application",
    margin_percent: f32 = 0.1,
    target_fps: i32 = 60,
    show_fps: bool = true,
    show_viewport_border: bool = true,
    letterbox_color: Color = Color.dark_gray,
    viewport_border: Color = Color.green,
};
