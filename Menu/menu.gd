extends Control

func _on_play_pressed() -> void:
	GameManager.start_game()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	$Menu.visible = false
	$Settings.visible = true

func _on_back_pressed() -> void:
	$Menu.visible = true
	$Settings.visible = false
	$Video.visible = false
	$Audio.visible = false
	$Controls.visible = false


func _on_video_pressed() -> void:
	pass # Replace with function body.


func _on_audio_pressed() -> void:
	pass # Replace with function body.
