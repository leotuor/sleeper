extends Node2D

@onready var boss = $Boss
@onready var boss_hud = $BossHud

func _ready() -> void:
	boss_hud.setup(boss.vida)
	boss.vida_mudou.connect(boss_hud.atualizar)
