const std = @import("std");
const rl = @import("raylib");

const Config = @import("config.zig").Config;
const Input = @import("input.zig").Input;
const AssetManager = @import("assets.zig").AssetManager;
const Window = @import("window.zig").Window;

pub const Context = struct {
    allocator: std.mem.Allocator,

    input: Input,
    assets: AssetManager,
    window: Window,

    const Self = @This();

    pub fn init(allocator: std.mem.Allocator, cfg: Config) !Self {
        return .{
            .allocator = allocator,
            .input = Input.init(),
            .assets = try AssetManager.init(allocator, cfg.asset_root),
            .window = Window.init(cfg),
        };
    }

    pub fn deinit(self: *Self) void {
        self.assets.deinit();
        self.window.deinit();
    }

    pub fn shouldQuit(self: *const Self) bool {
        return self.window.should_close;
    }

    pub fn tick(self: *Self) f32 {
        self.window.update();
        return rl.getFrameTime();
    }

    pub fn beginFrame(self: *Self) void {
        _ = self;
        rl.beginDrawing();
        rl.clearBackground(rl.Color.black);
    }

    pub fn endFrame(self: *Self) void {
        _ = self;
        rl.endDrawing();
    }
};
