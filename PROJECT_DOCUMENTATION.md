# Character Creator — Project Documentation

This document is the canonical architectural reference for the **Character Creator** project built in Godot 4. It covers the core systems, the character creation pipeline, and the data/settings architecture.

---

## 1. Project Structure

```
character-creator/
├── core/                        ← Reusable, domain-agnostic systems
│   ├── systems/
│   │   ├── reactive_system/     ← Reactive data wrappers + signals
│   │   └── state_machine/       ← Node-based FSM
│   ├── assets/
│   ├── components/
│   └── globals/
│
└── character_creator/           ← Domain-specific character creator
    ├── assets/
    │   ├── material/
    │   ├── textures/
    │   └── placeholder/
    ├── components/
    │   └── character_creation/
    │       ├── base/            ← Manager, UI, updater orchestration
    │       └── visual_updaters/ ← Per-feature visual logic
    ├── data/
    │   ├── settings/            ← CharacterSetting subclasses
    │   ├── options/             ← SelectOption subclasses
    │   ├── character_data.gd
    │   └── character_creation_settings.gd
    └── scenes/
        ├── camera/
        └── character/
```

---

## 2. Core Systems (`core/`)

### 2.1 Reactive System

The backbone of all data flow in this project. Variables are wrapped in `Reactive` subclasses that emit a `reactive_changed` signal whenever their value changes.

```
Reactive (Resource, base)
├── ReactiveFloat
├── ReactiveInt
├── ReactiveString
├── ReactiveColor
├── ReactiveTexture
├── ReactiveArray
└── ReactiveObject
```

**Propagation chain:** A `Reactive` can have an `owner` (another `Reactive`). When a nested reactive changes, the signal bubbles up through `_propagate()` — e.g., changing `CharacterData.eyes_size.value` also fires `CharacterData.reactive_changed`.

```
eyes_size.value = 0.5
  → eyes_size.reactive_changed.emit(eyes_size)
    → CharacterData._propagate()        (owner chain)
      → CharacterData.reactive_changed.emit(CharacterData)
```

### 2.2 State Machine

Node-based FSM with `StateMachine`, `State`, and `Transition` nodes. Each `State` has `enter()`, `update()`, `physics_update()`, `exit()` lifecycle hooks.

---

## 3. Character Creator Architecture

### 3.1 High-Level Overview

The character creator is built around a **single source of truth** principle: `CharacterData` is the only authoritative representation of a character's state. Everything else either reads from it or writes to it.

```
┌─────────────────────────────────────────────────────────────┐
│                   CharacterCreatorManager                   │
│  ┌─────────────────┐    ┌──────────────────────────────┐   │
│  │ CharacterData   │◄───│  CharacterCreationSettings   │   │
│  │ (source of      │    │  (ranges, palettes, options) │   │
│  │  truth)         │    └──────────────────────────────┘   │
│  └────────┬────────┘                                        │
│           │                                                 │
│    ┌──────▼───────┐    ┌──────────────────────────┐        │
│    │CharacterUI   │    │ CharacterUpdater          │        │
│    │(writes to    │    │  ├ EyesVisualUpdater      │        │
│    │ CharacterData│    │  ├ SkinVisualUpdater       │        │
│    │ via ID/value)│    │  └ MouthVisualUpdater      │        │
│    └──────────────┘    └──────────────────────────┘        │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Node Hierarchy

```
CharacterCreatorManager (Node)
├── CharacterUpdater (Node)
│   ├── EyesVisualUpdater  (VisualUpdater)
│   ├── SkinVisualUpdater  (VisualUpdater)
│   └── MouthVisualUpdater (VisualUpdater)
└── CharacterCreatorUI (Control)
```

### 3.3 Initialization Sequence

```
CharacterCreatorManager._ready()
  1. CharacterData.new()  (if not assigned)
  2. creation_settings.load_equivalences()   ← builds all runtime maps
  3. _setup_reactive_bindings()              ← bridges id → resolved value
  4. character_updater.initialize(self)      ← visual updaters subscribe to signals
  5. character_ui.initialize(self)           ← UI binds sliders + populates palettes
