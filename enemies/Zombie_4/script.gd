extends CharacterBody2D

var vida: int = 150

@export var speed: float = 40.0
@export var chase_speed: float = 60.0
@export var gravity: float = 900.0
@export var attack_strike_frame: int = 7

@onready var anim = $AnimatedSprite2D
@onready var hitbox_shape = $Hitbox/HitboxShape2D
@onready var cooldown_timer = $AttackCooldown
@onready var duration_timer = $AttackDuration
@onready var screen_notifier = $VisibleOnScreenNotifier2D
@onready var stun_timer = $StunTimer

# --- ADICIONADO: Referências aos nós de áudio ---
@onready var som_zumbi = $AudioStreamPlayer2D
@onready var som_morte = $SomMorte # <-- ADICIONADO: Referência para o som de morte

var em_stun: bool = false
var direction := 1
var jogador_na_area: bool = false
var pode_atacar: bool = true
var atacando: bool = false
var tomando_dano: bool = false
var is_dead: bool = false
var perseguindo_jogador: bool = false
var alvo: Node2D = null


# --- ADICIONADO: Função _ready para configurar o loop do som (4 segundos) ---
func _ready() -> void:
	var timer_som = Timer.new()
	timer_som.wait_time = 4.0 # Intervalo alterado para 4 segundos
	timer_som.autostart = true
	timer_som.timeout.connect(_on_timer_som_timeout)
	add_child(timer_som)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_dead:
		return

	# 3. Estado de Dano (Stun: fica parado sem agir)
	if tomando_dano or em_stun:
		velocity.x = 0
		move_and_slide()
		
		if not tomando_dano and anim.animation != "idle" and not is_dead:
			anim.play("idle")
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
	if area.name == "BeamHitbox" && screen_notifier.is_on_screen():
		tomar_dano(vida) #Instant Kill
	
	tomar_dano(20)

func tomar_dano(quantidade: int) -> void:
	if is_dead:
		return
		
	vida -= quantidade
	tomando_dano = true
	em_stun = true
	stun_timer.start(0.6)
	
	# Cancela o ataque ativo se tomar dano (Efeito Stun)
	if atacando:
		hitbox_shape.set_deferred("disabled", true)
		atacando = false
		duration_timer.stop()
		cooldown_timer.start()
		
	if vida <= 0:
		is_dead = true
		em_stun = false # Garante que o morto não rode lógica de stun
		desativar_todas_colisoes(self)
		anim.play("dead")
		
		# <-- ADICIONADO: Toca o som de morte
		if som_morte != null:
			som_morte.play()
			
		drop_food()
	else:
		anim.play("hurt")

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
	elif anim.animation == "attack":
		hitbox_shape.set_deferred("disabled", true)
		atacando = false
		cooldown_timer.start()

func drop_food() -> void:
	var count = randi() % 4
	var steak_scene = preload("res://steak_pickup/steak_pickup_scene.tscn")
	for i in count:
		var steak = steak_scene.instantiate()
		steak.position = position + Vector2(randf_range(-30, 30), 155)
		get_parent().call_deferred("add_child", steak)
		
func _on_animated_sprite_2d_frame_changed() -> void:
	if anim.animation == "attack" and anim.frame == attack_strike_frame:
		hitbox_shape.set_deferred("disabled", false)
		
func _on_stun_timer_timeout() -> void:
	em_stun = false

# --- ADICIONADO: Função chamada a cada 4 segundos ---
func _on_timer_som_timeout() -> void:
	# Toca o som apenas se o inimigo não estiver morto
	if not is_dead and som_zumbi != null:
		som_zumbi.play()
