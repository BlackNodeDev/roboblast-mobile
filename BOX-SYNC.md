# box-sync: RoboBlast Godot project

This branch adds the touch-enabled Godot 4.7.2 project from the shared Grok Bot box, so the repo holds source as well as the already-published web export.

Imported on 14 November 2026 (Australia/Brisbane). Original box folders were copied, not moved.

Added:

- `godot-project/` — from `/workspace/godot-third-person-mobile/project` (the `.godot/` import cache was left out)
- `shots/` — PNG captures from `/workspace/godot-third-person-mobile/shots`

Not added:

- `web/index.pck` (105.6 MB, over GitHub's 100 MB limit). The published export already uses `index.pck.gz`.
- Uncompressed `web/` export and the split `pkg/` zip packs (the live web export is already on `main`)
- `src/` — vanilla GDQuest upstream clone; that project is already forked at `BlackNodeDev/godot-4-3d-third-person-controller`

Art remains under the original CC BY-NC-SA licence in this repository. This repository is public.

Open `godot-project/project.godot` in Godot 4.7.2.
