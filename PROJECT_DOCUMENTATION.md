# Godot First-Person Template Documentation

This document provides a comprehensive overview of the architecture, systems, and components of the First-Person Template project. It serves as a unified reference guide for future development, clarifying how the `core` library interacts with `project-specific` implementations.

---

## 1. Architecture Overview

The project is strictly divided into two main domains to maximize reusability and maintainability:

*   **`core/`**: Contains project-agnostic systems, globals, and components. Anything inside this directory is designed to be easily exported or re-used in entirely different Godot projects without modification.
*   **`first_person_template_project/`**: Contains game-specific logic, actual scenes, player controllers, and unique behaviors (such as specific weapons, UI layouts, or game modes). It consumes the `core` library.

### Key Philosophy: Decoupling and Modularity
The codebase relies heavily on the **Entity-Component-System (ECS) heavily adapted for Godot's node hierarchy**. We use "meta components" to tag objects and "behavior components" to execute logic, communicating through Godot `Signals` or the custom **Reactive System**.

---

## 2. Core Systems (`core/systems/`)

### 2.1. Reactive System (`core/systems/reactive_system/`)
An architectural pattern used to decouple data from representation (UI or game logic). Instead of direct references, variables are wrapped in `Reactive` classes.

*   **`Reactive` (Base)**: Wraps a raw value type and emits the `changed(new_value, old_value)` signal whenever modified.
*   **Variant Specifics**: We have `ReactiveInt`, `ReactiveString`, `ReactiveArray`, `ReactiveObject`.
*   **Usage**: UI elements (like an `FPSCounter` or an `InventoryBar`) listen to a reactive variable (e.g., `PlayerHealth.reactive_value.changed`). When the gameplay logic updates the reactive, the UI updates automatically without the gameplay logic knowing the UI exists.

### 2.2. State Machine (`core/systems/state_machine/`)
A node-based Finite State Machine (FSM).
*   **`StateMachine`**: The root node managing execution.
*   **`State`**: The base class for logic (e.g., `IdleState`, `RunningState`). It contains lifecycle methods: `enter()`, `update()`, `physics_update()`, `exit()`.
*   **`Transition`**: Evaluates conditions to move from one `State` to another.

---

## 3. Globals & Managers (`core/globals/`)

Autoloaded (Singleton) managers handling project-wide accessibility:
*   **`GameManagers`**: Orchestrates high-level game states (Pause, Resume, Game Over).
*   **`SettingsSet` / Settings Manager**: Handles the saving, loading, and application of user settings (Graphics, Audio, Invert Y-Axis, etc.) across sessions.
*   **`SceneLoader`**: A robust, asynchronous scene switcher allowing for loading screens and smooth transitions between levels.
*   **`Utils`**: A static library providing common helper functions, particularly around robust, type-safe Physics Server queries (e.g., Raycasting, shape casting).

---

## 4. Core Components (`core/components/`)

These components are attached as Godot child nodes to give behaviors to arbitrary actors.

### 4.1. `FirstPersonMovementComponent`
A highly polished Kinematic (CharacterBody3D) movement controller. Features include:
*   Standard Move, Airborne, Sprint, and Crouch.
*   **Slope & Step Handling**: Smoothly traverses stairs and angled terrain without bouncing.
*   **Wall Sliding & Wall Running**: Detects adjacent walls based on velocity and surface normal dot products. Allows for continuous running, tilting the camera, sliding friction, and wall-jumping (with correct velocity carry-over and release triggers).

### 4.2. `FirstPersonCameraManager`
Handles the interpolation, aiming, and visual feedback of the camera.
*   Includes Field of View (FOV) shifting based on sprint state.
*   Implements dynamic camera tilting for wall-running or leaning.
*   Controls the actual mouse-look input and clamp angles.

