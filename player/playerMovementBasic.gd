extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var AS = $AnimatedSprite2D
@onready var steak = $"../SteakPickup"

# THIS IS THE MISSING LINK! We need to grab the BeamOrigin node.
@onready var beam_origin = $AnimatedSprite2D/BeamOrigin

# We use these to "lock" the player's state
var is_attacking = false 
var is_using_special = false 

# The frame of your animation where the beam should actually appear
var attack_fire_frame : int = 4 # The frame the beam appears
var attack_end_frame : int = 16  # The frame the beam disappears

func _ready() -> void:
	add_to_group("player")
	AS.frame_changed.connect(_on_animated_sprite_2d_frame_changed)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

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
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Stop movement while attacking or using special ability
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	# Right boundary → go to next level
	if global_position.x > GameManager.get_right_boundary():
		GameManager.next_level()
		return

	handle_animation()

func attack():
	is_attacking = true
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


# --- THIS IS THE NEW BEAM FIRING LOGIC ---

# This triggers every single time the animation moves to a new frame
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
	elif AS.animation == "special_ability":
		is_using_special = false
		beam_origin.stop_beam() # This turns the beam off when the animation ends
