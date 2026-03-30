extends Node

var max_hp : float = 100.0
var current_hp : float = 100.0

signal hp_changed(new_hp, max_hp)

func update_hp(amount: float):
	current_hp += amount
	current_hp = clamp(current_hp, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)
