extends Node

var max_hp : float = 100.0
var current_hp : float = 100.0

signal hp_changed(new_hp, max_hp)

# --- Level Management ---
var current_level_index: int = 0
var _transitioning: bool = false

var levels: Array = [
	{
		"scene": "res://stage_scenes/playground(tests)/playground.tscn",
		"right_boundary": 635.0
	},
	{
		"scene": "res://stage_scenes/lockerHallwayStage/lockerHallway.tscn",
		"right_boundary": 2740.0
	},
	{
		"scene": "res://stage_scenes/corredorStage/corredor.tscn",
		"right_boundary": 2740.0
	},
	{
		"scene": "res://stage_scenes/salaDeAulaStage/salaDeAula.tscn",
		"right_boundary": 2740.0
	},
]

func _ready() -> void:
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.autostart = true
	timer.timeout.connect(_auto_heal)
	add_child(timer)

func _auto_heal() -> void:
	if current_hp > 0 and current_hp < max_hp:
		update_hp(1.0)

func update_hp(amount: float):
	current_hp += amount
	current_hp = clamp(current_hp, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)

func get_right_boundary() -> float:
	return levels[current_level_index]["right_boundary"]

func start_game() -> void:
	current_level_index = 0
	current_hp = max_hp
	_transitioning = false
	get_tree().change_scene_to_file(levels[0]["scene"])

func go_to_menu() -> void:
	current_level_index = 0
	current_hp = max_hp
	_transitioning = false
	get_tree().change_scene_to_file("res://Menu/menu.tscn")

func next_level() -> void:
	if _transitioning:
		return
	_transitioning = true
	if current_level_index >= levels.size() - 1:
		go_to_menu()
	else:
		current_level_index += 1
		get_tree().change_scene_to_file(levels[current_level_index]["scene"])
