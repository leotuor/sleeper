extends CharacterBody2D

@export var speed: float = 40.0
@export var gravity: float = 900.0

@onready var anim = $AnimatedSprite2D

var direction := 1


func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta

	velocity.x = direction * speed

	move_and_slide()

	if is_on_wall():
		direction *= -1

		if direction == -1:
			anim.flip_h = true
		else:
			anim.flip_h = false

	if anim.animation != "walk":
		anim.play("walk")
