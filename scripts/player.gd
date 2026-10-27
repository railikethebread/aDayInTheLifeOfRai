extends CharacterBody3D


const speed = 5.0
const jump = 4.5
@onready var animator = $personRiggedAnims/AnimationPlayer

var lookdir: Vector2
var looksens = 25
var height = 0.6

func _ready() -> void:
	self.scale = Vector3(height,height,height)
	animator.play("idle")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if velocity == Vector3.ZERO and animator.current_animation != "idle":
		animator.play("idle")
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event.as_text() in ["W","A","S","D"]:
		var input_dir := Input.get_vector("d", "a", "s", "w")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = -direction.x * speed
			velocity.z = -direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		if animator.current_animation != "walkAction":
			animator.play("walkAction")
	#if event.is_action("ui_accept") and is_on_floor():
	#	velocity.y = sqrt(4 * jump)
	
	# https://github.com/rbarongr/GodotFirstPersonController/blob/main/Player/player.gd
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		lookdir = event.relative * 0.001
		rotation.y -= lookdir.x * looksens
		$Camera3D.rotation.x = clamp($Camera3D.rotation.x - lookdir.y * looksens, -1, 1)
		
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
