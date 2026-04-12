extends VBoxContainer

@export var resolution_option: OptionButton
@export var fullscreen_check: CheckBox
@export var borderless_check: CheckBox
@export var vsync_check: CheckBox

func _ready():
	var resolutions = [
		Vector2i(1280, 900),
		Vector2i(640, 360)
	]

	# Adiciona as resoluções
	for res in resolutions:
		resolution_option.add_item("%dx%d" % [res.x, res.y])

	# Carrega configurações atuais
	load_current_settings()

	# Conecta os sinais (APENAS UMA VEZ)
	resolution_option.item_selected.connect(_on_resolution_selected)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	borderless_check.toggled.connect(_on_borderless_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)


func load_current_settings():
	var mode = DisplayServer.window_get_mode()
	fullscreen_check.button_pressed = mode == DisplayServer.WINDOW_MODE_FULLSCREEN
	
	borderless_check.button_pressed = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	
	vsync_check.button_pressed = DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	
	var window_size = DisplayServer.window_get_size()
	for i in range(resolution_option.item_count):
		var res_text = resolution_option.get_item_text(i)
		var parts = res_text.split("x")
		if parts.size() == 2 and int(parts[0]) == window_size.x and int(parts[1]) == window_size.y:
			resolution_option.select(i)
			break


func _on_resolution_selected(index: int):
	var text = resolution_option.get_item_text(index)
	var parts = text.split("x")
	if parts.size() == 2:
		DisplayServer.window_set_size(Vector2i(int(parts[0]), int(parts[1])))


func _on_fullscreen_toggled(enabled: bool):
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_borderless_toggled(enabled: bool):
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, enabled)


func _on_vsync_toggled(enabled: bool):
	var mode = DisplayServer.VSYNC_ENABLED if enabled else DisplayServer.VSYNC_DISABLED
	DisplayServer.window_set_vsync_mode(mode)
