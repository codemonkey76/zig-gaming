// Core systems
pub const core = struct {
    pub const Window = @import("core/window.zig").Window;
    pub const WindowConfig = @import("core/window.zig").WindowConfig;
    pub const AssetManager = @import("core/asset_manager.zig").AssetManager;
    pub const Viewport = @import("core/viewport.zig").Viewport;
    pub const Renderer = @import("core/renderer.zig").Renderer;
};

// Input
pub const input = struct {
    pub const InputManager = @import("input/input_manager.zig").InputManager;
};

// Spatial helpers
pub const spatial = struct {
    pub const FormationGrid = @import("spatial/formation_grid.zig").FormationGrid;
    pub const FormationConfig = @import("spatial/formation_config.zig").FormationConfig;
    pub const TextGrid = @import("spatial/text_grid.zig").TextGrid;
};

// Level system
pub const level = struct {
    pub const PathDefinition = @import("level/path_definition.zig").PathDefinition;
    pub const BezierSegment = @import("level/bezier_segment.zig").BezierSegment;
    pub const PathFormat = @import("level/path_format.zig");
    pub const PathRegistry = @import("level/path_registry.zig").PathRegistry;

    const path_io = @import("level/path_io.zig");
    pub const savePath = path_io.PathIO.savePath;
    pub const loadPath = path_io.PathIO.loadPath;
    pub const LoadedPath = path_io.PathIO.LoadedPath;
};

// Graphics
pub const graphics = struct {
    const sprite = @import("graphics/sprite.zig");
    pub const Sprite = sprite.Sprite;
    pub const SpriteFrame = sprite.SpriteFrame;
    pub const SpriteResult = sprite.SpriteResult;
    pub const Flip = sprite.Flip;
    pub const MAX_IDLE_FRAMES = sprite.MAX_IDLE_FRAMES;
    pub const MAX_ROT_FRAMES = sprite.MAX_ROT_FRAMES;

    pub const SpriteAtlas = @import("graphics/atlas.zig").SpriteAtlas;
};

// Math utilities
pub const math = struct {
    pub const Bezier = @import("math/bezier.zig").Bezier;
};

// Drawing Utilities
pub const drawing = struct {
    pub const drawBezierCurve = @import("drawing/bezier_draw.zig").drawBezierCurve;
    pub const drawControlPolygon = @import("drawing/bezier_draw.zig").drawControlPolygon;
    pub const drawControlPoint = @import("drawing/bezier_draw.zig").drawControlPoint;
};

// Types
pub const types = @import("types.zig");
