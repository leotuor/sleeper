extends CanvasLayer
@onready var resume: Button = $menuholder/resume


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		visible = true
		get_tree().paused = true
		resume.grab_focus()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	visible = false


func _on_quit_pressed() -> void:
	get_tree().quit()
