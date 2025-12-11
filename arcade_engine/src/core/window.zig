const std = @import("std");
const rl = @import("raylib");

const Viewport = @import("viewport.zig").Viewport;
const types = @import("../types.zig");
const Color = types.Color;

pub const WindowConfig = struct {
    width: i32 = 1280,
    height: i32 = 720,
    title: [:0]const u8 = "Game",
    target_fps: i32 = 60,
    resizable: bool = true,
    ssaa_scale: f32 = 2.0,
    game_width: f32 = 224,
    game_height: f32 = 288,
    margin_percent: f32 = 0.1,
    show_fps: bool = true,
    show_viewport_border: bool = true,
    letterbox_color: Color = rl.Color.dark_gray,
    viewport_border: Color = rl.Color.green,
};

pub const Window = struct {
    width: i32,
    height: i32,
    render_target: rl.RenderTexture2D,
    render_width: f32,
    render_height: f32,
    config: WindowConfig,
    viewport: Viewport,
    pub fn init(config: WindowConfig) !Window {
        rl.setTraceLogLevel(rl.TraceLogLevel.none);
        if (config.resizable) {
            rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });
        }
        rl.initWindow(config.width, config.height, config.title);
        rl.setTargetFPS(config.target_fps);

        const width = rl.getScreenWidth();
        const height = rl.getScreenHeight();

        const render_width = config.game_width * config.ssaa_scale;
        const render_height = config.game_height * config.ssaa_scale;
        const render_target = try rl.loadRenderTexture(
            @intFromFloat(render_width),
            @intFromFloat(render_height),
        );

        const viewport = Viewport.fromScreenSize(
            width,
            height,
            config.game_width,
            config.game_height,
            config.margin_percent,
        );

        return .{
            .width = width,
            .height = height,
            .render_target = render_target,
            .render_width = render_width,
            .render_height = render_height,
            .config = config,
            .viewport = viewport,
        };
    }

    pub fn deinit(self: *Window) void {
        rl.unloadRenderTexture(self.render_target);
        rl.closeWindow();
    }

    pub fn shouldClose(_: *const Window) bool {
        return rl.windowShouldClose();
    }

    pub fn getDelta(_: *const Window) f32 {
        return rl.getFrameTime();
    }

    pub fn getSize(self: *const Window) struct { width: i32, height: i32 } {
        return .{ .width = self.width, .height = self.height };
    }

    pub fn update(self: *Window) void {
        const current_width = rl.getScreenWidth();
        const current_height = rl.getScreenHeight();

        if (current_width != self.width or current_height != self.height) {
            self.viewport = Viewport.fromScreenSize(
                current_width,
                current_height,
                self.config.game_width,
                self.config.game_height,
                self.config.margin_percent,
            );
            self.width = current_width;
            self.height = current_height;
        }
    }

    pub fn beginFrame(self: *Window) void {
        self.update();

        rl.beginDrawing();
        rl.clearBackground(self.config.letterbox_color);

        rl.beginTextureMode(self.render_target);
        rl.clearBackground(rl.Color.black);
    }

    pub fn endFrame(self: *const Window) void {
        rl.endTextureMode();

        const source = rl.Rectangle{
            .x = 0,
            .y = 0,
            .width = self.render_width,
            .height = -self.render_height,
        };

        rl.drawTexturePro(
            self.render_target.texture,
            source,
            self.viewport.rect,
            rl.Vector2{ .x = 0, .y = 0 },
            0.0,
            rl.Color.white,
        );

        if (self.config.show_viewport_border) {
            rl.drawRectangleLinesEx(self.viewport.rect, 2.0, self.config.viewport_border);
        }

        if (self.config.show_fps) {
            rl.drawFPS(self.width - 100, 10);
        }

        rl.endDrawing();
    }

    pub fn getViewport(self: *const Window) Viewport {
        return self.viewport;
    }
};
