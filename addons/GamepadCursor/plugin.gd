@tool
extends EditorPlugin


func _enter_tree():
	add_autoload_singleton("Gamepad_Cursor", "res://addons/GamepadCursor/gamepad_cursor.gd")


func _exit_tree():
	remove_autoload_singleton("Gamepad_Cursor")
