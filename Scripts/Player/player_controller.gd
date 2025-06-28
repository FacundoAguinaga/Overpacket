extends CharacterBody3D

# --- Variables de Movimiento y Estado ---
@export var speed: float = 6.0
@export var acceleration: float = 8.0
@export var friction: float = 10.0
@export var rotation_speed: float = 15.0

@export_group("Throwing")
@export var throw_min_force: float = 10.0
@export var throw_max_force: float = 25.0
@export var throw_charge_time: float = 1.5 # Segundos para carga máxima
@export var throw_angle_degrees: float = 30.0 # Ángulo del lanzamiento en grados

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_state: State
var states: Dictionary = {}

# --- Variables de Interacción ---
@onready var hold_point: Node3D = $holdPoint
@onready var aim_indicator: Node3D = $aimIndicator
var held_item: Grabbable = null
var nearby_grabbables: Array[Grabbable] = []

func _ready() -> void:
	# Guardamos una referencia a cada nodo de estado en nuestro diccionario.
	for state_node in $States.get_children():
		state_node.player = self
		states[state_node.name] = state_node as State
	
	current_state = states["Idle"]
	current_state.enter()


func _physics_process(delta: float) -> void:
	
	# Comprobamos la acción de interactuar usando el singleton global Input.
	# Esto es inmune a los diferentes tipos de eventos.
	if Input.is_action_just_pressed("interact"):
		if held_item:
			drop_item()
		elif not nearby_grabbables.is_empty():
			grab_item()
	
	# Aplicamos gravedad.
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		# Aseguramos que la velocidad Y sea 0 en el suelo para evitar problemas.
		velocity.y = 0

	# Delegamos la lógica de físicas al estado actual.
	var next_state = current_state.process_physics(delta)
	if next_state:
		transition_to(next_state)
	
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	# Delegamos el input al estado actual.
	var next_state = current_state.process_input(event)
	if next_state:
		transition_to(next_state)
		return

func transition_to(next_state: State) -> void:
	if current_state == next_state:
		return
	
	current_state.exit()
	current_state = next_state
	current_state.enter()

func launch_held_item(impulse: Vector3) -> void:
	if not held_item:
		return
	
	# La posición inicial del lanzamiento es donde está el HoldPoint.
	var start_transform = hold_point.global_transform
	
	# Le decimos al objeto que se lance y rompemos el vínculo.
	held_item.launch(start_transform, impulse)
	held_item = null

# --- Funciones de Utilidad y Lógica ---

## Esta función ahora es pública para que los estados puedan acceder a ella.
func get_input_direction() -> Vector3:
	var input_dir_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	return Vector3(input_dir_2d.x, 0, input_dir_2d.y).normalized()

# Las funciones de agarrar, soltar y detectar no cambian.
func grab_item():
	var closest_item = find_closest_grabbable()
	if not closest_item: return
	held_item = closest_item
	nearby_grabbables.erase(held_item)
	held_item.pick_up(hold_point)

func drop_item():
	if not held_item: return
	var drop_position = global_transform.origin + (-global_transform.basis.z * 1.2)
	var drop_transform = Transform3D(Basis(), drop_position)
	held_item.drop(drop_transform)
	held_item = null

func _on_grab_area_body_entered(body: Node3D):
	if body is Grabbable and not nearby_grabbables.has(body):
		nearby_grabbables.append(body)

func _on_grab_area_body_exited(body: Node3D):
	if body is Grabbable and nearby_grabbables.has(body):
		nearby_grabbables.erase(body)

func find_closest_grabbable() -> Grabbable:
	var closest = null
	var min_dist = INF
	for item in nearby_grabbables:
		var dist = global_position.distance_to(item.global_position)
		if dist < min_dist:
			min_dist = dist
			closest = item
	return closest