```

---

## 4. Data Layer

### 4.1 CharacterData

The serializable snapshot of a character. Contains two types of fields per select parameter:

| Field | Type | Purpose |
|---|---|---|
| `eye_texture_id` | `ReactiveString` | Persistence key — saved to disk, order-independent |
| `eye_texture` | `ReactiveTexture` | Runtime-resolved texture — what visual updaters read |
| `skin_color_id` | `ReactiveString` | Persistence key |
| `skin_color` | `ReactiveColor` | Runtime-resolved color |
| `eyes_size` | `ReactiveFloat` | Direct float value (no ID needed for ranges) |
| `eyes_separation` | `ReactiveFloat` | — |
| `eyes_rotation` | `ReactiveFloat` | — |
| `eyes_height` | `ReactiveFloat` | — |

> **Why two fields for select params?**
> Storing the ID (`"eye_almond"`) makes saves portable: adding, removing, or reordering palette options never breaks existing character data. The resolved runtime value is set by `CharacterCreatorManager` — visual updaters never look up settings themselves.

**To reproduce any character:** pass a `CharacterData` to `CharacterUpdater.load_character_data()`. Each `VisualUpdater` reads the current values and applies them immediately.

```gdscript
character_updater.load_character_data(saved_data)
```

### 4.2 ID → Runtime Value Resolution (Manager Bridge)

`CharacterCreatorManager` is the **only** class that knows both `CharacterData` and `CharacterCreationSettings`. It bridges select IDs to resolved values:

```
character_data.eye_texture_id  ──► manager._resolve_eye_texture(id)
                                       └► settings.eye_texture.find_texture(id)
                                              └► character_data.eye_texture.value = texture

character_data.skin_color_id   ──► manager._resolve_skin_color(id)
                                       └► settings.skin_color.find_color(id)
                                              └► character_data.skin_color.value = color
```

---

## 5. Settings Architecture

### 5.1 Class Hierarchy

All settings are `Resource` subclasses, editable in the Godot inspector, and saved as `.tres` files.

```
CharacterSetting  (Resource, abstract)
│  └── load() → void   [abstract]
│
├── RangeSetting
│   ├── @export steps: int
│   ├── @export min_value: float
│   ├── @export max_value: float
│   ├── @export use_degrees: bool
│   ├── var equivalence: Dictionary[int, float]   ← built by load()
│   └── get_value(step: int) → float
│
└── SelectSetting  (abstract)
    ├── var _map: Dictionary[String, SelectOption]  ← built by load()
    ├── find(id) → SelectOption
    ├── get_default_id() → String  [abstract]
    ├── _build_map_from(options: Array)   ← shared validation logic
    │
    ├── TextureSelectSetting
    │   ├── @export options: Array[TextureOption]
    │   └── find_texture(id) → TextureOption
    │
    └── ColorSelectSetting
        ├── @export options: Array[ColorOption]
        └── find_color(id) → ColorOption
```

### 5.2 Option Types

```
SelectOption  (Resource, abstract)
│  ├── @export id: String           ← stable persistence key
│  └── @export display_name: String
│
├── TextureOption
│   └── @export texture: Texture2D
│
└── ColorOption
    └── @export color: Color
```

> **ID convention:** `snake_case` strings, e.g. `"eye_almond"`, `"skin_pale"`. **Never change an ID** after `.tres` files are created — it is the key used to restore a character's saved data.

### 5.3 CharacterCreationSettings

After the refactor, this class is purely declarative:

```gdscript
class_name CharacterCreationSettings
extends Resource

@export var eyes_separation : RangeSetting
@export var eyes_size       : RangeSetting
@export var eyes_rotation   : RangeSetting   # use_degrees = true in .tres
@export var eyes_height     : RangeSetting
@export var eye_texture     : TextureSelectSetting
@export var skin_color      : ColorSelectSetting

func load_equivalences() -> void:
    eyes_separation.load(); eyes_size.load(); ...
```

**Adding a new range parameter** takes exactly 2 lines (1 export + 1 `load()` call). **Adding a new palette option** requires only creating a new `.tres` file and adding it to the setting's array in the inspector.

### 5.4 Lookup Performance

All select settings use a pre-built `Dictionary[String, SelectOption]` for **O(1)** lookup by ID. The map is built once during `load_equivalences()` at startup.

```
find_texture("eye_almond")
  → _map.get("eye_almond", null)   ← O(1)
