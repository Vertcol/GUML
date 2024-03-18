extends Panel


var dragging = false

func _gui_input(event):
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT:
			if event.is_pressed():
				dragging = true
				self.grab_focus()
			elif event.is_released():
				dragging = false
	elif event is InputEventMouseMotion:
		if dragging:
			self.position += event.relative
	
	if Input.is_key_pressed(KEY_DELETE):
		if self.has_focus():
			self.free()


@onready var selected_style = load("res://Graph/Elements/GraphNodeHighlight.tres")


func _ready():
	self.remove_theme_stylebox_override("panel")

func _on_focus_entered():
	self.add_theme_stylebox_override("panel",selected_style)

func _on_focus_exited():
	self.remove_theme_stylebox_override("panel")
