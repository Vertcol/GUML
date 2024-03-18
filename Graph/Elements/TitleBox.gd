extends Panel

@onready var parent = $"../.."
@onready var label = $"Label"
@onready var text_edit = $"TextEdit"

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.double_click:
			label.hide()
			text_edit.show()
			text_edit.grab_focus()
			return
			
	parent._gui_input(event)
		
		
