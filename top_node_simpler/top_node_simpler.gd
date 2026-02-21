extends Node3D
@onready var a_beam: StaticBody3D = $"Base (A)"
@onready var b_beam: RigidBody3D = $B
@onready var a_to_b: HingeJoint3D = $"A to B"

@onready var a_length: HBoxContainer = $"HUD/Control/VBoxContainer/A Length (inches)"
@onready var b_length: HBoxContainer = $"HUD/Control/VBoxContainer/B Length (inches)"

# Lengths of the beams (inches)
var a: float
var b: float

var need_rebuild := false


func _ready() -> void:
	prints("ready", ((a_beam.get_child(1) as CollisionShape3D).shape as BoxShape3D).size.y)
	a = m2i(((a_beam.get_child(1) as CollisionShape3D).shape as BoxShape3D).size.y)
	a_length.value = a
	b = m2i(((b_beam.get_child(1) as CollisionShape3D).shape as BoxShape3D).size.y)
	b_length.value = b
	a_length.enabled = true
	b_length.enabled = true


#func _process(_delta: float) -> void:
#    prints("process", ((a_beam.get_child(1) as CollisionShape3D).shape as BoxShape3D).size.y)


## Resize a beam having a CSGMesh3D child and a CollisionShape3D child,
## in that order.
func resize_beam_(beam: Node3D, length_m: float, minus_y_global_position: Vector3) -> Node3D:
	if not beam:
		return null

	# Create a new beam with the new size
	var new_beam := beam.duplicate()

	var mesh := new_beam.get_child(0) as CSGMesh3D
	var box := mesh.mesh as BoxMesh
	box.size.y = length_m

	var collision := new_beam.get_child(1) as CollisionShape3D
	var shape := collision.shape as BoxShape3D
	shape.size.y = length_m

	# Add and position the new beam
	beam.get_parent().add_child(new_beam)
	new_beam.global_position = (
		minus_y_global_position + new_beam.global_basis.y.normalized() * length_m / 2
	)

	# Remove the old beam.  The caller is responsible for updating references
	# to point to the new beam.
	beam.get_parent().remove_child(beam)
	beam.queue_free()

	return new_beam


## inches to meters.  The GUI is in inches.
func i2m(inches: float):
	return inches / 39.37


func m2i(meters: float):
	return meters * 39.37


func rebuild_():
	var a_m = i2m(a)
	var b_m = i2m(b)

	# Resize
	a_beam = resize_beam_(a_beam, a_m, a_to_b.global_position)
	b_beam = resize_beam_(b_beam, b_m, a_to_b.global_position)
	a_to_b.node_a = a_beam.get_path()
	a_to_b.node_b = b_beam.get_path()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_desired_angle_value_changed(value: float) -> void:
	b_beam.desired_angle = value


func _on_a_length_value_changed(value: float) -> void:
	prints("a length changed", value)
	a = value
	need_rebuild = true


func _on_b_length_value_changed(value: float) -> void:
	prints("b length changed", value)
	b = value
	need_rebuild = true


func _on_check_box_toggled(toggled_on: bool) -> void:
	b_beam.enabled = toggled_on


func _physics_process(_delta: float) -> void:
	if need_rebuild:
		rebuild_()
		need_rebuild = false
