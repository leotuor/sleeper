extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var AS = $AnimatedSprite2D
@onready var HitboxCollition = $Hitbox/HitboxCollisionShape2D
@onready var steak = $"../SteakPickup"
@onready var camera: Camera2D = $Camera2D

# THIS IS THE MISSING LINK! We need to grab the BeamOrigin node.
@onready var beam_origin = $AnimatedSprite2D/BeamOrigin

# We use these to "lock" the player's state
var is_attacking = false 
var is_using_special = false 
var tomando_dano = false
var morreu = false

# The frame of your animation where the beam should actually appear
var attack_fire_frame : int = 4 # The frame the beam appears
var attack_end_frame : int = 16  # The frame the beam disappears

func _ready() -> void:
	GameManager._transitioning = false
	add_to_group("player")
	AS.frame_changed.connect(_on_animated_sprite_2d_frame_changed)
	camera.limit_left = 0
	camera.limit_right = int(GameManager.get_right_boundary())
	camera.position_smoothing_enabled = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if morreu:
		return
		
	if tomando_dano:
		velocity.x = 0
		move_and_slide()
		AS.play("hurt")
		return

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 1. Trigger the standard attack
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_using_special:
		attack()

	# 2. Trigger the special ability 
	if Input.is_action_just_pressed("special_action") and is_on_floor() and not is_attacking:
		special_ability()

	var direction := Input.get_axis("move_left", "move_right")
	
	if not is_attacking and not is_using_special:
		# If the player is pressing a movement key...
		if direction != 0:
			# Take the current scale, strip any negative signs using abs(), 
			# and multiply it by the direction (which is naturally 1 or -1)
			AS.scale.x = abs(AS.scale.x) * sign(direction)
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Stop movement while attacking or using special ability
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	camera.position.y = 180.0 - global_position.y

	# Right boundary → go to next level
	if global_position.x > GameManager.get_right_boundary():
		GameManager.next_level()
		return

	handle_animation()

func attack():
	is_attacking = true
	HitboxCollition.disabled = false
	AS.play("attack")

# 4. The new special ability function
func special_ability():
	is_using_special = true
	AS.play("special_ability")

func handle_animation():
	# 5. Skip standard animations if EITHER lock is active
	if is_attacking or is_using_special:
		return 

	if is_on_floor():
		if velocity.x != 0:
			AS.play("running")
		else:
			AS.play("idle")
	else:
		AS.play("running")

# --- THIS IS THE BEAM FIRING LOGIC ---

func _on_animated_sprite_2d_frame_changed() -> void:
	if AS.animation == "special_ability":
		# Turn the beam ON when we hit the start frame
		if AS.frame == attack_fire_frame:
			beam_origin.fire_beam()
			
		# Turn the beam OFF when we hit the end frame
		elif AS.frame == attack_end_frame:
			beam_origin.stop_beam()

# 6. Unlock the respective state when its animation finishes
func _on_animated_sprite_2d_animation_finished() -> void:
	if AS.animation == "attack":
		is_attacking = false
		HitboxCollition.disabled = true
	elif AS.animation == "special_ability":
		is_using_special = false
		beam_origin.stop_beam()
	elif AS.animation == "hurt":
		tomando_dano = false
	elif AS.animation == "dead":
		GameManager.go_to_menu()

func _on_hurtbox_area_entered(_area: Area2D) -> void:
	# A configuração de Masks garante que apenas o Enemy Hitbox acione isto
	tomar_dano(20)

func tomar_dano(quantidade: int) -> void:
	# If the player is shooting the laser, ignore the damage entirely and exit this function early.
	if is_using_special:
		return
	# ------------------------------------

	GameManager.update_hp(-quantidade)
	tomando_dano = true
	print(GameManager.current_hp)
	if GameManager.current_hp <= 0 and not morreu:
		morreu = true
		AS.play('dead')
		desativar_todas_colisoes(self)
		
func desativar_todas_colisoes(no: Node) -> void:
	for filho in no.get_children():
		if filho is CollisionShape2D:
			filho.set_deferred("disabled", true)
		if filho.get_child_count() > 0:
			desativar_todas_colisoes(filho)
