## On-screen touch controls for phones/tablets (added for the mobile build).
## Left: analog stick for movement. Right: drag to look. Buttons: Jump, Fire, Aim, Swap, Pause.
## Enabled when a touchscreen is detected. Override on web with ?touch=1 / ?touch=0,
## or on desktop with the command-line user argument: -- --touch=1
extends CanvasLayer

const MOVE_ACTIONS := ["move_left", "move_right", "move_up", "move_down"]
const LOOK_SENSITIVITY := 0.3

var enabled := false

var _root: Control
var _owners := {}            # touch index -> "stick" | "look" | button id
var _stick_center := Vector2.ZERO
var _stick_knob := Vector2.ZERO
var _stick_radius := 100.0
var _buttons := []           # [{id, action, label, center, radius, hold}]
var _pressed := {}           # button id -> true
var _pending_release := []   # actions to release next frame


func _ready() -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS
	enabled = _detect_touch()
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.draw.connect(_draw_overlay)
	add_child(_root)
	visible = enabled
	if not enabled:
		set_process_input(false)
		return
	# Touch taps must not count as mouse clicks (left mouse = attack, right = aim).
	for action in ["attack", "aim"]:
		for ev in InputMap.action_get_events(action):
			if ev is InputEventMouseButton:
				InputMap.action_erase_event(action, ev)
	get_viewport().size_changed.connect(_layout)
	_layout()


func _detect_touch() -> bool:
	for arg in OS.get_cmdline_user_args():
		if arg == "--touch=1": return true
		if arg == "--touch=0": return false
	if OS.has_feature("web"):
		var q = JavaScriptBridge.eval("window.location.search", true)
		if typeof(q) == TYPE_STRING:
			if q.contains("touch=1"): return true
			if q.contains("touch=0"): return false
	return DisplayServer.is_touchscreen_available()


func _layout() -> void:
	var size := _root.get_viewport_rect().size
	var unit := minf(size.x, size.y)
	# Safe area (notches) converted from screen pixels to canvas units.
	var margin := unit * 0.05
	var safe := DisplayServer.get_display_safe_area()
	var screen := DisplayServer.screen_get_size()
	var inset := Vector4(margin, margin, margin, margin) # left, top, right, bottom
	if safe.size.x > 0 and screen.x > 0 and not OS.has_feature("web"):
		var sx := size.x / float(screen.x)
		var sy := size.y / float(screen.y)
		inset.x += safe.position.x * sx
		inset.y += safe.position.y * sy
		inset.z += (screen.x - safe.end.x) * sx
		inset.w += (screen.y - safe.end.y) * sy
	_stick_radius = unit * 0.14
	_stick_center = Vector2(inset.x + _stick_radius * 1.15, size.y - inset.w - _stick_radius * 1.15)
	_stick_knob = _stick_center
	var r := unit * 0.075
	var br := Vector2(size.x - inset.z - r * 1.2, size.y - inset.w - r * 1.2)
	_buttons = [
		{id = "jump", action = "jump", label = "JUMP", center = br, radius = r * 1.2, hold = true},
		{id = "attack", action = "attack", label = "FIRE", center = br + Vector2(-r * 2.7, -r * 0.3), radius = r, hold = true},
		{id = "aim", action = "aim", label = "AIM", center = br + Vector2(-r * 0.3, -r * 2.7), radius = r, hold = true},
		{id = "swap", action = "swap_weapons", label = "SWAP", center = br + Vector2(-r * 2.6, -r * 2.6), radius = r * 0.75, hold = false},
		{id = "pause", action = "pause", label = "II", center = Vector2(size.x - inset.z - r * 0.7, inset.y + r * 0.7), radius = r * 0.6, hold = false},
	]
	_root.queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_touch_down(event.index, event.position)
		else:
			_touch_up(event.index)
	elif event is InputEventScreenDrag:
		var role = _owners.get(event.index)
		if role == "stick":
			_update_stick(event.position)
		elif role == "look":
			var cam := _camera()
			if cam:
				cam.add_look_input(event.relative * LOOK_SENSITIVITY)


