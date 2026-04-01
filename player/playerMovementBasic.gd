extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var AS = $AnimatedSprite2D
@onready var steak = $"../SteakPickup"

# We use these to "lock" the player's state
var is_attacking = false 
var is_using_special = false 

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 1. Trigger the standard attack
	if Input.is_action_just_pressed("attack") and is_on_floor() and not is_using_special:
		attack()

	# 2. Trigger the special ability (Requires a new input action mapped in Project Settings)
	if Input.is_action_just_pressed("special_action") and is_on_floor() and not is_attacking:
		special_ability()

	var direction := Input.get_axis("move_left", "move_right")
	
	# 3. Only allow turning/moving if NOT attacking and NOT using the special ability
	if not is_attacking and not is_using_special:
		if direction > 0:
			AS.flip_h = false
		elif direction < 0:
			AS.flip_h = true
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Stop movement while attacking or using special ability
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	handle_animation()
	special_ability()

func attack():
	is_attacking = true
	AS.play("attack")

# 4. The new special ability function
func special_ability():
	if Input.is_action_just_pressed("special_action"):
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

# 6. Unlock the respective state when its animation finishes
func _on_animated_sprite_2d_animation_finished() -> void:
	if AS.animation == "attack":
		is_attacking = false
	elif AS.animation == "special_ability":
		is_using_special = false
