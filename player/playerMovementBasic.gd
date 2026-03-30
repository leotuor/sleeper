extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var AS = $AnimatedSprite2D
@onready var steak = $"../SteakPickup"
var is_attacking = false # This is our "lock"

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 1. Trigger the attack here
	if Input.is_action_just_pressed("attack") and is_on_floor():
		attack()

	var direction := Input.get_axis("move_left", "move_right")
	
	# Only allow turning/moving if not attacking
	if not is_attacking:
		if direction > 0:
			AS.flip_h = false
		elif direction < 0:
			AS.flip_h = true
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Optional: stop movement while attacking
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	handle_animation()
	take_damage(10)

func attack():
	is_attacking = true
	AS.play("attack")

func take_damage(damage):
	if Input.is_action_just_pressed("pick_item_btn"):
		GameManager.update_hp(-damage)



func handle_animation():
	if is_attacking:
		return 

	if is_on_floor():
		if velocity.x != 0:
			AS.play("running")
		else:
			AS.play("idle")
	else:
		AS.play("running")

func _on_animated_sprite_2d_animation_finished() -> void:
	if AS.animation == "attack":
		is_attacking = false