func _touch_down(index: int, pos: Vector2) -> void:
	if get_tree().paused:
		return # Let the pause menu receive the tap (via mouse emulation).
	for b in _buttons:
		if pos.distance_to(b.center) <= b.radius * 1.15:
			_owners[index] = b.id
			_pressed[b.id] = true
			_send_action(b.action, true)
			if not b.hold:
				_pending_release.append(b.action)
			_root.queue_redraw()
			return
	var size := _root.get_viewport_rect().size
	if pos.x < size.x * 0.45 and not _owners.values().has("stick"):
		_owners[index] = "stick"
		_update_stick(pos)
	elif not _owners.values().has("look"):
		_owners[index] = "look"


func _touch_up(index: int) -> void:
	var role = _owners.get(index)
	_owners.erase(index)
	if role == null:
		return
	if role == "stick":
		_reset_stick()
	elif role != "look":
		_pressed.erase(role)
		for b in _buttons:
			if b.id == role and b.hold:
				_send_action(b.action, false)
	_root.queue_redraw()


func _update_stick(pos: Vector2) -> void:
	var offset := (pos - _stick_center).limit_length(_stick_radius)
	_stick_knob = _stick_center + offset
	var v := offset / _stick_radius
	if v.length() < 0.12:
		v = Vector2.ZERO
	_set_strength("move_left", maxf(-v.x, 0.0))
	_set_strength("move_right", maxf(v.x, 0.0))
	_set_strength("move_up", maxf(-v.y, 0.0))
	_set_strength("move_down", maxf(v.y, 0.0))
	_root.queue_redraw()


func _set_strength(action: String, s: float) -> void:
	if s > 0.0:
		Input.action_press(action, s)
	else:
		Input.action_release(action)


func _reset_stick() -> void:
	_stick_knob = _stick_center
	for a in MOVE_ACTIONS:
		Input.action_release(a)


func _send_action(action: String, pressed: bool) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	ev.strength = 1.0 if pressed else 0.0
	Input.parse_input_event(ev)


## Releases every touch-held input (focus loss, pause, etc.).
func release_all() -> void:
	for id in _pressed.keys():
		for b in _buttons:
			if b.id == id and b.hold:
				_send_action(b.action, false)
	_pressed.clear()
	_owners.clear()
	_reset_stick()
	_root.queue_redraw()


func _process(_delta: float) -> void:
	if not enabled:
		return
	for a in _pending_release:
		_send_action(a, false)
	_pending_release.clear()
	# The game captures the mouse on start/resume; on touch devices keep the pointer free.
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var hide := get_tree().paused
	if _root.visible == hide:
		_root.visible = not hide
		if hide:
			release_all()


func _notification(what: int) -> void:
	if what in [NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED]:
		if enabled:
			release_all()


func _camera() -> Node:
	var cams := get_tree().get_nodes_in_group("touch_look_camera")
	return cams[0] if cams.size() > 0 else null


func _draw_overlay() -> void:
	var font := ThemeDB.fallback_font
	var white := Color(1, 1, 1, 0.85)
	_root.draw_circle(_stick_center, _stick_radius, Color(0, 0, 0, 0.28))
	_root.draw_arc(_stick_center, _stick_radius, 0, TAU, 48, Color(1, 1, 1, 0.5), 4.0, true)
	_root.draw_circle(_stick_knob, _stick_radius * 0.42, Color(1, 1, 1, 0.55))
	for b in _buttons:
		var on: bool = _pressed.has(b.id)
		_root.draw_circle(b.center, b.radius, Color(1, 0.55, 0.15, 0.75) if on else Color(0, 0, 0, 0.32))
		_root.draw_arc(b.center, b.radius, 0, TAU, 40, white, 3.0, true)
		var fs := int(b.radius * 0.42)
		var tw := font.get_string_size(b.label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		_root.draw_string(font, b.center + Vector2(-tw / 2.0, fs * 0.35), b.label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, white)
