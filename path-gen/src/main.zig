const std = @import("std");
const path_gen = @import("path_gen");
const engine = @import("arcade_engine");
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        path_gen.printHelp();
        return;
    }

    const command = std.meta.stringToEnum(path_gen.Command, args[1]) orelse {
        std.debug.print("Unknown command: {s}\n\n", .{args[1]});
        path_gen.printHelp();
        return error.InvalidCommand;
    };

    var registry = engine.level.PathRegistry.init(allocator);
    defer registry.deinit();

    try registry.loadFromDirectory("assets/paths");

    switch (command) {
        .create => try path_gen.createPath(allocator, &registry, args),
        .list => try path_gen.listPaths(&registry),
        .delete => try path_gen.deletePath(&registry, args),
        .rename => try path_gen.renamePath(&registry, args),
        .info => try path_gen.showPathInfo(&registry, args),
        .help => path_gen.printHelp(),
    }
}
