extends CharacterBody2D

var vida: int = 80

@export var speed: float = 40.0
@export var chase_speed: float = 60.0
@export var gravity: float = 900.0

@onready var anim = $AnimatedSprite2D
@onready var hitbox_shape = $Hitbox/HitboxShape2D
@onready var cooldown_timer = $AttackCooldown
@onready var duration_timer = $AttackDuration

var direction := 1
var jogador_na_area: bool = false
var pode_atacar: bool = true
var atacando: bool = false
var tomando_dano: bool = false
var is_dead: bool = false
var perseguindo_jogador: bool = false
var alvo: Node2D = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead:
		return

	# 3. Estado de Dano (Stun: fica parado sem agir)
	if tomando_dano:
		velocity.x = 0
		move_and_slide()
		return

	# 4. Gatilho de Ataque
	if jogador_na_area and pode_atacar and not atacando:
		iniciar_ataque()

	# 5. Máquina de Estados de Movimento
	if atacando:
		# Trava movimento durante o golpe
		velocity.x = 0
	elif perseguindo_jogador and alvo != null:
		# Persegue o alvo
		var direcao_alvo = sign(alvo.global_position.x - global_position.x)
		if direcao_alvo != 0:
			direction = direcao_alvo
		
		velocity.x = direction * chase_speed
		anim.flip_h = (direction == -1)
		
		if anim.animation != "walk":
			anim.play("walk")
	else:
		# Patrulha livre
		velocity.x = direction * speed
		anim.flip_h = (direction == -1)
		
		if anim.animation != "walk":
			anim.play("walk")
			
		# Inverte direção ao bater na parede apenas durante patrulha
		if is_on_wall():
			direction *= -1

	move_and_slide()

func iniciar_ataque() -> void:
	anim.play("attack")
	pode_atacar = false
	atacando = true
	hitbox_shape.set_deferred("disabled", false)
	duration_timer.start()

func desativar_todas_colisoes(no: Node) -> void:
	for filho in no.get_children():
		if filho is CollisionShape2D:
			filho.set_deferred("disabled", true)
		if filho.get_child_count() > 0:
			desativar_todas_colisoes(filho)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.name == "BeamHitbox":
		tomar_dano(vida)
	
	tomar_dano(20)

func tomar_dano(quantidade: int) -> void:
	if is_dead:
		return
		
	vida -= quantidade
	tomando_dano = true
	
	# Cancela o ataque ativo se tomar dano (Efeito Stun)
	if atacando:
		hitbox_shape.set_deferred("disabled", true)
		atacando = false
		duration_timer.stop()
		cooldown_timer.start()
		
	if vida <= 0:
		is_dead = true
		desativar_todas_colisoes(self)
		anim.play("dead")
		drop_food()
	else:
		anim.play("hurt")

func _on_attack_duration_timeout() -> void:
	hitbox_shape.set_deferred("disabled", true)
	atacando = false
	cooldown_timer.start()

func _on_attack_cooldown_timeout() -> void:
	pode_atacar = true

func _on_attack_range_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		jogador_na_area = true

func _on_attack_range_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		jogador_na_area = false

func _on_chase_range_area_entered(area: Area2D) -> void:
	var pai = area.get_parent()
	if pai.is_in_group("player"):
		perseguindo_jogador = true
		alvo = pai

func _on_chase_range_area_exited(area: Area2D) -> void:
	var pai = area.get_parent()
	if pai.is_in_group("player"):
		perseguindo_jogador = false
		alvo = null

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "hurt":
		tomando_dano = false

func drop_food() -> void:
	var count = randi() % 4
	var steak_scene = preload("res://steak_pickup/steak_pickup_scene.tscn")
	for i in count:
		var steak = steak_scene.instantiate()
		steak.position = position + Vector2(randf_range(-30, 30), 155)
		get_parent().call_deferred("add_child", steak)
