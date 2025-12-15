const std = @import("std");

pub const Config = struct {
    app_name: []const u8,
    version: []const u8,
    asset_path: []const u8,
    debug: bool,

    pub fn deinit(self: Config, allocator: std.mem.Allocator) void {
        allocator.free(self.app_name);
        allocator.free(self.version);
        allocator.free(self.asset_path);
    }
};

pub fn getConfigPath(allocator: std.mem.Allocator, app_name: []const u8) ![]const u8 {
    const config_dir = try std.fs.getAppDataDir(allocator, app_name);
    defer allocator.free(config_dir);

    std.fs.makeDirAbsolute(config_dir) catch |err| switch (err) {
        error.PathAlreadyExists => {},
        else => return err,
    };

    return try std.fs.path.join(allocator, &.{ config_dir, "config.zon" });
}

pub fn writeDefaultConfig(path: []const u8, asset_path: []const u8) !void {
    const default_asset_path = if (asset_path.len == 0) "~/assets/paths" else asset_path;

    var buffer: [1024]u8 = undefined;

    const config_content = try std.fmt.bufPrint(&buffer,
        \\.{{
        \\  .app_name = "Sketch",
        \\  .version = "1.0.0",
        \\  .asset_path = "{s}",
        \\  .debug = true,
        \\}}
        \\
    , .{default_asset_path});

    const file = try std.fs.createFileAbsolute(path, .{});
    defer file.close();
    try file.writeAll(config_content);
}

pub fn read(allocator: std.mem.Allocator, path: []const u8) !Config {
    var dir = std.fs.openDirAbsolute(std.fs.path.dirname(path) orelse ".", .{}) catch std.fs.cwd();
    defer dir.close();

    const basename = std.fs.path.basename(path);
    std.debug.print("Full config path: {s}\n", .{path});
    std.debug.print("Reading config file: {s}\n", .{basename});

    const content = try dir.readFileAlloc(allocator, basename, 1024 * 1024);
    defer allocator.free(content);

    const content_z = try allocator.dupeZ(u8, content);
    defer allocator.free(content_z);

    var ast = try std.zig.Ast.parse(allocator, content_z, .zon);
    defer ast.deinit(allocator);

    if (ast.errors.len > 0) {
        std.debug.print("Parse errors: {d}\n", .{ast.errors.len});
        return error.ParseError;
    }

    // Debug: print node count
    std.debug.print("Total nodes: {d}\n", .{ast.nodes.len});

    var config = Config{
        .app_name = "",
        .version = "",
        .asset_path = "",
        .debug = false,
    };

    // The root expression is typically at node index 0
    // But we need to find the actual struct init, which might be a child
    var buf: [2]std.zig.Ast.Node.Index = undefined;

    // Try to find struct init - it might be the first node or we need to search
    var found = false;
    var i: u32 = 0;
    while (i < ast.nodes.len) : (i += 1) {
        const node_idx: std.zig.Ast.Node.Index = @enumFromInt(i);
        if (ast.fullStructInit(&buf, node_idx)) |struct_init| {
            std.debug.print("Found struct init at node {d}\n", .{i});

            for (struct_init.ast.fields) |field_init| {
                const field_name_token = ast.firstToken(field_init) - 2;
                const field_name = ast.tokenSlice(field_name_token);

                if (std.mem.eql(u8, field_name, "app_name")) {
                    const value = try extractString(allocator, &ast, field_init);
                    config.app_name = value;
                } else if (std.mem.eql(u8, field_name, "version")) {
                    const value = try extractString(allocator, &ast, field_init);
                    config.version = value;
                } else if (std.mem.eql(u8, field_name, "asset_path")) {
                    const value = try extractString(allocator, &ast, field_init);
                    config.asset_path = value;
                } else if (std.mem.eql(u8, field_name, "debug")) {
                    config.debug = try extractBool(&ast, field_init);
                }
            }
            found = true;
            break;
        }
    }

    if (!found) {
        return error.InvalidFormat;
    }

    return config;
}

fn extractString(allocator: std.mem.Allocator, ast: *std.zig.Ast, node: std.zig.Ast.Node.Index) ![]const u8 {
    const main_token = ast.nodes.items(.main_token)[@intFromEnum(node)];
    const token_tag = ast.tokens.items(.tag)[main_token];

    if (token_tag == .string_literal) {
        const raw = ast.tokenSlice(main_token);
        return try std.zig.string_literal.parseAlloc(allocator, raw);
    }
    return error.InvalidStringValue;
}

fn extractBool(ast: *std.zig.Ast, node: std.zig.Ast.Node.Index) !bool {
    const main_token = ast.nodes.items(.main_token)[@intFromEnum(node)];
    const raw = ast.tokenSlice(main_token);

    if (std.mem.eql(u8, raw, "true")) return true;
    if (std.mem.eql(u8, raw, "false")) return false;
    return error.InvalidBoolValue;
}

fn extractInt(comptime T: type, ast: *std.zig.Ast, node: std.zig.Ast.Node.Index) !T {
    const main_token = ast.node.items(.main_token)[@intFromEnum(node)];
    const token_tag = ast.tokens.items(.tag)[main_token];

    if (token_tag == .number_literal) {
        const raw = ast.tokenSlice(main_token);
        return try std.fmt.parseInt(T, raw, 10);
    }
    return error.InvalidIntValue;
}
