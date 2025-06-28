extends Node3D

# --- Variables de Seguimiento de Posición ---
# Especificamos que el target es un CharacterBody3D para acceder a su velocidad de forma segura.
@export var target: CharacterBody3D

@export var smoothness: float = 5.0
@export var vertical_offset: float = 2.0

# --- NUEVAS: Variables de Zoom Dinámico ---
# Usa @export_group para organizar las variables en el Inspector. ¡Muy útil!
@export_group("Dynamic Zoom")
@export var idle_zoom_distance: float = 8.0   # Distancia de la cámara cuando está quieto.
@export var running_zoom_distance: float = 12.0 # Distancia de la cámara cuando corre.
@export var zoom_smoothness: float = 3.0    # Suavidad de la transición del zoom.

# --- Referencia al Nodo Hijo ---
# Esto obtiene el nodo SpringArm3D para que podamos controlar su longitud.
@onready var spring_arm: SpringArm3D = $SpringArm3D


func _physics_process(delta: float) -> void:
	# Si no hay un objetivo, no hacemos nada.
	if not target:
		return
		
	# --- Lógica de Seguimiento de Posición (sin cambios) ---
	var target_position = target.global_position + Vector3.UP * vertical_offset
	global_position = global_position.lerp(target_position, delta * smoothness)
	
	# --- NUEVA: Llamada a la lógica de zoom ---
	handle_dynamic_zoom(delta)


## Esta nueva función maneja todo lo relacionado con el zoom.
func handle_dynamic_zoom(delta: float) -> void:
	# 1. Obtenemos la velocidad horizontal del jugador (ignorando el eje Y).
	var horizontal_velocity = Vector3(target.velocity.x, 0, target.velocity.z)
	var speed = horizontal_velocity.length()

	# 2. Determinamos cuál debería ser nuestra distancia de zoom objetivo.
	var target_zoom = idle_zoom_distance
	# Usamos un pequeño umbral (0.5) para evitar que el zoom tiemble al frenar.
	if speed > 0.5:
		target_zoom = running_zoom_distance

	# 3. Interpolamos suavemente la longitud actual del SpringArm hacia el objetivo.
	# Esta es la línea que crea el efecto de zoom suave.
	spring_arm.spring_length = lerp(spring_arm.spring_length, target_zoom, delta * zoom_smoothness)
