extends RigidBody2D
signal lives_changed
signal dead

@export var engine_power := 500
@export var spin_power := 8000
@export var bullet_scene : PackedScene
@export var fire_rate := 0.25
var reset_pos = false
var lives = 0: set = set_lives
var can_shoot := true
var thrust := Vector2.ZERO
var rotation_dir := 0.0
var screensize := Vector2.ZERO
enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state := INIT
var size := Vector2.ZERO
var radius := 0.0

func set_lives(value):
	lives = value
	lives_changed.emit(lives)
	if(lives < 1):
		change_state(DEAD)
	else:
		change_state(INVULNERABLE)

func reset():
	reset_pos = true	
	lives = 3
	change_state(ALIVE)
	$Sprite2D.show()

func change_state(new_state):
	match new_state:
		INIT:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = 0.5
		ALIVE: 
			$CollisionShape2D.set_deferred("disabled", false)
			$Sprite2D.modulate.a = 1.0
			$InvulnerabilityTimer.start()
		INVULNERABLE: 
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2D.modulate.a = 0.5
		DEAD:
			$CollisionShape2D.set_deferred("disabled", true)
			$Sprite2d.hide()
			linear_velocity = Vector2.ZERO
			dead.emit()
	state = new_state

func _ready() -> void:
	$Sprite2D.hide()	
	screensize = get_viewport_rect().size
	size = Vector2(
		$Sprite2D.texture.get_width(),
		$Sprite2D.texture.get_height()
	) * $Sprite2D.scale
	radius = size.x / 2.0
	transform.origin = screensize / 2
	$GunCooldown.wait_time = fire_rate	

func _process(delta: float) -> void:
	get_input()
	
func get_input():
	thrust = Vector2.ZERO
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = transform.x * engine_power
	rotation_dir = Input.get_axis("rotate_left", "rotate_right")		
	if can_shoot and Input.is_action_pressed("shoot"):
		shoot()     

func shoot():
	if state == INVULNERABLE:
		return
	can_shoot = false
	$GunCooldown.start()
	var b = bullet_scene.instantiate()
	get_tree().root.add_child(b)
	b.start($Muzzle.global_transform)

func _physics_process(delta: float) -> void:
	constant_force = thrust	
	constant_torque = rotation_dir * spin_power
	
func _integrate_forces(physics_state):
	if reset_pos:
		physics_state.transform.origin = screensize / 2
		reset_pos = false
		return
	
	var xform = physics_state.transform	
	xform.origin.x = wrapf(xform.origin.x, -radius, screensize.x+radius)
	xform.origin.y = wrapf(xform.origin.y, -radius, screensize.y+radius)
	physics_state.transform = xform


func _on_gun_cooldown_timeout() -> void:
	can_shoot = true


func _on_invulnerability_timer_timeout() -> void:
	change_state(ALIVE)
