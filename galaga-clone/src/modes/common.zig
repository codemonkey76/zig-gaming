const MutableGameContext = @import("../context.zig").MutableGameContext;
const engine = @import("arcade_engine");
const Key = engine.types.Key;

pub fn registerKeys(ctx: MutableGameContext, keys: []const Key) void {
    for (keys) |key| {
        ctx.input_manager.registerKey(key);
    }
}

pub fn unregisterKeys(ctx: MutableGameContext, keys: []const Key) void {
    for (keys) |key| {
        ctx.input_manager.unregisterKey(key);
    }
}
