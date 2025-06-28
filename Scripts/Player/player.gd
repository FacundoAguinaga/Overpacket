extends CharacterBody3D

# --- Variables de Movimiento ---
@onready var hold_point: Node3D = $HoldPoint
@export var speed: float = 6.0
@export var acceleration: float = 8.0  # Cuán rápido alcanza la velocidad máxima
@export var friction: float = 10.0      # Cuán rápido frena (más alto = frena más rápido)
@export var rotation_speed: float = 15.0 # Cuán rápido rota el personaje visualmente
var held_item: Grabbable = null
var nearby_grabbables: Array[Grabbable] = []
# Obtenemos la gravedad definida en la configuración del proyecto.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta: float) -> void:
	# --- 1. Obtener Input del Jugador ---
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")

	# --- 2. Calcular la Dirección en el Mundo 3D ---
	# Creamos un vector de dirección basado en los ejes del MUNDO, no del personaje.
	# El input 'Y' (forward/backward) se mapea al eje Z del mundo.
	# El input 'X' (left/right) se mapea al eje X del mundo.
	# Ya NO lo multiplicamos por "transform.basis". Esta es la corrección clave.
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()

	# --- 3. Aplicar Gravedad ---
	# Siempre es importante asegurarse de que la gravedad se aplique.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# --- 4. Calcular la Velocidad (Aceleración y Fricción) ---
	# Guardamos la velocidad vertical actual para no perderla.
	var vertical_velocity = velocity.y
	
	# Creamos un vector de velocidad horizontal objetivo.
	var target_velocity = Vector3(direction.x, 0, direction.z) * speed
	
	# Usamos lerp (interpolación lineal) para mover suavemente la velocidad actual hacia el objetivo.
	# Esto crea una aceleración y deceleración (fricción) muy fluidas.
	var current_horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	if direction != Vector3.ZERO:
		# Si hay input, aceleramos
		current_horizontal_velocity = current_horizontal_velocity.lerp(target_velocity, delta * acceleration)
	else:
		# Si no hay input, frenamos (aplicamos fricción)
		current_horizontal_velocity = current_horizontal_velocity.lerp(Vector3.ZERO, delta * friction)

	# Combinamos la velocidad horizontal calculada con la vertical
	velocity = current_horizontal_velocity + Vector3(0, vertical_velocity, 0)
	
	# --- 5. Rotar el Personaje Visualmente ---
	# El personaje rota para mirar en la dirección en la que se está moviendo.
	# Esto ahora está separado de la lógica de movimiento.
	if direction != Vector3.ZERO:
		var new_transform = transform.looking_at(global_position + direction, Vector3.UP)
		transform.basis = transform.basis.slerp(new_transform.basis, delta * rotation_speed)

	move_and_slide()
