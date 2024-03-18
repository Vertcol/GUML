@tool
extends Control

@onready var nodetree = $"../Nodes"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _draw():
	var nodes = nodetree.get_children()
	
	for i in range(nodes.size()-1):
		var start = nodes[i].get_rect().get_center()
		var end = nodes[i+1].get_rect().get_center()
		draw_line(start, end, Color.DIM_GRAY, 4.0, true)
