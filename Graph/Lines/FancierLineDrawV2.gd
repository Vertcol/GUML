@tool
extends Control

@onready var nodetree = $"../Nodes"
@export var slide = 0.0
@onready var slider = $"../HSlider"

@export var margin = 32

# Links between nodes
var links = [] 
# Resulting lines from links
var lines = []

func _ready():
	# Add first links for debugging
	# A is parent, B is child
	var nodes = nodetree.get_children()
	links.push_back({"A": nodes[4],"B": nodes[5], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT, "SlideX": 1.0, "SlideY": 1.0})
	links.push_back({"A": nodes[4],"B": nodes[6], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT, "SlideX": 1.0, "SlideY": 1.0})
	links.push_back({"A": nodes[4],"B": nodes[7], "DirA": SIDE_RIGHT, "DirB": SIDE_LEFT, "SlideX": 1.0, "SlideY": 1.0})
	
# Draw every frame
func _process(delta):
	queue_redraw()

func _draw():
	var nodes = nodetree.get_children()
	
	# Draw every link
	for link in links:
		# If one of the nodes is missing, skip
		if link["A"] == null or link["B"] == null:
			continue
			
		# Get a line from the link
		var line = get_line(link)
		var line_packed = PackedVector2Array(line)
		
		# Draw it
		draw_polyline(line_packed, Color.DIM_GRAY, 4.0, true)
	
		draw_circle(line[0], 5, Color.GRAY)
		draw_circle(line[-1], 5, Color.GRAY)
		
		var parent = line[0] + line[0].direction_to(line[1]).rotated(-45)*Vector2(32,16)
		draw_string(ThemeDB.fallback_font, parent, "1", HORIZONTAL_ALIGNMENT_CENTER)
		
		var child = line[-1] + line[-1].direction_to(line[-2]).rotated(45)*Vector2(32,16)
		draw_string(ThemeDB.fallback_font, child, "*", HORIZONTAL_ALIGNMENT_CENTER)


# Generates line that checks whether rectangle sides are adjescent
# meaning they can be connected with a straight line
# a_low     
# |      b_low
# |------|
# a_high |
#        b_high		
func get_line(link):	
	var a: Rect2 = link["A"].get_rect()
	var b: Rect2 = link["B"].get_rect()
	
	var marginv = Vector2(margin, margin)
	
	# Minimal values of x and y
	var a_low = a.position + marginv
	var b_low = b.position + marginv
	# Maximum values of x and y
	var a_high = a.position + a.size - marginv
	var b_high = b.position + b.size - marginv
	
	# The low-high range determines the overlap of the two sides
	var low = Vector2(max(a_low.x, b_low.x), max(a_low.y, b_low.y))
	var high = Vector2(min(a_high.x, b_high.x), min(a_high.y, b_high.y))
	
	# Closest side on A to B's center
	var a_side = get_closest_side(a, b.get_center())
	var b_side = get_closest_side(b, a.get_center())

	# If the low-high range is greater than zero, a straight line is possible
	if high.y - low.y > 0:
		var y = lerp(low.y, high.y, slider.value) # link["SlideY"]
		a_side.y = y
		b_side.y = y
	elif high.x - low.x > 0:
		var x = lerp(low.x, high.x, slider.value) # link["SlideX"]
		a_side.x = x
		b_side.x = x
	
	return [a_side, b_side]

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
