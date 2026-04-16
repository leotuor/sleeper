extends Control

@export var menu: VBoxContainer
@export var main_settings: VBoxContainer
@export var video_settings: VBoxContainer
@export var audio_settings: VBoxContainer
@export var controls_settings: VBoxContainer

@export var play_button: Button
@export var settings_button: Button
@export var exit_button: Button
@export var back_button: Button

@export var video_button: Button
@export var audio_button: Button
@export var controls_button: Button

var nav_stack: Array[Control] = []
var current_panel: Control

func _ready():
	current_panel = menu
	_show_panel(menu)
	_update_back_button()

	# Botões principais
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_navigate_to.bind(main_settings))
	exit_button.pressed.connect(_on_exit_pressed)
	back_button.pressed.connect(_on_back_pressed)

	# Submenus
	video_button.pressed.connect(_navigate_to.bind(video_settings))
	audio_button.pressed.connect(_navigate_to.bind(audio_settings))
	controls_button.pressed.connect(_navigate_to.bind(controls_settings))


func _show_panel(panel: Control):
	for p in [menu, main_settings, video_settings, audio_settings, controls_settings]:
		if p:
			p.visible = false
	
	panel.visible = true


func _update_back_button():
	back_button.visible = nav_stack.size() > 0


func _navigate_to(panel: Control):
	if current_panel:
		nav_stack.append(current_panel)

	current_panel = panel
	_show_panel(current_panel)
	_update_back_button()


func _on_back_pressed():
	if nav_stack.is_empty():
		return

	current_panel = nav_stack.pop_back()
	_show_panel(current_panel)
	_update_back_button()


func _on_play_pressed():
	var scene = load("res://stage_scenes/lockerHallwayStage/lockerHallway.tscn")
	get_tree().change_scene_to_packed(scene)


func _on_exit_pressed():
	print("Saindo do jogo...")
	get_tree().quit()
