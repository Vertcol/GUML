extends TextEdit

@onready var box = $".."
@onready var label = $"../Label"

func _input(event):
	if Input.is_key_pressed(KEY_ENTER):
		if self.has_focus():
			release_focus()

func _on_focus_exited():
	print(self.text)
	if self.text.length() > 0:
		label.text = self.text
	else:
		label.text = "Title"
		
	self.hide()
	label.show()
	
