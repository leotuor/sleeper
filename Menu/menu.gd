extends Control

func _on_play_pressed() -> void:
	GameManager.start_game()


func _on_exit_pressed() -> void:
	get_tree().quit()
