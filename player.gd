extends RigidBody2D
@export var engine_power = 500
@export var spin_power = 8000
var thrust = Vector2.ZERO
var rotation_dir = 0
var screensize := Vector2.ZERO
enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = INIT
var size := Vector2.ZERO
var radius := 0.0
func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
		ALIVE: 
			$CollisionShape2D.set_deferred("disabled", false)
		INVULNERABLE: 
			$CollisionShape2D.set_deferred("disabled", true)
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
	state = new_state

func _ready() -> void:
	screensize = get_viewport_rect().size
	size = Vector2(
		$Sprite2D.texture.get_width(),
		$Sprite2D.texture.get_height()
	) * $Sprite2D.scale
	radius = size.x / 2.0
	change_state(ALIVE)

func _process(delta: float) -> void:
	get_input()
	
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")

func _physics_process(delta: float) -> void:
	constant_force = thrust	
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	
	var xform = physics_state.transform	
	xform.origin.x = wrapf(xform.origin.x, -radius, screensize.x+radius)
	xform.origin.y = wrapf(xform.origin.y, -radius, screensize.y+radius)
	physics_state.transform = xform
