extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const CROUCH_SPEED = 150.0

# Coyote time: permite pular um instante após sair de uma plataforma
const COYOTE_TIME = 0.15
# Jump buffer: registra o pulo se apertado ligeiramente antes de pousar
const JUMP_BUFFER_TIME = 0.1
# Duração dos frames de invencibilidade após tomar dano
const INVINCIBILITY_DURATION = 1.0

@onready var AS = $AnimatedSprite2D

var is_attacking := false
var is_crouching := false
var is_hurt := false
var is_dead := false

var coyote_timer := 0.0
var jump_buffer_timer := 0.0
var invincibility_timer := 0.0

var was_on_floor := false

func _ready() -> void:
	GameManager.player_died.connect(_on_player_died)
	GameManager.hp_changed.connect(_on_hp_changed)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if not is_on_floor():
			velocity += get_gravity() * delta
		move_and_slide()
		return

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Coyote time: conta o tempo desde que saiu do chão
	if was_on_floor and not is_on_floor():
		coyote_timer = COYOTE_TIME
	elif is_on_floor():
		coyote_timer = 0.0
	else:
		coyote_timer -= delta

	was_on_floor = is_on_floor()

	# Jump buffer: registra se o jogador apertou pulo um pouco cedo
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	# Pular: aceita coyote time e jump buffer
	var can_jump = is_on_floor() or coyote_timer > 0.0
	if jump_buffer_timer > 0.0 and can_jump and not is_hurt:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0
		jump_buffer_timer = 0.0

	# Ataque (permitido no chão e no ar)
	if Input.is_action_just_pressed("attack") and not is_hurt:
		attack()

	# Agachar (apenas no chão)
	is_crouching = Input.is_action_pressed("crouch") and is_on_floor()

	# Movimentação horizontal
	var direction := Input.get_axis("move_left", "move_right")
	var current_speed = CROUCH_SPEED if is_crouching else SPEED

	if not is_attacking and not is_hurt:
		if direction > 0:
			AS.flip_h = false
		elif direction < 0:
			AS.flip_h = true

		if direction:
			velocity.x = direction * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# Para o personagem durante ataque ou hurt
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Frames de invencibilidade: efeito de piscar
	if invincibility_timer > 0.0:
		invincibility_timer -= delta
		AS.modulate.a = 0.4 if fmod(invincibility_timer, 0.2) < 0.1 else 1.0
	else:
		AS.modulate.a = 1.0

	move_and_slide()
	handle_animation()

func attack() -> void:
	if is_attacking:
		return
	is_attacking = true
	AS.play("attack")

func take_damage(damage: float) -> void:
	if invincibility_timer > 0.0 or is_dead:
		return
	GameManager.update_hp(-damage)
	invincibility_timer = INVINCIBILITY_DURATION
	if GameManager.current_hp > 0:
		_play_hurt()

func _play_hurt() -> void:
	is_hurt = true
	is_attacking = false
	AS.play("hurt")

func _on_hp_changed(_new_hp: float, _max_hp: float) -> void:
	pass  # Morte tratada pelo sinal player_died

func _on_player_died() -> void:
	is_dead = true
	is_attacking = false
	is_hurt = false
	velocity = Vector2.ZERO
	AS.modulate.a = 1.0
	AS.play("dead")

func handle_animation() -> void:
	if is_dead or is_hurt or is_attacking:
		return

	if is_on_floor():
		if is_crouching:
			AS.play("idle")
		elif velocity.x != 0:
			AS.play("running")
		else:
			AS.play("idle")
	else:
		AS.play("running")

func _on_animated_sprite_2d_animation_finished() -> void:
	if AS.animation == "attack":
		is_attacking = false
	elif AS.animation == "hurt":
		is_hurt = false
	elif AS.animation == "dead":
		# Congela no último frame da animação de morte
		AS.stop()
		AS.frame = AS.sprite_frames.get_frame_count("dead") - 1
