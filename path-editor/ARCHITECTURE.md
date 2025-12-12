# Path Editor Architecture

## Module Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         main.zig                            │
│                  (Application Entry Point)                  │
│                                                             │
│  • Initialize engine components (Window, Renderer, etc.)   │
│  • Create AppState, PathRegistry, UI components            │
│  • Main game loop                                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              │ coordinates
                              ▼
        ┌─────────────────────────────────────────┐
        │         Application Layer               │
        │                                         │
        │  ┌──────────────────────────────────┐  │
        │  │       AppState                   │  │
        │  │  • Current mode (viewing/editing)│  │
        │  │  • PathEditor instance           │  │
        │  │  • Current path name             │  │
        │  └──────────────────────────────────┘  │
        │                                         │
        │  ┌──────────────────────────────────┐  │
        │  │    InputHandler                  │  │
        │  │  • Process global shortcuts      │  │
        │  │  • Delegate to mode handlers     │  │
        │  └──────────────────────────────────┘  │
        │                                         │
        │  ┌──────────────────────────────────┐  │
        │  │    RenderSystem                  │  │
        │  │  • Coordinate rendering          │  │
        │  │  • Draw UI and paths             │  │
        │  └──────────────────────────────────┘  │
        └─────────────────────────────────────────┘
                              │
                ┌─────────────┴─────────────┐
                ▼                           ▼
        ┌───────────────┐           ┌──────────────┐
        │  UI Layer     │           │ Editor Layer │
        └───────────────┘           └──────────────┘
                │                           │
    ┌───────────┴───────────┐       ┌──────┴────────┐
    ▼                       ▼       ▼               ▼
┌─────────┐          ┌──────────┐  ┌────────┐  ┌─────────┐
│PathList │          │   Save   │  │ Path   │  │  Path   │
│   UI    │          │  Dialog  │  │ Editor │  │ Viewer  │
└─────────┘          └──────────┘  └────────┘  └─────────┘
    │                      │            │            │
    │                      │            │            │
    └──────────────────────┴────────────┴────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │  Arcade Engine   │
                    │                  │
                    │  • PathRegistry  │
                    │  • Bezier        │
                    │  • Renderer      │
                    │  • Window        │
                    │  • InputManager  │
                    └──────────────────┘
```

## Data Flow

### Viewing Mode
```
User Input
    │
    ▼
InputManager.poll()
    │
    ▼
InputHandler.handleViewingInput()
    │
    ├─ Enter → AppState.startEditing()
    ├─ N → AppState.startCreatingNew()
    └─ Delete → PathRegistry.deletePath()
    │
    ▼
RenderSystem.render()
    │
    └─ PathViewer.draw() ← PathRegistry.getPath()
```

### Editing Mode
```
User Input
    │
    ▼
InputManager.poll()
    │
    ├─ Global Keys → InputHandler.handleEditingInput()
    │                    │
    │                    ├─ S → SaveDialog.show()
    │                    ├─ N → AppState.startCreatingNew()
    │                    └─ ESC → AppState.returnToViewing()
    │
    └─ Mouse Input → PathEditor.handleInput()
                         │
                         ├─ Click → Add/Select point
                         ├─ Drag → Move point
                         └─ Right Click → Delete point
    │
    ▼
RenderSystem.render()
    │
    └─ PathEditor.draw()
```

### Save Flow
```
User presses 'S'
    │
    ▼
SaveDialog.show()
    │
    ▼
User types name + Enter
    │
    ▼
SaveDialog.handleInput() → returns path_name
    │
    ▼
PathEditor.toPathDefinition() → PathDefinition
    │
    ▼
PathRegistry.savePath(name, definition)
    │
    ├─ Serialize to .gpath file
    └─ Update in-memory registry
    │
    ▼
AppState.returnToViewing()
```

## Component Responsibilities

### UI Components

**PathListUI** (`ui/path_list.zig`)
- Display scrollable list of path files
- Handle selection via mouse clicks
- Highlight selected item
- Render in letterbox area

**SaveDialog** (`ui/save_dialog.zig`)
- Show/hide modal dialog
- Text input handling
- Return path name on confirm
- Cancel on ESC

### Editor Components

**AppState** (`editor/app_state.zig`)
- Track current mode (viewing/editing/creating)
- Manage PathEditor lifecycle
- Store current path name
- Provide mode transitions

**PathEditor** (`editor/path_editor.zig`)
- Manage Bezier curve points
- Handle point selection/dragging
- Add/remove control points
- Convert to/from PathDefinition

**PathViewer** (`editor/path_viewer.zig`)
- Render saved paths in read-only mode
- Display control points and curves
- Temporary Bezier instance for display

**InputHandler** (`editor/input_handler.zig`)
- Route input based on mode
- Handle global shortcuts (N, S, ESC, etc.)
- Coordinate between UI and editor

**RenderSystem** (`editor/render_system.zig`)
- Coordinate all rendering
- Draw appropriate content per mode
- Render instructions/help text
- Compose UI elements

## Key Design Patterns

### State Management
- `AppState` acts as central state container
- Mode transitions are explicit methods
- Editor state is cleared on mode changes

### Separation of Concerns
- UI components don't know about editor logic
- Editor components don't handle UI input
- InputHandler coordinates between layers

### Dependency Direction
```
main.zig
   │
   ├──> UI Components (pure presentation)
   ├──> Editor Components (business logic)
   └──> Arcade Engine (infrastructure)
```

### Error Handling
- Errors propagate up to main loop
- Failed operations don't crash the app
- User is returned to safe state on error

## Extension Points

To add new features:

1. **New UI Component**: Create in `src/ui/`, follow PathListUI pattern
2. **New Editor Mode**: Add to `EditorMode` enum, handle in InputHandler
3. **New Editor Feature**: Extend PathEditor with new methods
4. **New Rendering**: Add to RenderSystem.render() switch

## Testing Strategy

Each module can be tested independently:

- **UI Components**: Mock renderer, test input handling
- **PathEditor**: Test point manipulation, coordinate conversion
- **InputHandler**: Test mode transitions, shortcut handling
- **AppState**: Test state transitions
