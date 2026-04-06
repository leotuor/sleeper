extends Area2D

@onready var AP = $AnimationPlayer

func _ready():
	AP.play("steak_hover")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and GameManager.current_hp < 100:
		var tween = create_tween()
		
		tween.tween_property(self, "position", position + Vector2(0, -20), 0.3)
		tween.tween_property(self, "modulate:a", 0.0, 0.3)
		
		GameManager.update_hp(10)
		
		tween.tween_callback(self.queue_free)
