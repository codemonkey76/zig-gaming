const MutableGameContext = @import("../context.zig").MutableGameContext;
const Key = @import("renderer").types.Key;

pub fn registerKeys(ctx: MutableGameContext, keys: []const Key) void {
    for (keys) |key| {
        ctx.renderer.input_manager.registerKey(key);
    }
}

pub fn unregisterKeys(ctx: MutableGameContext, keys: []const Key) void {
    for (keys) |key| {
        ctx.renderer.input_manager.unregisterKey(key);
    }
}
