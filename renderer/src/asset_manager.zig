const std = @import("std");
const rl = @import("raylib");
pub const Texture = @import("types.zig").Texture;
pub const Sound = @import("types.zig").Sound;
pub const Font = @import("types.zig").Font;

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

    pub fn getAsset(self: *@This(), comptime T: type, name: []const u8) ?T {
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

    pub fn playSound(self: *@This(), name: []const u8) void {
        if (self.sounds.get(name)) |sound| {
            sound.play();
        }
    }
};
