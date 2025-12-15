# Arcade Engine Usage Guide

## Basic Setup
```zig
const std = @import("std");
const engine = @import("arcade_engine");

const Window = engine.core.Window;
const WindowConfig = engine.core.WindowConfig;
const Renderer = engine.core.Renderer;
const InputManager = engine.input.InputManager;
const AssetManager = engine.core.AssetManager;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // 1. Create window
    var window = try Window.init(.{
        .width = 1280,
        .height = 720,
        .title = "My Game",
        .game_width = 224,
        .game_height = 288,
        .ssaa_scale = 2.0,
        .target_fps = 60,
    });
    defer window.deinit();

    // 2. Create renderer
    const renderer = Renderer.init(
        window.render_width,
        window.render_height,
        window.config.ssaa_scale,
    );

    // 3. Create input manager
    var input_manager = InputManager.init(allocator);
    defer input_manager.deinit();
    input_manager.registerKey(.space);
    input_manager.registerMouseButton(.left);

    // 4. Create asset manager
    var assets = AssetManager.init(allocator);
    defer assets.deinit();
    try assets.loadAsset(engine.types.Texture, "sprite", "assets/sprite.png");

    // Game loop
    while (!window.shouldClose()) {
        const dt = window.getDelta();
        const input = input_manager.poll();

        // Update game logic
        if (input.isKeyPressed(.space)) {
            // Handle input
        }

        // Render
        window.beginFrame();
        
        renderer.drawCircle(.{ .x = 100, .y = 100 }, 10, engine.types.Color.red);
        renderer.drawText("Hello!", .{ .x = 50, .y = 50 }, 20, engine.types.Color.white, null);
        
        if (assets.getAsset(engine.types.Texture, "sprite")) |texture| {
            renderer.drawSprite(
                texture,
                .{ .x = 0, .y = 0, .width = 16, .height = 16 },
                .{ .x = 200, .y = 200 },
                engine.types.Color.white,
            );
        }
        
        window.endFrame();
    }
}
```

## Component Overview

### Window (`engine.core.Window`)
- Manages the OS window
- Handles render target (SSAA)
- Manages viewport and resizing
- Controls frame timing

**Key methods:**
- `init(config)` - Create window
- `deinit()` - Clean up
- `shouldClose()` - Check if window should close
- `getDelta()` - Get frame delta time
- `beginFrame()` - Start rendering
- `endFrame()` - Finish rendering and present
- `getViewport()` - Get current viewport

### Renderer (`engine.core.Renderer`)
- Pure drawing operations
- No state management
- Coordinate transformations

**Key methods:**
- `init(width, height, scale)` - Create renderer
- `drawCircle(center, radius, color)` - Draw circle
- `drawLine(start, end, color)` - Draw line
- `drawText(text, pos, size, color, font)` - Draw text
- `drawSprite(texture, src, center, tint)` - Draw sprite
- `normToRender(norm)` - Convert normalized coords to render coords

### InputManager (`engine.input.InputManager`)
- Keyboard and mouse input
- Must register keys/buttons before use

**Key methods:**
- `init(allocator)` - Create input manager
- `deinit()` - Clean up
- `registerKey(key)` - Register a keyboard key
- `registerMouseButton(button)` - Register a mouse button
- `poll()` - Get current input state

### AssetManager (`engine.core.AssetManager`)
- Load and manage textures, sounds, fonts
- String-based lookups

**Key methods:**
- `init(allocator)` - Create asset manager
- `deinit()` - Clean up
- `loadAsset(Type, name, path)` - Load an asset
- `getAsset(Type, name)` - Get loaded asset

### Viewport (`engine.core.Viewport`)
- Coordinate transformations
- Managed automatically by Window

**Key methods:**
- `toNormalized(screen_pos)` - Screen to normalized coords
- `toScreen(norm_pos)` - Normalized to screen coords
- `contains(screen_pos)` - Check if point is in viewport

## Advanced Features

### Sprite System
```zig
const SpriteType = enum { player, enemy };
const SpriteAtlas = engine.graphics.SpriteAtlas(SpriteType);

var atlas = SpriteAtlas.init();
const player_sprite = try engine.graphics.Sprite.init(
    &[_]engine.graphics.SpriteFrame{
        .{ .x = 0, .y = 0, .width = 16, .height = 16 },
    },
    &[_]engine.graphics.SpriteFrame{},
);
atlas.set(.player, player_sprite);
```

### Path System
```zig
var registry = engine.level.PathRegistry.init(allocator);
defer registry.deinit();
try registry.loadFromDirectory("assets/paths");

if (registry.getPath("swoop_left")) |path| {
    const pos = path.getPosition(0.5); // Get position at 50% along path
}
```

### Formation Grid
```zig
var formation = engine.spatial.FormationGrid.init(
    .{ .x = 0.5, .y = 0.3 },  // center
    10,  // cols
    6,   // rows
    .{ .x = 0.05, .y = 0.05 },  // spacing
    60,  // total ships
    .{},  // config
);

formation.update(dt);
const enemy_pos = formation.getPosition(col, row);
```

### Text Grid
```zig
const text_grid = engine.spatial.TextGrid.init(
    viewport_width,
    viewport_height,
    font,
    16,
);

const pos = text_grid.getCenteredPosition("GAME OVER", 10);
renderer.drawText("GAME OVER", pos, 16, Color.white, font);
```
