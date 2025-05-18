extends CharacterBody2D

# Variables de movimiento
@export var speed: float = 120.0
@export var jump_force: float = 300.0
@export var gravity: float = 900.0

# Variables de animación
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D  # Referencia a la cámara

var lifes = 3
# Estado del salto
var is_jumping: bool = false

# Variables para el empuje
var push_back_force: float = 200  # Fuerza de empuje reducida a 1/4 (anteriormente 400)
var push_back_duration: float = 0.2  # Duración del empuje en segundos
var push_back_timer: float = 0  # Temporizador para controlar la duración del empuje

func _process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		is_jumping = false
		if velocity.y > 0:
			velocity.y = 0

	# Movimiento horizontal
	var direction: float = Input.get_axis("move_left", "move_right")  
	var run_multiplier: float = 1.35 if Input.is_action_pressed("Run") else 1.0
	
	# Si no estamos en empuje, aplicamos el movimiento normal
	if push_back_timer <= 0:
		velocity.x = direction * speed * run_multiplier
	else:
		pass

	# Animaciones de caminar y predeterminada
	if direction != 0:
		animated_sprite.play("Caminar")  
		animated_sprite.flip_h = direction < 0
		animated_sprite.speed_scale = 1.35 if run_multiplier > 1.0 else 1.0  # Ajusta la velocidad de la animación
	else:
		velocity.x = 0
		animated_sprite.play("Quieto")  
		animated_sprite.speed_scale = 1.0  

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -jump_force
		is_jumping = true
	
	if not is_on_floor():
		animated_sprite.play("Saltar")		

	# Aplicar movimiento
	move_and_slide()

	# Si el temporizador del empuje está activo, lo reducimos
	if push_back_timer > 0:
		push_back_timer -= delta
	else:
		# Si el temporizador se agotó, restauramos el movimiento normal
		velocity.x = 0  # Detenemos el empuje y restauramos el movimiento en X

# Daño Sierra
func _loselife(enemyposx: float) -> void:
	# Aplicar una fuerza de empuje dependiendo de la posición del enemigo
	if position.x < enemyposx:
		velocity.x = -push_back_force  # Empuja hacia la izquierda
	elif position.x > enemyposx:
		velocity.x = push_back_force   # Empuja hacia la derecha
	
	velocity.y = -120  # Impulsa hacia arriba
	
	lifes -= 1
	print("Perdemos vida, vida actual: " + str(lifes))
	
	# Intentar obtener el nodo CanvasLayer de forma más flexible
	var canvasLayer = get_node("/root/Escenario1/CanvasLayer")  # Asumiendo que CanvasLayer está en la escena
	if canvasLayer != null:
		canvasLayer.handleHearts(lifes)
	else:
		print("CanvasLayer no encontrado.")
	
	if lifes <= 0:
		get_tree().reload_current_scene()  # Si se pierde toda la vida, recargar la escena
	
	# Reiniciar el temporizador del empuje
	push_back_timer = push_back_duration
	
# Daño Pinchos
func _on_pinchos_body_entered(body: Node2D) -> void:
	if body.get_name() == "Personaje":
		print("Nos hemos pinchado")
		get_tree().reload_current_scene()  # Recargar la escena si la vida es 0
		pass
