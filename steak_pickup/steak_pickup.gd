extends Area2D

@onready var AP = $AnimationPlayer
# --- ADICIONADO: Referência ao nó de som ---
@onready var som_pegar = $SomPegar 

func _ready():
	AP.play("steak_hover")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and GameManager.current_hp < 100:
		
		# 1. Desativa o monitoramento para o jogador não pegar o item duas vezes
		set_deferred("monitoring", false)
		
		# 2. Toca o som de pegar o item
		if som_pegar != null:
			som_pegar.play()
		
		var tween = create_tween()
		tween.tween_property(self, "position", position + Vector2(0, -20), 0.3)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		
		GameManager.update_hp(10)
		
		# 3. Espera a animação visual do tween terminar (0.6 segundos no total)
		await tween.finished
		
		# 4. Se o som for mais longo que a animação, espera ele terminar também
		if som_pegar != null and som_pegar.playing:
			await som_pegar.finished
			
		# 5. Deleta o item com segurança
		queue_free()
