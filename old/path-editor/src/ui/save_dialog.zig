const std = @import("std");
const engine = @import("arcade_engine");

const Renderer = engine.core.Renderer;
const Vec2 = engine.types.Vec2;
const Color = engine.types.Color;
const Rect = engine.types.Rect;
const Input = engine.types.Input;
const Font = engine.types.Font;
const Key = engine.types.Key;

pub const SaveDialog = struct {
    name_buffer: [64]u8 = undefined,
    name_len: usize = 0,
    visible: bool = false,

    pub fn init() SaveDialog {
        return .{};
    }

    pub fn show(self: *SaveDialog, initial_name: []const u8) void {
        self.visible = true;
        self.name_len = @min(initial_name.len, self.name_buffer.len - 1);
        if (self.name_len > 0) {
            @memcpy(self.name_buffer[0..self.name_len], initial_name[0..self.name_len]);
        }
    }

    pub fn hide(self: *SaveDialog) void {
        self.visible = false;
        self.name_len = 0;
    }

    pub fn handleInput(self: *SaveDialog, input: Input) ?[]const u8 {
        if (!self.visible) return null;

        // Enter to confirm save
        if (input.isKeyPressed(.enter) and self.name_len > 0) {
            return self.name_buffer[0..self.name_len];
        }

        // Escape to cancel
        if (input.isKeyPressed(.escape)) {
            self.hide();
            return null;
        }

        // Text input - letters only
        if (input.isKeyPressed(.a)) self.tryAddChar('a');
        if (input.isKeyPressed(.b)) self.tryAddChar('b');
        if (input.isKeyPressed(.c)) self.tryAddChar('c');
        if (input.isKeyPressed(.d)) self.tryAddChar('d');
        if (input.isKeyPressed(.e)) self.tryAddChar('e');
        if (input.isKeyPressed(.f)) self.tryAddChar('f');
        if (input.isKeyPressed(.g)) self.tryAddChar('g');
        if (input.isKeyPressed(.h)) self.tryAddChar('h');
        if (input.isKeyPressed(.i)) self.tryAddChar('i');
        if (input.isKeyPressed(.j)) self.tryAddChar('j');
        if (input.isKeyPressed(.k)) self.tryAddChar('k');
        if (input.isKeyPressed(.l)) self.tryAddChar('l');
        if (input.isKeyPressed(.m)) self.tryAddChar('m');
        if (input.isKeyPressed(.n)) self.tryAddChar('n');
        if (input.isKeyPressed(.o)) self.tryAddChar('o');
        if (input.isKeyPressed(.p)) self.tryAddChar('p');
        if (input.isKeyPressed(.q)) self.tryAddChar('q');
        if (input.isKeyPressed(.r)) self.tryAddChar('r');
        if (input.isKeyPressed(.s)) self.tryAddChar('s');
        if (input.isKeyPressed(.t)) self.tryAddChar('t');
        if (input.isKeyPressed(.u)) self.tryAddChar('u');
        if (input.isKeyPressed(.v)) self.tryAddChar('v');
        if (input.isKeyPressed(.w)) self.tryAddChar('w');
        if (input.isKeyPressed(.x)) self.tryAddChar('x');
        if (input.isKeyPressed(.y)) self.tryAddChar('y');
        if (input.isKeyPressed(.z)) self.tryAddChar('z');

        // Number keys
        if (input.isKeyPressed(.zero)) self.tryAddChar('0');
        if (input.isKeyPressed(.one)) self.tryAddChar('1');
        if (input.isKeyPressed(.two)) self.tryAddChar('2');
        if (input.isKeyPressed(.three)) self.tryAddChar('3');
        if (input.isKeyPressed(.four)) self.tryAddChar('4');
        if (input.isKeyPressed(.five)) self.tryAddChar('5');
        if (input.isKeyPressed(.six)) self.tryAddChar('6');
        if (input.isKeyPressed(.seven)) self.tryAddChar('7');
        if (input.isKeyPressed(.eight)) self.tryAddChar('8');
        if (input.isKeyPressed(.nine)) self.tryAddChar('9');

        // Special characters
        if (input.isKeyPressed(.minus)) self.tryAddChar('-');
        if (input.isKeyPressed(.equal)) self.tryAddChar('_');

        // Backspace
        if (input.isKeyPressed(.backspace) and self.name_len > 0) {
            self.name_len -= 1;
        }

        return null;
    }

    fn tryAddChar(self: *SaveDialog, c: u8) void {
        if (self.name_len < self.name_buffer.len - 1) {
            self.name_buffer[self.name_len] = c;
            self.name_len += 1;
        }
    }

    pub fn draw(self: *const SaveDialog, renderer: *const Renderer, font: Font) void {
        if (!self.visible) return;

        const prompt_rect = Rect{
            .x = renderer.normToRender(.{ .x = 0.3, .y = 0 }).x,
            .y = renderer.normToRender(.{ .x = 0, .y = 0.4 }).y,
            .width = renderer.normToRender(.{ .x = 0.4, .y = 0 }).x,
            .height = renderer.normToRender(.{ .x = 0, .y = 0.2 }).y,
        };

        Renderer.drawRectangleRec(prompt_rect, Color{ .r = 60, .g = 60, .b = 70, .a = 255 });
        Renderer.drawRectangleLines(prompt_rect, 2, Color.white);

        const prompt_pos = renderer.normToRender(.{ .x = 0.35, .y = 0.43 });
        var prompt_buf: [128:0]u8 = undefined;
        const prompt = std.fmt.bufPrintZ(&prompt_buf, "Path name: {s}_", .{self.name_buffer[0..self.name_len]}) catch "???";
        Renderer.drawText(prompt, prompt_pos, 12, Color.white, font);

        const help_pos = renderer.normToRender(.{ .x = 0.35, .y = 0.50 });
        Renderer.drawText("Type name, ENTER to save, ESC to cancel", help_pos, 10, Color.light_gray, font);
    }
};
