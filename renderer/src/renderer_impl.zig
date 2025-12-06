const rl = @import("raylib");
const std = @import("std");

const types = @import("types.zig");
const InputManager = @import("input_manager.zig").InputManager;
const Viewport = @import("viewport.zig").Viewport;
const MouseButton = types.MouseButton;
const Key = types.Key;
const Input = types.Input;
const Color = types.Color;
const Vec2 = types.Vec2;
const RendererConfig = @import("config.zig").RenderConfig;

pub const Renderer = struct {
    viewport: Viewport,
    last_width: i32,
    last_height: i32,
    input_manager: InputManager,
    config: RendererConfig,
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator, config: RendererConfig) @This() {
        rl.setTraceLogLevel(rl.TraceLogLevel.none);
        rl.setConfigFlags(rl.ConfigFlags{ .window_resizable = true });
        rl.initWindow(config.initial_width, config.initial_height, config.title);
        rl.setTargetFPS(config.target_fps);

        const width = rl.getScreenWidth();
        const height = rl.getScreenHeight();

        var input_manager = InputManager.init(allocator);
        input_manager.registerKey(Key.f11);

        return .{
            .viewport = Viewport.fromScreenSize(width, height, config.game_width, config.game_height, config.margin_percent),
            .last_width = width,
            .last_height = height,
            .input_manager = input_manager,
            .config = config,
            .allocator = allocator,
        };
    }

    pub fn registerInput(self: *@This(), register_fn: fn (*InputManager) void) void {
        register_fn(&self.input_manager);
    }

    pub fn deinit(self: *@This()) void {
        self.input_manager.deinit();
        rl.closeWindow();
    }

    pub fn shouldQuit(_: *const @This()) bool {
        return rl.windowShouldClose();
    }

    pub fn begin(self: *@This()) void {
        const current_width = rl.getScreenWidth();
        const current_height = rl.getScreenHeight();

        if (current_width != self.last_width or current_height != self.last_height) {
            self.viewport = Viewport.fromScreenSize(current_width, current_height, self.config.game_width, self.config.game_height, self.config.margin_percent);
            self.last_width = current_width;
            self.last_height = current_height;
        }

        rl.beginDrawing();
        rl.clearBackground(self.config.letterbox_color);
        rl.drawRectangleRec(self.viewport.rect, rl.Color.black);
        if (self.config.show_viewport_border) {
            rl.drawRectangleLinesEx(self.viewport.rect, 2.0, self.config.viewport_border);
        }
        if (self.config.show_fps) {
            rl.drawFPS(current_width - 100, 10);
        }
    }

    pub fn end(_: *const @This()) void {
        rl.endDrawing();
    }

    pub fn getDelta(_: *const @This()) f32 {
        return rl.getFrameTime();
    }

    pub fn getInput(self: *const @This()) Input {
        return self.input_manager.poll();
    }

    pub fn handleGlobalInput(_: *const @This(), input: Input) void {
        if (input.isKeyPressed(Key.f11)) {
            rl.toggleBorderlessWindowed();
        }
    }

    pub fn drawCircle(_: *const @This(), center: Vec2, radius: f32, color: Color) void {
        rl.drawCircleV(center, radius, color);
    }

    pub fn drawLine(
        _: *const @This(),
        startPoint: Vec2,
        endPoint: Vec2,
        color: Color,
    ) void {
        rl.drawLineV(startPoint, endPoint, color);
    }

    pub fn drawText(_: *const @This(), text: [:0]const u8, pos: Vec2, font_size: i32, color: Color) void {
        rl.drawText(text, @intFromFloat(pos.x), @intFromFloat(pos.y), font_size, color);
    }
};
