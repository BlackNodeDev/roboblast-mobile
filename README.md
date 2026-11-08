# RoboBlast TPS: mobile touch build

**Play:** https://blacknodedev.github.io/roboblast-mobile/ (use Chrome; landscape works best on phones)

This is a Godot 4.7.2 web export of [GDQuest's 3D third-person controller demo](https://github.com/gdquest-demos/godot-4-3d-third-person-controller) with on-screen touch controls added. It is non-commercial and not endorsed by GDQuest.

- Code: MIT © GDQuest. Art: CC BY-NC-SA 4.0 © GDQuest. See [LICENSE](LICENSE) and [credits.html](credits.html).
- Modified and new source files are in [`source-changes/`](source-changes/).
- `index.pck` ships gzip-compressed as `index.pck.gz` because of GitHub's 100 MiB per-file limit. `index.html` downloads and unpacks it with the browser's DecompressionStream, then starts the game with Godot's `engine.preloadFile()` and `engine.start()`.

Touch controls: left stick to move, drag the right side to look, JUMP / FIRE / AIM / SWAP buttons, and II to pause.
