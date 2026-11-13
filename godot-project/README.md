# RoboBlast TPS Demo: mobile touch build

This is GDQuest's Godot 4 third-person controller demo with on-screen phone controls added. The original art, levels and gameplay are unchanged.

- Upstream: https://github.com/gdquest-demos/godot-4-3d-third-person-controller (commit b3bd6e8, 2026-08-15)
- Original demo: https://gdquest-demos.github.io/godot-4-3d-third-person-controller/
- Engine: **Godot 4.7.2-stable** (official). The project targets 4.7 and uses Jolt Physics, which works in the web build. Desktop uses Forward+; the web build uses the Compatibility (WebGL2) renderer.

## Controls
| Action | Touch | Keyboard / mouse | Gamepad |
|---|---|---|---|
| Move | Left analog stick | WASD | Left stick |
| Look | Drag the right side of the screen | Mouse (captured) | Right stick |
| Jump | JUMP | Space | A / Cross |
| Fire / attack | FIRE (hold) | Left click | RT |
| Aim | AIM (hold) | Right click | LT |
| Swap weapon | SWAP | Tab | Y / Triangle |
| Pause | II (top right) | Esc | Start |

The touch controls turn on automatically when a touchscreen is detected. To force them on or off in a browser, add `?touch=1` or `?touch=0` to the URL. On desktop, run with `-- --touch=1`. Multi-touch works: you can move, look and press buttons at the same time. All touch inputs are released when the game pauses or loses focus. **Play in landscape**, because the original menu and HUD are designed for landscape.

## Run the web build locally
The web build has to be served over HTTP; opening `index.html` directly from a `file://` path won't work. It is single-threaded, so it needs no special headers.
```
cd web
python3 serve.py        # then open http://127.0.0.1:8000
```
To play on your phone, host the `web/` folder on any static host such as GitHub Pages or itch.io. `serve.py` only listens on this computer (127.0.0.1).

## Edit in the Godot web editor
1. Open https://editor.godotengine.org/releases/latest/ (4.7.x).
2. Choose **Preload project ZIP**, pick the project ZIP, then **Start Godot Editor** → Install & Edit.
3. The web editor only uses the Compatibility renderer and **cannot export**. To export, use Project > Tools > Download Project Source, then export with desktop Godot 4.7.2 and the official export templates (preset "Web" is included, with thread support off).

## Changes from upstream
- `touch/touch_controls.gd` (new autoload `TouchControls`) provides the stick, look area and buttons. It adds touch input on top of the existing input actions and doesn't replace them.
- `player/camera_controller.gd` adds `add_look_input()` and the group `touch_look_camera`. Mouse look behaves exactly as before.
- `autoloads/full_screen_handler.gd` no longer captures the pointer on touch devices.
- `autoloads/camera_mode.gd` replaces `free()` with `queue_free()`, which fixes a parse error in release web exports. This is a debug-only free-camera tool.
- `project.godot` adds the autoload and ETC2/ASTC texture import for mobile GPUs. `export_presets.cfg` adds the Web preset.

## License
- Code and Godot resources: MIT © GDQuest. See `LICENSE`.
- Art (textures and 3D models): **CC BY-NC-SA 4.0**. Non-commercial use only. Credit GDQuest and share any changes under the same license.

The touch-control additions are MIT.
