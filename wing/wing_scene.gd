extends Node3D
@onready var b_beam: RigidBody3D = $B
@onready var a_beam: StaticBody3D = $"Base (A)"
@onready var c_beam: RigidBody3D = $C
@onready var d_beam: RigidBody3D = $D
@onready var e_beam: RigidBody3D = $E
@onready var f_beam: RigidBody3D = $F
@onready var a_to_b: HingeJoint3D = $"A to B"
@onready var c_to_d: HingeJoint3D = $"C to D"
@onready var b_to_d: HingeJoint3D = $"B to D"
@onready var a_to_c: HingeJoint3D = $"A to C"
@onready var c_to_e: HingeJoint3D = $"C to E"
@onready var d_to_f: HingeJoint3D = $"D to F"
@onready var e_to_f: HingeJoint3D = $"E to F"

# Lengths of the beams (inches)
var a: float
var b: float
var c: float
var d: float
var e: float
var f: float

# How far along the beams the mid-beam joints are
var along_c_pct: float  ## c->d pctage of the way along C, 0..1
var along_f_pct: float  ## e->f pctage of the way along F, 0..1

#var need_rebuild := false


## Resize a beam having a CSGMesh3D child and a CollisionShape3D child,
## in that order.
func resize_beam_(beam: Node3D, length_m: float):
	if not beam:
		return

	var mesh := beam.get_child(0) as CSGMesh3D
	var box := mesh.mesh as BoxMesh
	box.size.y = length_m

	var collision := beam.get_child(1) as CollisionShape3D
	var shape := collision.shape as BoxShape3D
	shape.size.y = length_m


## inches to meters.  The GUI is in inches.
func i2m(inches: float):
	return inches / 39.37


func rebuild_():
	if not is_inside_tree() or not a_to_b:
		return
	#need_rebuild = false

	# Freeze the nodes so we can move them
	for node in [b_beam, c_beam, d_beam, e_beam, f_beam]:
		node.freeze = true

	var a_m = i2m(a)
	var b_m = i2m(b)
	var c_m = i2m(c)
	var d_m = i2m(d)
	var e_m = i2m(e)
	var f_m = i2m(f)

	# Resize
	resize_beam_(a_beam, a_m)
	resize_beam_(b_beam, b_m)
	resize_beam_(c_beam, c_m)
	resize_beam_(d_beam, d_m)
	resize_beam_(e_beam, e_m)
	resize_beam_(f_beam, f_m)

	if false:  # XXX experiment
		# Reposition the beams and end-of-beam joints, starting from the base (A).
		# Each beam's Y axis extends along the beam, away from A.
		var a_bottom = (
			a_beam.global_position - a_beam.global_basis.y.normalized() * Vector3(0, a_m / 2, 0)
		)
		a_to_b.global_position = a_bottom
		b_beam.global_position = (
			a_bottom + b_beam.global_basis.y.normalized() * Vector3(0, b_m / 2, 0)
		)

		var a_top = (
			a_beam.global_position + a_beam.global_basis.y.normalized() * Vector3(0, a_m / 2, 0)
		)
		a_to_c.global_position = a_top
		c_beam.global_position = a_top + c_beam.global_basis.y.normalized() * Vector3(0, c_m / 2, 0)

		b_to_d.global_position = (
			a_to_b.global_position + b_beam.global_basis.y.normalized() * Vector3(0, b_m, 0)
		)
		d_beam.global_position = (
			b_to_d.global_position + d_beam.global_basis.y.normalized() * Vector3(0, d_m / 2, 0)
		)

		c_to_e.global_position = (
			c_beam.global_position + c_beam.global_basis.y.normalized() * Vector3(0, c_m, 0)
		)
		e_beam.global_position = (
			c_to_e.global_position + e_beam.global_basis.y.normalized() * Vector3(0, e_m / 2, 0)
		)

		d_to_f.global_position = (
			d_beam.global_position + d_beam.global_basis.y.normalized() * Vector3(0, d_m, 0)
		)
		f_beam.global_position = (
			d_to_f.global_position + f_beam.global_basis.y.normalized() * Vector3(0, f_m / 2, 0)
		)

		# Central joints
		c_to_d.global_position = (
			c_beam.global_position
			+ c_beam.global_basis.y.normalized() * Vector3(0, c_m * along_c_pct, 0)
		)
		e_to_f.global_position = (
			f_beam.global_position
			+ f_beam.global_basis.y.normalized() * Vector3(0, f_m * along_f_pct, 0)
		)

	await get_tree().physics_frame

	for node in [b_beam, c_beam, d_beam, e_beam, f_beam]:
		node.freeze = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_desired_angle_value_changed(value: float) -> void:
	b_beam.desired_angle = value


func _on_a_length_value_changed(value: float) -> void:
	a = value
	rebuild_()


func _on_b_length_value_changed(value: float) -> void:
	b = value
	rebuild_()


func _on_c_length_value_changed(value: float) -> void:
	c = value
	rebuild_()


func _on_d_length_value_changed(value: float) -> void:
	d = value
	rebuild_()


func _on_e_length_value_changed(value: float) -> void:
	e = value
	rebuild_()


func _on_f_length_value_changed(value: float) -> void:
	f = value
	rebuild_()


func _on_cto_d_percentage_value_changed(value: float) -> void:
	along_c_pct = value
	rebuild_()


func _on_eto_f_pct_value_changed(value: float) -> void:
	along_f_pct = value
	rebuild_()


func _on_check_box_toggled(toggled_on: bool) -> void:
	b_beam.enabled = toggled_on
