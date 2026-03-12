# playerhud.gd
extends CanvasLayer

@onready var health_points: Label = $Control/HpMarginContainer/NinePatchRect/HealthPoints

func _ready() -> void:
	_update_health_points(GameManager.current_hp, GameManager.max_hp)
	GameManager.hp_changed.connect(_update_health_points)
	GameManager.player_died.connect(_on_player_died)

func _update_health_points(hp: float, max_hp: float) -> void:
	health_points.text = "%d / %d" % [hp, max_hp]

func _on_player_died() -> void:
	health_points.text = "0 / %d  —  VOCÊ MORREU" % int(GameManager.max_hp)
