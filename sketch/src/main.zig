const std = @import("std");
const builtin = @import("builtin");
const sketch = @import("sketch");
const rl = @import("raylib");
const config = sketch.config;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    const config_path = try config.getConfigPath(alloc, "Sketch");
    defer alloc.free(config_path);

    config.writeDefaultConfig(config_path, "") catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    const cfg = try config.read(alloc, config_path);
    defer cfg.deinit(alloc);

    rl.setConfigFlags(.{ .window_resizable = true });
    if (builtin.mode == .Debug) {
        rl.setTraceLogLevel(.info);
    } else {
        rl.setTraceLogLevel(.none);
    }

    rl.initWindow(900.0, 600.0, "Sketch");

    const dpi_scale = rl.getWindowScaleDPI();

    const scaled_w = @as(i32, @intFromFloat(900.0 * dpi_scale.x));
    const scaled_h = @as(i32, @intFromFloat(600.0 * dpi_scale.y));
    rl.setWindowSize(scaled_w, scaled_h);

    const min_w = @as(i32, @intFromFloat(500.0 * dpi_scale.x));
    const min_h = @as(i32, @intFromFloat(400.0 * dpi_scale.y));
    rl.setWindowMinSize(min_w, min_h);
    defer rl.closeWindow();

    std.debug.print("DPI Scale: {d}x{d}\n", .{ dpi_scale.x, dpi_scale.y });
    const font_size = @as(i32, @intFromFloat(18.0 * dpi_scale.x));

    rl.setTargetFPS(60);

    const font_data = @embedFile("assets/fonts/inter/Inter_18pt-Regular.ttf");
    const font = try rl.loadFontFromMemory(".ttf", font_data, font_size, null);
    // const font = try rl.loadFontEx("assets/fonts/inter/Inter_18pt-Regular.ttf", 18, null);
    rl.setTextureFilter(font.texture, rl.TextureFilter.point);

    var model = try sketch.models.AppModel.init(alloc, font, &cfg);
    defer model.deinit();

    var queue = std.ArrayList(sketch.models.AppMsg).empty;
    defer queue.deinit(alloc);

    while (model.running and !rl.windowShouldClose()) {
        queue.clearRetainingCapacity();
        try pollInput(alloc, &queue);
        try queue.append(alloc, .{ .Tick = rl.getFrameTime() });

        for (queue.items) |msg| {
            const cmd = model.update(msg);
            _ = cmd;
        }

        try model.view();
    }
}

fn pollInput(alloc: std.mem.Allocator, msgs: *std.ArrayList(sketch.models.AppMsg)) !void {
    const mx = @as(f32, @floatFromInt(rl.getMouseX()));
    const my = @as(f32, @floatFromInt(rl.getMouseY()));
    try msgs.append(alloc, .{ .MoveMouse = .{ .x = mx, .y = my } });

    if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
        try msgs.append(alloc, .{ .MouseDown = .{ .button = rl.MouseButton.left } });
    }
    if (rl.isMouseButtonPressed(rl.MouseButton.right)) {
        try msgs.append(alloc, .{ .MouseDown = .{ .button = rl.MouseButton.right } });
    }
    if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
        try msgs.append(alloc, .{ .MouseUp = .{ .button = rl.MouseButton.left } });
    }
    if (rl.isMouseButtonReleased(rl.MouseButton.right)) {
        try msgs.append(alloc, .{ .MouseUp = .{ .button = rl.MouseButton.right } });
    }

    if (rl.isKeyPressed(rl.KeyboardKey.q)) {
        try msgs.append(alloc, .{ .KeyDown = .{ .key = rl.KeyboardKey.q } });
    }

    if (rl.isKeyPressed(rl.KeyboardKey.f11)) {
        try msgs.append(alloc, .{ .KeyDown = .{ .key = rl.KeyboardKey.f11 } });
    }
    if (rl.isKeyPressed(rl.KeyboardKey.f3)) {
        try msgs.append(alloc, .{ .KeyDown = .{ .key = rl.KeyboardKey.f3 } });
    }
}
