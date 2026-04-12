extends CanvasLayer

@onready var bar: ProgressBar = $Control/ProgressBar
@onready var label: Label = $Control/Label

func setup(max_vida: int) -> void:
	bar.max_value = max_vida
	bar.value = max_vida
	visible = true

func atualizar(vida_atual: int) -> void:
	bar.value = vida_atual
	if vida_atual <= 0:
		visible = false
