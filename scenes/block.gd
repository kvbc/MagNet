class_name Block extends StaticBody2D

@onready var area: Area2D = $Area2D
var collide: bool = true:
	set(v): $CollisionShape2D.disabled = not v
	get: return not $CollisionShape2D.disabled

static func create() -> Block:
	return preload("res://scenes/block.tscn").instantiate()

func is_area_overlapping_any_body() -> bool:
	if not is_node_ready():
		await ready
		
	# idk
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	if area.has_overlapping_bodies():
		var overlapping_bodies = area.get_overlapping_bodies()
		if overlapping_bodies.size() > (1 if self in overlapping_bodies else 0):
			return true
	return false
