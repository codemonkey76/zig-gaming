const std = @import("std");
const rl = @import("raylib");
pub const Texture = @import("types.zig").Texture;
pub const Sound = @import("types.zig").Sound;
pub const Font = @import("types.zig").Font;
pub const Color = @import("types.zig").Color;

pub const AssetType = enum {
    texture,
    sound,
    font,
};

pub const AssetManager = struct {
    allocator: std.mem.Allocator,
    textures: std.StringHashMap(Texture),
    sounds: std.StringHashMap(Sound),
    fonts: std.StringHashMap(Font),

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{
            .allocator = allocator,
            .textures = std.StringHashMap(Texture).init(allocator),
            .sounds = std.StringHashMap(Sound).init(allocator),
            .fonts = std.StringHashMap(Font).init(allocator),
        };
    }

    pub fn deinit(self: *@This()) void {
        var tex_it = self.textures.valueIterator();
        while (tex_it.next()) |texture_ptr| {
            rl.unloadTexture(texture_ptr.*);
        }
        self.textures.deinit();

        var sound_it = self.sounds.valueIterator();
        while (sound_it.next()) |sound_ptr| {
            rl.unloadSound(sound_ptr.*);
        }
        self.sounds.deinit();

        var font_it = self.fonts.valueIterator();
        while (font_it.next()) |font_ptr| {
            rl.unloadFont(font_ptr.*);
        }
        self.fonts.deinit();
    }

    pub fn loadAsset(self: *@This(), comptime T: type, name: []const u8, path: [:0]const u8) !void {
        if (T == Texture) {
            const asset = try rl.loadTexture(path);
            try self.textures.put(name, asset);
        } else if (T == Sound) {
            const asset = try rl.loadSound(path);
            try self.sounds.put(name, asset);
        } else if (T == Font) {
            const asset = try rl.loadFont(path);
            try self.fonts.put(name, asset);
        } else {
            @compileError("Unsupported asset type");
        }
    }
    pub fn loadAssetWithColorKey(
        self: *@This(),
        comptime T: type,
        name: []const u8,
        path: [:0]const u8,
        key_color: Color,
    ) !void {
        if (T == Texture) {
            var image = try rl.loadImage(path);
            defer rl.unloadImage(image);

            rl.imageFormat(&image, rl.PixelFormat.uncompressed_r8g8b8a8);
            const transparent = rl.Color{ .r = key_color.r, .g = key_color.g, .b = key_color.b, .a = 0 };
            rl.imageColorReplace(&image, key_color, transparent);

            const asset = try rl.loadTextureFromImage(image);
            try self.textures.put(name, asset);
        } else {
            @compileError("Color key only supported for textures");
        }
    }
    pub fn setTextureColorKey(self: *@This(), name: []const u8, key_color: Color) !void {
        if (self.textures.getPtr(name)) |tex_ptr| {
            var image = try rl.loadImageFromTexture(tex_ptr.*);
            defer rl.unloadImage(image);

            // Replace key color with transparent
            const transparent = rl.Color{ .r = key_color.r, .g = key_color.g, .b = key_color.b, .a = 0 };
            rl.imageColorReplace(&image, key_color, transparent);

            // Reload texture from modified image
            rl.unloadTexture(tex_ptr.*);
            tex_ptr.* = try rl.loadTextureFromImage(image);
        } else {
            return error.TextureNotFound;
        }
    }

    pub fn getAsset(self: *const @This(), comptime T: type, name: []const u8) ?T {
        if (T == Texture) {
            return self.textures.get(name);
        } else if (T == Sound) {
            return self.sounds.get(name);
        } else if (T == Font) {
            return self.fonts.get(name);
        } else {
            @compileError("Unsupported asset type");
        }
    }

    pub fn loadFont(self: *@This(), name: []const u8, path: [:0]const u8, size: i32) !void {
        const font = try rl.loadFontEx(path, size, null);
        try self.fonts.put(name, font);
    }

    pub fn playSound(self: *const @This(), name: []const u8) void {
        if (self.sounds.get(name)) |sound| {
            sound.play();
        }
    }
};
