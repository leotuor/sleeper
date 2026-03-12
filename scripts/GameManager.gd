extends Node

var max_hp: float = 100.0
var current_hp: float = 100.0

var score: int = 0

signal hp_changed(new_hp, max_hp)
signal player_died

func update_hp(amount: float) -> void:
	current_hp += amount
	current_hp = clamp(current_hp, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		player_died.emit()

func add_score(points: int) -> void:
	score += points

func reset() -> void:
	current_hp = max_hp
	score = 0
	hp_changed.emit(current_hp, max_hp)
