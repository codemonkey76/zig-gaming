# Path Editor

A visual path editor for the Arcade Engine that allows you to create, edit, and manage Bézier curve paths.

## Features

- **Visual Path Editing**: Click to add control points, drag to move them, right-click to delete
- **Path List**: Browse all paths in `assets/paths` directory
- **Load/Save**: Save paths to `.gpath` files and load them for editing
- **Real-time Preview**: See your Bézier curves rendered as you edit

## Building

```bash
zig build
```

## Running

```bash
zig build run
```

## Usage

### Viewing Mode (Default)

- **Path List**: Left side panel shows all available paths
- Click on a path name to select it
- **ENTER**: Load selected path for editing
- **N**: Create a new path
- **DELETE**: Remove the selected path file

### Editing Mode

When you press ENTER on a selected path or create a new one with N:

- **LEFT CLICK**: 
  - Click empty space to add a new control point
  - Click and drag existing points to move them
- **RIGHT CLICK**: Delete a control point (click near it)
- **S**: Save the path (will prompt for name)
- **ESC**: Cancel editing and return to viewing mode
- **N**: Start a new path (discards current)

### Saving Paths

When you press **S**:

1. A dialog appears asking for the path name
2. Type the name using letters, numbers, underscore, and hyphen
3. **BACKSPACE** to delete characters
4. **ENTER** to save
5. **ESC** to cancel

The path will be saved to `assets/paths/[name].gpath`

## Directory Structure

You need to have this structure:

```
path_editor/
├── build.zig
├── build.zig.zon
├── src/
│   ├── main.zig                    # Application entry point
│   ├── ui/
│   │   ├── path_list.zig          # Path list panel UI
│   │   └── save_dialog.zig        # Save dialog UI
│   └── editor/
│       ├── app_state.zig          # Application state management
│       ├── path_editor.zig        # Path editing logic
│       ├── path_viewer.zig        # Path viewing/display
│       ├── input_handler.zig      # Input handling
│       └── render_system.zig      # Rendering system
└── assets/
    ├── paths/                      # Your .gpath files go here
    └── fonts/
        └── default.ttf             # Required font file
```

## Code Organization

The application is organized into several modules:

- **UI Components** (`src/ui/`): Reusable UI widgets
  - `PathListUI`: File browser panel
  - `SaveDialog`: Name input dialog

- **Editor Components** (`src/editor/`):
  - `AppState`: Manages application modes and state
  - `PathEditor`: Handles path editing operations
  - `PathViewer`: Displays saved paths in read-only mode
  - `InputHandler`: Processes keyboard/mouse input
  - `RenderSystem`: Coordinates all rendering

- **Main** (`src/main.zig`): Application entry point and game loop

## Controls Summary

| Key | Action |
|-----|--------|
| LEFT CLICK | Add/move control points |
| RIGHT CLICK | Delete control point |
| ENTER | Edit selected path |
| N | New path |
| S | Save current path |
| DELETE | Remove selected path |
| ESC | Cancel/return to viewing |

## Path File Format

Paths are saved as `.gpath` files with:
- Magic header: "GPTH"
- Version number
- Path name
- Control points (x, y coordinates)

## Tips

- For smooth curves, use at least 4 control points
- The yellow lines show the control polygon
- The cyan/green curve is the actual Bézier path
- Control points are shown as circles (green=normal, red=selected, blue=viewing mode)
- Paths are automatically centered in the viewport at normalized coordinates (0-1)
