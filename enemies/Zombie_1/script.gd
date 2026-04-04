extends CharacterBody2D

var vida: int = 100

@export var speed: float = 40.0
@export var gravity: float = 900.0

@onready var anim = $AnimatedSprite2D
@onready var hitbox_shape = $Hitbox/HitboxShape2D
@onready var cooldown_timer = $AttackCooldown
@onready var duration_timer = $AttackDuration

var direction := 1
var jogador_na_area: bool = false
var pode_atacar: bool = true
var atacando: bool = false
var is_dead: bool = false

func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta

	if jogador_na_area and pode_atacar:
		iniciar_ataque()

	if atacando:
		velocity.x = 0
	else:
		velocity.x = direction * speed
		if anim.animation != "walk":
			anim.play("walk")

	move_and_slide()

	if is_on_wall() and not atacando:
		direction *= -1
		anim.flip_h = (direction == -1)

func iniciar_ataque() -> void:
	anim.play("attack")
	pode_atacar = false
	atacando = true
	hitbox_shape.disabled = false
	duration_timer.start()

func _on_hurtbox_area_entered(area: Area2D) -> void:
	tomar_dano(20)

func tomar_dano(quantidade: int) -> void:
	vida -= quantidade
	if vida <= 0 and not is_dead:
		is_dead = true
		anim.play("dead")

func _on_attack_duration_timeout() -> void:
	hitbox_shape.disabled = true
	atacando = false
	cooldown_timer.start()

func _on_attack_cooldown_timeout() -> void:
	pode_atacar = true


func _on_attack_range_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "player":
		jogador_na_area = true

func _on_attack_range_area_exited(area: Area2D) -> void:
	if area.get_parent().name == "player":
		jogador_na_area = false