### 4.3. `ShakerComponent` & `ShakeProfile`
A robust modular camera and object shake system designed as an alternative to "Smooth Shake" plugins.
*   Uses a **Tweening and layer-based noise architecture**.
*   **`ShakeProfile`**: A Resource defining frequency, amplitude, noise textures, and attenuation.
*   Allows stacking multiple shakes (e.g., footsteps + explosion) and accurately blending them out without jarring snapping.

### 4.4. `DayCycleComponent` (Day/Night System)
Controls directional lights and environment/skybox parameters to dynamically transition between times of day based on realistic or modified cycles.

### 4.5. `InputHandlerComponent`
Centralizes input polling (`Input.is_action_pressed()`, etc.) into variables that other components read from. This allows easy implementation of AI bots or external controllers by overriding the handler without changing movement logic.

### 4.6. Inventory System (`core/components/inventory_component/`)
A scalable, data-driven back-end for inventory management and equippable items.
*   **Data Models (`ItemData` & `EquippableItemData`)**: Core `Resource` types defining static properties (names, stack limits) and the `PackedScene` to cleanly instantiate when equipped.
*   **`InventoryComponent`**: The single source of truth for the player's pockets. It manages an array of `InventorySlotData`, handles stacking logic, and tracks the `active_slot_index`.
*   It synchronizes unidirectionally with `InventoryUIState`, ensuring the front-end UI reacts instantly when underlying data changes.

---

## 5. Project Components (`first_person_template_project/components/`)

These are gameplay-specific mechanics attached to the player or interactables.

### 5.1. The "Meta" Component Pattern
We use `MetaComponent` nodes to tag interactable objects. For example:
*   **`GrabbableMetaComponent`**: Tells the system "this Object can be picked up".
*   **`PunchableMetaComponent`**: Tells the system "this Object reacts to being punched".

### 5.2. Grab System
*   **`GrabbingBehavior`**: The logic executing on the Player. When activated, it uses `Utils` to raycast for a `GrabbableMetaComponent`.
*   **Physics Slide Mechanics**: Instead of strictly snapping the grabbed item to the camera (which causes geometry clipping), it dynamically collides and slides against walls, resolving penetration smoothly.

### 5.3. Punch System
*   **`PunchingBehaviorComponent`**: Executes raycast checks when the player clicks the punch button.
*   Applies a localized, properly calculated 3D impulse to `RigidBody3D` nodes at the exact point of impact using global collision offsets, ensuring natural rotation/torque when an item is struck.

### 5.4. `InSightCheckerComponent`
An optimization & interaction tool used to continuously or explicitly verify if a specific interactable object or enemy is actively framed within the player's camera frustum (line of sight).

---

## 6. Key Project Scenes & Actors

### 6.1. The Player (`first_person_template_project/scenes/player/`)
An integration scene where the `CharacterBody3D` node aggregates the core controllers (`Movement`, `Camera`, `Shaker`, `Input`) alongside behaviors (`Grabbing`, `Punching`, `Inventory`) to structure the playable character.
*   **`Arms` System**: An IK/AnimationTree unified rig. It listens dynamically to the `InventoryComponent`'s active slot, seamlessly changing visual states or instantiating `EquippableItemData` models (like weapons/tools) directly into the view model's hand bones.

### 6.2. `SphereVehicle` (`first_person_template_project/scenes/vehicle/`)
An independent physics-based vehicle controller inspired by arcade driving (e.g., Rocket League/Deadline Delivery).
*   Uses a rolling `RigidBody3D` sphere for suspension, momentum, and collision physics instead of Godot's built-in `VehicleBody3D`. This ensures extreme stability and snappy maneuvering without complex suspension tuning.

### 6.3. User Interface (`first_person_template_project/scenes/ui/`)
*   **`AimerStateMachine`**: Manages the crosshair UI logic (interacting, standard, reloading).
*   **`InventoryBar`**: Reads from a `ReactiveArray` of inventory slots (using `InventoryUiState`) to dynamically represent collected items.
*   **`HUD` & `FPSCounter`**: Standard on-screen contextual displays driven by Reactive State.

---
*Generated by Antigravity AI.*
