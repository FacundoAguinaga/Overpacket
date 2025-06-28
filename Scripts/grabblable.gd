class_name Grabbable extends RigidBody3D

signal dropped_on(area)
@onready var collision_shape: CollisionShape3D = $pickableCol

func _ready() -> void:
	add_to_group("grabbables")
	if not collision_shape:
		printerr("¡El objeto Grabbable no tiene un nodo CollisionShape3D como hijo!")

func pick_up(holder: Node3D) -> void:
	freeze = true
	if collision_shape: collision_shape.disabled = false
	reparent(holder)
	transform = Transform3D.IDENTITY

func drop(drop_transform: Transform3D) -> void:
	reparent(get_tree().current_scene)
	global_transform = drop_transform
	if collision_shape: collision_shape.disabled = false
	freeze = false
	apply_central_impulse(Vector3.DOWN * 0.1)

## Llamada por el jugador para lanzar el objeto con un impulso.
func launch(start_transform: Transform3D, impulse: Vector3) -> void:
	# Lo devolvemos a la escena principal.
	reparent(get_tree().current_scene)
	
	# Colocamos el objeto en la posición inicial del lanzamiento.
	global_transform = start_transform
	
	# Reactivamos su colisión y física.
	if collision_shape: collision_shape.disabled = false
	freeze = false
	
	# Aplicamos el impulso calculado para lanzarlo.
	apply_central_impulse(impulse)
	$frictionParticle/GPUParticles3D.emitting = true
	$frictionParticle/GPUParticles3D2.emitting = true
