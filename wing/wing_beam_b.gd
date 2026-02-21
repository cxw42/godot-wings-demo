## Beam B
extends RigidBody3D

@onready var a_to_b: HingeJoint3D = $"../A to B"

@onready
var current_angle_label: Label = $"../HUD/Control/VBoxContainer/HBoxContainer/CurrentAngleLabel"

@export var Kp: float = 100

@export var desired_angle: float = 0  ## degrees from X towards Y

@export var y_force_min: float = 100
@export var y_force_max: float = 450
@export var y_freq = 0.05

@export var enabled: bool = true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not enabled:
		return

	# Get current angle w.r.t a_to_b
	var base_to_center = (global_position - a_to_b.global_position).normalized()
	var angle = rad_to_deg(atan2(base_to_center.y, base_to_center.x))
	current_angle_label.text = "%.f" % angle
	var difference = desired_angle - angle
	var force = Kp * difference
	# var force = sin(2*PI*y_freq*Time.get_ticks_msec()/1000)
	# force = remap(force, -1, 1, y_force_min, y_force_max)
	#print(force)
	var direction = -transform.basis.x  # global_transform * (Vector3(0,1,1).normalized())
	state.apply_central_force(force * direction)
	%Arrow.global_transform = Transform3D().rotated(
		Vector3(0, 0, -1), direction.angle_to(Vector3(0, 1, 0))
	)
