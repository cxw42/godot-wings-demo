## Beam B
extends RigidBody3D

@onready
var current_angle_label: Label = $"../HUD/Control/VBoxContainer/HBoxContainer/CurrentAngleLabel"

@export var Kp: float = 50

@export var Kd: float = 5

@export var Ki: float = 5

@export var desired_angle: float = 0  ## degrees from X towards Y

@export var y_force_min: float = 100
@export var y_force_max: float = 450
@export var y_freq = 0.05

@export var enabled: bool = true


func _physics_process(_delta: float) -> void:
	if not enabled:
		return

	# Get current angle w.r.t. the X axis.  Negate to get positive rotation around +Z
	var angle: float = rad_to_deg(
		-global_transform.basis.y.signed_angle_to(Vector3.RIGHT, Vector3.BACK)
	)
	current_angle_label.text = "%.f" % angle
	var difference: float = desired_angle - angle
	#prints(angle, difference)
	var force: float = control_law_(difference)
	force = clampf(force, -y_force_max, y_force_max)
	# var force = sin(2*PI*y_freq*Time.get_ticks_msec()/1000)
	# force = remap(force, -1, 1, y_force_min, y_force_max)
	#print(force)
	var direction := -transform.basis.x  # global_transform * (Vector3(0,1,1).normalized())
	apply_central_force(force * direction)
	#%Arrow.global_transform = Transform3D().rotated(Vector3(0,0,-1), direction.angle_to(Vector3(0,1,0)))


var last_error_ := 0.0
var accum_error_ := 0.0


## Return the force to be applied
func control_law_(error: float) -> float:
	accum_error_ += error
	var result := (error * Kp) + ((error - last_error_) * Kd)
	if abs(accum_error_) > 1:
		result += accum_error_ * Ki
	return result
