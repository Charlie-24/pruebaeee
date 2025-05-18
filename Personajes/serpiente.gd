extends CharacterBody2D 

@export var speed: float = 40.0
@export var gravity: float = 900.0
var moving_left = true
var can_turn = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_ray: RayCast2D = $RayCast2D

func _ready():
	animated_sprite.play("Caminar")

func _physics_process(delta: float) -> void:
	move_character()
	check_edge()

func move_character():
	velocity.y += gravity
	velocity.x = -speed if moving_left else speed
	move_and_slide()

	# Voltear el sprite según la dirección
	animated_sprite.flip_h = moving_left

func check_edge():
	if not ground_ray.is_colliding() and can_turn:
		moving_left = !moving_left

		# Reposicionar el RayCast al otro lado
		ground_ray.position.x *= -1

		can_turn = false
		await get_tree().create_timer(0.2).timeout
		can_turn = true

func _loselife(enemyposx: float) -> void:
	pass
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body._loselife(position.x)
		pass
