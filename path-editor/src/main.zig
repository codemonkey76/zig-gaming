const std = @import("std");
const engine = @import("arcade_engine");

const Window = engine.core.Window;
const Renderer = engine.core.Renderer;
const InputManager = engine.input.InputManager;
const AssetManager = engine.core.AssetManager;
const PathRegistry = engine.level.PathRegistry;

// Import our modules
const AppState = @import("editor/app_state.zig").AppState;
const PathListUI = @import("ui/path_list.zig").PathListUI;
const SaveDialog = @import("ui/save_dialog.zig").SaveDialog;
const InputHandler = @import("editor/input_handler.zig").InputHandler;
const RenderSystem = @import("editor/render_system.zig").RenderSystem;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Initialize window
    var window = try Window.init(.{
        .width = 1600,
        .height = 900,
        .title = "Path Editor",
        .game_width = 320,
        .game_height = 240,
        .ssaa_scale = 2.0,
        .target_fps = 60,
        .margin_percent = 0.05,
    });
    defer window.deinit();

    const renderer = Renderer.init(
        window.render_width,
        window.render_height,
        window.config.ssaa_scale,
    );

    // Initialize input manager
    var input_manager = InputManager.init(allocator);
    defer input_manager.deinit();
    registerInputKeys(&input_manager);

    // Load assets - font is required for UI
    var assets = AssetManager.init(allocator);
    defer assets.deinit();

    // Load font (create assets/fonts/default.ttf or use any .ttf file)
    assets.loadFont("main", "assets/fonts/arcade.ttf", 16) catch {
        std.debug.print("\n=== ERROR: Could not load font ===\n", .{});
        std.debug.print("Please create the assets/fonts/ directory and add a .ttf font file.\n", .{});
        std.debug.print("You can download a free font like:\n", .{});
        std.debug.print("  - Liberation Sans: https://github.com/liberationfonts/liberation-fonts\n", .{});
        std.debug.print("  - Roboto: https://fonts.google.com/specimen/Roboto\n", .{});
        std.debug.print("\nExample commands:\n", .{});
        std.debug.print("  mkdir -p assets/fonts\n", .{});
        std.debug.print("  # Copy any .ttf font to assets/fonts/default.ttf\n\n", .{});
        return error.FontNotLoaded;
    };

    const font = assets.getAsset(engine.types.Font, "main") orelse return error.FontNotLoaded;

    // Initialize path registry
    var registry = PathRegistry.init(allocator);
    defer registry.deinit();
    try registry.loadFromDirectory("assets/paths");

    // Initialize application state
    var app_state = AppState.init(allocator);
    defer app_state.deinit();

    var path_list = PathListUI.init();
    var save_dialog = SaveDialog.init();

    // Main loop
    while (!window.shouldClose()) {
        const dt = window.getDelta();
        const input = input_manager.poll();
        const viewport = window.getViewport();
        const window_size = window.getSize();

        // Update UI layout based on current window/viewport size
        path_list.updateLayout(viewport, window_size.width, window_size.height);

        // Get path list
        const path_names = try registry.listPaths(allocator);
        defer allocator.free(path_names);

        // Update path list
        path_list.handleInput(input, path_names.len);

        // Handle global input
        try InputHandler.handleGlobalInput(
            &app_state,
            input,
            &path_list,
            &save_dialog,
            &registry,
            path_names,
        );

        // Handle editor-specific input
        if (app_state.isEditing()) {
            try app_state.path_editor.handleInput(input, viewport, &renderer);
        }

        // Render
        window.beginFrame();
        try RenderSystem.render(
            allocator,
            &app_state,
            &renderer,
            &path_list,
            &save_dialog,
            &registry,
            path_names,
            font,
        );
        window.endFrame();

        _ = dt; // unused for now
    }
}

fn registerInputKeys(input_manager: *InputManager) void {
    input_manager.registerKey(.space);
    input_manager.registerKey(.n);
    input_manager.registerKey(.s);
    input_manager.registerKey(.delete);
    input_manager.registerKey(.escape);
    input_manager.registerKey(.enter);
    input_manager.registerKey(.backspace);

    // Register all letter keys for text input
    const letter_keys = "abcdefghijklmnopqrstuvwxyz";
    inline for (letter_keys) |c| {
        const key_enum = @field(engine.types.Key, &[_]u8{c});
        input_manager.registerKey(key_enum);
    }

    // Register number keys
    input_manager.registerKey(.zero);
    input_manager.registerKey(.one);
    input_manager.registerKey(.two);
    input_manager.registerKey(.three);
    input_manager.registerKey(.four);
    input_manager.registerKey(.five);
    input_manager.registerKey(.six);
    input_manager.registerKey(.seven);
    input_manager.registerKey(.eight);
    input_manager.registerKey(.nine);

    // Register special characters for path names
    input_manager.registerKey(.minus);
    input_manager.registerKey(.equal); // underscore when shift is pressed

    input_manager.registerMouseButton(.left);
    input_manager.registerMouseButton(.right);
}
