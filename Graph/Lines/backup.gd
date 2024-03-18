@tool
extends Control

@onready var nodetree = $"../Nodes"
@export var slide = 0.0
@onready var slider = $"../HSlider"

# Connections between nodes
var connections = [] 
# Lines from resulting connections
var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Add first connection, this will be used to draw lines later on
	var nodes = nodetree.get_children()
	connections.push_back({"A": nodes[4],"B": nodes[5], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT})
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _draw():
	var nodes = nodetree.get_children()
	
	# Draw every connection
	for c in connections:
		# Two nodes in connection
		var a: Rect2 = c["A"].get_rect()
		var b: Rect2 = c["B"].get_rect()
		
		# Sides used for connection
		# Will be set automatically if null
		var a_side: Vector2 = get_straight(a,b)
		var b_side: Vector2 = get_straight(b,a)
		
		# If a side is missing, skip drawing
		if a_side == null or b_side == null:
			continue
			
		draw_line(a_side, b_side, Color.DIM_GRAY, 4.0, true)
		draw_circle(a_side, 5, Color.GRAY)
		draw_circle(b_side, 5, Color.GRAY)

# Checks whether rectangle sides are directly adjescent
# meaning they can be connected with a straight line
# a_low     
# |      b_low
# |------|
# a_high |
#        b_high
func get_straight(a: Rect2, b: Rect2):
	const margin = 32
	
	var ay_high = a.position.y + a.size.y - margin 
	var ay_low = a.position.y + margin
	var by_high = b.position.y + b.size.y - margin
	var by_low = b.position.y + margin

	# The range low-high determines where the line may be connected
	var y_high: float = min(ay_high, by_high)
	var y_low: float = max(ay_low, by_low)
	
	# Closed side on A to B's center
	var side: Vector2 = get_closest_side(a, b.get_center())
	
	# If the range is less than zero, a straight connection isn't possible
	if y_high - y_low > 0:
		side.y = lerp(y_low, y_high, slider.value)
		return side
	
	return side
	
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
			
# Returns the coordinates of the side A
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
