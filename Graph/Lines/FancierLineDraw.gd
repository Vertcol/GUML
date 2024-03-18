@tool
extends Control

@onready var nodetree = $"../Nodes"
@export var slide = 0.0
@onready var slider = $"../HSlider"

# Links between nodes
var links = [] 
# Resulting lines from links
var lines = []

func _ready():
	# Add first links for debugging
	var nodes = nodetree.get_children()
	links.push_back({"A": nodes[4],"B": nodes[5], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT, "SlideX": 0.5})
	links.push_back({"A": nodes[4],"B": nodes[6], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT, "SlideX": 0.5})
	links.push_back({"A": nodes[4],"B": nodes[7], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT, "SlideX": 0.5})
	
# Draw every frame
func _process(delta):
	queue_redraw()

func _draw():
	var nodes = nodetree.get_children()
	
	# Draw every link
	for c in links:
		# If one of the nodes is missing, skip
		if c["A"] == null or c["B"] == null:
			continue
		
		# Two nodes in link
		var a: Rect2 = c["A"].get_rect()
		var b: Rect2 = c["B"].get_rect()
		
		# Sides used for link
		# Will be set automatically if null
		var a_side: Vector2 = get_straight(a,b,c["SlideX"])
		var b_side: Vector2 = get_straight(b,a,c["SlideX"])
		
		# TODO: Root node should be the ruling party for slide
		
		# If a side is missing, skip drawing
		if a_side == null or b_side == null:
			continue
			
		draw_line(a_side, b_side, Color.DIM_GRAY, 4.0, true)
		draw_circle(a_side, 5, Color.GRAY)
		draw_circle(b_side, 5, Color.GRAY)
		
func get_straight_root(a: Rect2, link):
	pass

# Checks whether rectangle sides are adjescent
# meaning they can be connected with a straight line
# a_low     
# |      b_low
# |------|
# a_high |
#        b_high
func get_straight(a: Rect2, b: Rect2, slide):
	const m = 32
	const margin = Vector2(m, m)
	
	# Minimal values of x and y
	var a_low = a.position + margin
	var b_low = b.position + margin
	# Maximum values of x and y
	var a_high = a.position + a.size - margin
	var b_high = b.position + b.size - margin
	
	# The low-high range determines the overlap of the two sides
	var low = Vector2(max(a_low.x, b_low.x), max(a_low.y, b_low.y))
	var high = Vector2(min(a_high.x, b_high.x), min(a_high.y, b_high.y))
	
	# Closest side on A to B's center
	var side = get_closest_side(a, b.get_center())

	# If the low-high range is greater than zero, a straight line is possible
	if high.y - low.y > 0:
		side.y = lerp(low.y, high.y, slide)
	elif high.x - low.x > 0:
		side.x = lerp(low.x, high.x, slide)
	
	return side
	
# Return coordinates on the side of a rectangle
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
			
# Returns the closest side coordinate of A relative to the center of B
func get_closest_side(a: Rect2, b: Vector2) -> Vector2:
	var sides = [
		Vector2(a.position.x + a.size.x/2, a.position.y),
		Vector2(a.position.x + a.size.x/2, a.position.y + a.size.y),
		Vector2(a.position.x, a.position.y + a.size.y/2),
		Vector2(a.position.x + a.size.x, a.position.y + a.size.y/2)
	]
	
	# Find side with shortest distance to B
	var smallest_length = 9223372036854775807
	var smallest = null
	for s in sides:
		var length = (s-b).length_squared()
		if length < smallest_length:
			smallest_length = length
			smallest = s

	return smallest
