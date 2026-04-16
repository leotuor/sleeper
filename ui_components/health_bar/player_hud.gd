extends CanvasLayer

@onready var health_points : Label = $Control/HpMarginContainer/NinePatchRect/HealthPoints

# --- ADICIONADO: Referência para a sua nova barra de energia ---
# Certifique-se de que o caminho ($Control/BeamMeter) corresponde exatamente à sua árvore de nós!
@onready var beam_meter : ProgressBar = $BeamMeter

func _ready() -> void:
	_update_health_points(GameManager.current_hp, GameManager.max_hp)
	GameManager.hp_changed.connect(_update_health_points)

func _update_health_points(hp: float, max_hp: float) -> void:
	health_points.text = "%d / %d" % [hp, max_hp]

# --- ADICIONADO: Função que o Player vai chamar para atualizar a barra ---
func update_energy_ui(current_energy: float, max_energy: float) -> void:
	if beam_meter:
		beam_meter.max_value = max_energy
		beam_meter.value = current_energy
