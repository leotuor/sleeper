extends Area2D

const HEAL_AMOUNT = 25.0

func _on_body_entered(body: Node2D) -> void:
	# Verifies if the body colided
	if not body.has_method("take_damage"):
		return

	# Heals the user
	if GameManager.current_hp >= GameManager.max_hp:
		return
	GameManager.update_hp(HEAL_AMOUNT)
	queue_free()