```

---

## 6. Visual Updater System

### 6.1 Base Contract

```
VisualUpdater  (Node, abstract)
├── initialize(manager: CharacterCreatorManager) [abstract]
│     Connect reactive signals for real-time updates during a creator session.
└── load_character_data(data: CharacterData) [abstract]
      Apply all current values from CharacterData immediately.
      Used to reproduce any saved character without a full manager session.
```

### 6.2 Updater Lifecycle

```
On session start:
  initialize(manager)
    ├── connect signals → future reactive changes
    └── (signals will fire as user interacts)

On loading a saved character:
  load_character_data(saved_data)
    └── reads current values and applies all setters immediately

On value change (reactive signal):
  _on_X_changed(reactive) → set_X(reactive.value)
```

### 6.3 EyesVisualUpdater Responsibility Map

| Signal source | Handler | Setter |
|---|---|---|
| `eyes_size.reactive_changed` | `_on_eyes_size_changed` | `set_eyes_size(value)` |
| `eyes_separation.reactive_changed` | `_on_eyes_separation_changed` | `set_eyes_separation(value)` |
| `eyes_rotation.reactive_changed` | `_on_eyes_rotation_changed` | `set_eyes_rotation(value)` |
| `eyes_height.reactive_changed` | `_on_eyes_height_changed` | `set_eyes_height(value)` |
| `eye_texture.reactive_changed` | `_on_eye_texture_changed` | `set_eye_texture(texture)` |

> `_initial_eyes_height` is captured in `_ready()` (not `initialize()`) so that `load_character_data()` produces correct results even when called independently of a manager session.

---

## 7. UI System

`CharacterCreatorUI` is a passive view: it only **writes** to `CharacterData`. It never reads from it for display (that is the visual updater's job).

```
bind_settings()
  ├── _initialize_slider(slider, RangeSetting)  ← sets max_value and initial step
  ├── _populate_eye_textures()                  ← generates TextureButtons from options
  └── _populate_skin_colors()                   ← generates styled Buttons from ColorOptions

bind_signals()
  ├── slider.value_changed → character_data.eyes_X.value = setting.eyes_X.get_value(step)
  ├── texture_btn.pressed  → character_data.eye_texture_id.value = option.id
  └── color_btn.pressed    → character_data.skin_color_id.value = option.id
```

---

## 8. Full Data Flow — User Selects an Eye Texture

```
[User clicks TextureButton in UI]
        │
        ▼
character_data.eye_texture_id.value = "eye_almond"
        │
        ▼  (ReactiveString.reactive_changed signal)
CharacterCreatorManager._on_eye_texture_id_changed()
        │
        ▼
creation_settings.eye_texture.find_texture("eye_almond")  → TextureOption
        │
        ▼
character_data.eye_texture.value = option.texture
        │
        ▼  (ReactiveTexture.reactive_changed signal)
EyesVisualUpdater._on_eye_texture_changed()
        │
        ▼
l_eye_decal.texture_albedo = texture
r_eye_decal.texture_albedo = texture
```

---

## 9. Setup Checklist (Editor)

When setting up the project in the Godot editor:

### `creation_settings.tres`
- Assign a `RangeSetting.tres` for each eyes parameter (`eyes_separation`, `eyes_size`, `eyes_rotation`, `eyes_height`)
- For `eyes_rotation`: set `use_degrees = true`, `min_value = -45`, `max_value = 45`
- Assign a `TextureSelectSetting.tres` for `eye_texture`
- Assign a `ColorSelectSetting.tres` for `skin_color`

### Option `.tres` Files
- Create one `TextureOption.tres` per eye texture option — set `id` (snake_case, permanent), `display_name`, `texture`
- Create one `ColorOption.tres` per skin color — set `id`, `display_name`, `color`
- Add all options to the respective setting's `options` array

### Scene Setup
- Assign `l_eye_decal` and `r_eye_decal` exports in `EyesVisualUpdater`
- Assign a `Container` node to `eye_texture_container` in `CharacterCreatorUI`
- Assign a `Container` node to `skin_color_container` in `CharacterCreatorUI`

---

*Generated by Antigravity AI — Last updated 2026-04-27*
