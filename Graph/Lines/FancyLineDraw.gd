@tool
extends Control

#@onready var r1 = $"../R1"
#@onready var r2 = $"../R2"

@onready var nodetree = $"../Nodes"

# Connections between nodes
var connections = [] 
# Lines from resulting connections
var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add first connection, this will be used to draw lines later on
	var nodes = nodetree.get_children()
	connections.push_back({"A": nodes[0],"B": nodes[1], "DirA": null, "DirB": null})
	connections.push_back({"A": nodes[2],"B": nodes[3], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT})
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _draw():
	var nodes = nodetree.get_children()
	
	# Draw every connection
	for c in connections:
		# If one of the nodes is missing, skip
		if c["A"] == null or c["B"] == null:
			continue
		
		# Two nodes in connection
		var a: Rect2 = c["A"].get_rect()
		var b: Rect2 = c["B"].get_rect()
		
		# Sides used for connection
		var a_side: Vector2
		var b_side: Vector2
		
		# Use closest if no direction is specified
		if c["DirA"] != null:
			a_side = get_rect_side(a, c["DirA"])
		else:
			a_side = get_closest_side(a,b.get_center())
			
		if c["DirB"] != null:
			b_side = get_rect_side(b, c["DirB"])
		else:
			b_side = get_closest_side(b,a.get_center())
			
		draw_line(a_side, b_side, Color.DIM_GRAY, 4.0, true)
		draw_circle(a_side, 5, Color.GRAY)
		draw_circle(b_side, 5, Color.GRAY)


# Return coordinates on the side of a rect
func get_rect_side(a: Rect2, side) -> Vector2:
	match side:
		SIDE_TOP:
			return Vector2(a.position.x + a.size.x/2, a.position.y)
		SIDE_BOTTOM:
			return Vector2(a.position.x + a.size.x/2, a.position.y + a.size.y)
		SIDE_LEFT:
			return Vector2(a.position.x, a.position.y + a.size.y/2)
		SIDE_RIGHT:
			return Vector2(a.position.x + a.size.x, a.position.y + a.size.y/2)
		_:
			return a.get_center()
			
# Returns the coordinates of the side a 
func get_closest_side(a: Rect2, b: Vector2) -> Vector2:
	var sides = [
		Vector2(a.position.x + a.size.x/2, a.position.y),
		Vector2(a.position.x + a.size.x/2, a.position.y + a.size.y),
		Vector2(a.position.x, a.position.y + a.size.y/2),
		Vector2(a.position.x + a.size.x, a.position.y + a.size.y/2)
	]
	
	# Find side with shortest distance to node
	var smallest_length = 9223372036854775807
	var smallest = null
	for s in sides:
		var length = (s-b).length_squared()
		if length < smallest_length:
			smallest_length = length
			smallest = s

	return smallest
