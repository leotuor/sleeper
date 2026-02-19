# playerhud.gd
extends CanvasLayer

@onready var health_points : Label = $Control/HpMarginContainer/NinePatchRect/HealthPoints

func _ready() -> void:
	_update_health_points(GameManager.current_hp, GameManager.max_hp)
	
	GameManager.hp_changed.connect(_update_health_points)

func _update_health_points(hp: float, max_hp: float) -> void:
	health_points.text = "%d / %d" % [hp, max_hp]
