extends Node2D

@export var beam_frames: Array[Texture2D] # Drag your beam animation frames here in the Inspector
@export var animation_fps: float = 12.0 # Speed of the beam animation

@onready var raycast = $RayCast2D
@onready var body = $BodySprite
@onready var hitbox_shape = $BeamHitbox/CollisionShape2D

@export var fixed_beam_length : float = 800.0 # Change this number to whatever fits your screen!

var max_beam_distance : float = 1200.0
var current_frame_index : float = 0.0

func _ready():
	visible = false
	$BeamHitbox.monitoring = false

func _physics_process(delta):
	if visible:
		update_beam_visuals()
		animate_beam(delta)

# Turns the beam on
func fire_beam():
	visible = true
	$BeamHitbox.monitoring = true
	current_frame_index = 0.0 # Reset animation when fired

# Turns the beam off
func stop_beam():
	visible = false
	$BeamHitbox.monitoring = false

func animate_beam(delta):
	if beam_frames.is_empty(): return
	
	# Manually cycle through the array of textures based on FPS
	current_frame_index += animation_fps * delta
	if current_frame_index >= beam_frames.size():
		current_frame_index = 0.0
		
	# Apply the current frame to the Sprite2D
	body.texture = beam_frames[int(current_frame_index)]

func update_beam_visuals():
	if not body.texture: return
	
	body.centered = false 
	
	# 1. Lock ONLY the X position so it starts at the BeamOrigin
	body.position.x = 0
	
	# (The body.position.y line has been completely removed)
	
	# 2. Stretch the region forward
	body.region_rect = Rect2(0, 0, fixed_beam_length, body.texture.get_size().y)
	
	# 3. Stretch the invisible damage hitbox forward to match
	if hitbox_shape.shape:
		hitbox_shape.shape.size.x = fixed_beam_length
		hitbox_shape.position.x = fixed_beam_length / 2.0
