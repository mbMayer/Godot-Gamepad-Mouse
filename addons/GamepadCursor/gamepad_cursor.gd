@icon("res://addons/GamepadCursor/icon.png")
extends Node

@export_group("Visual")
@export var custom_cursor_normal = load("res://addons/GamepadCursor/dry-clean.png")
@export var custom_cursor_pressed = load("res://addons/GamepadCursor/dry-clean-pressed.png")
@export_group("Action")
@export var action_button = JOY_BUTTON_A
@export var mouse_sens: float = 400.0

var tex: ImageTexture
var scale_factor: float

var time_pressed_start: float
var time_pressed_end: float

enum CursorShapes {
	CURSOR_ARROW,
	CURSOR_BDIAGSIZE,
	CURSOR_BUSY,
	CURSOR_CAN_DROP,
	CURSOR_CROSS,
	CURSOR_DRAG,
	CURSOR_FDIAGSIZE,
	CURSOR_FORBIDDEN,
	CURSOR_HELP,
	CURSOR_HSIZE,
	CURSOR_HSPLIT,
	CURSOR_IBEAM,
	CURSOR_MOVE,
	CURSOR_POINTING_HAND,
	CURSOR_VSIZE,
	CURSOR_VSPLIT,
	CURSOR_WAIT
}

func _ready():
	get_tree().get_root().size_changed.connect(resize)
	resize()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)


func resize():
	scale_factor = min(float(get_viewport().size.x) / get_viewport().get_visible_rect().size.x, float(get_viewport().size.y) / get_viewport().get_visible_rect().size.y)


func _set_cursor(type: Texture2D):
	if type == null:
		tex = null
		for i in CursorShapes:
			Input.set_custom_mouse_cursor(tex, Input[i])
	else:
		var img: Image = type.get_image()
		var size := Vector2(128, 128) * (scale_factor/2)
		img.resize(int(size.x), int(size.y))
		tex = ImageTexture.create_from_image(img)
		var hotspot := Vector2(64, 64) * (scale_factor/2)
		for i in CursorShapes:
			Input.set_custom_mouse_cursor(tex, Input[i], hotspot)

func _process(delta):
	var direction := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if abs(direction.x) == 1 and abs(direction.y) == 1:
		direction = direction.normalized()
	var movement = mouse_sens * direction * delta
	if movement:
		get_viewport().warp_mouse(get_viewport().get_mouse_position() + movement)

func _input(event):
	if event is InputEventJoypadButton and event.device == 0 and event.button_index == action_button:
		var pressed = event.is_pressed()
		var JoyClick := InputEventMouseButton.new()
		JoyClick.button_index = MOUSE_BUTTON_LEFT
		JoyClick.position = get_viewport().get_final_transform().basis_xform_inv(get_viewport().get_mouse_position())
		JoyClick.pressed = pressed
		Input.parse_input_event(JoyClick)

		if pressed:
			_set_cursor(custom_cursor_pressed)
			time_pressed_start = Time.get_ticks_msec()
			
		else:
			_set_cursor(custom_cursor_normal)
			time_pressed_end = Time.get_ticks_msec()
			var time_pressed := float(time_pressed_end - time_pressed_start) / 1000.0
			print("Время нажатия кнопки: ", time_pressed, "секунд")

	if event is InputEventKey and event.is_pressed():
		if event.physical_keycode:
			_set_cursor(null)
