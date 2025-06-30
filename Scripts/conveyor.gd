extends Area3D

## Velocidad a la que la cinta mueve los objetos.
@export var speed: float = 3.0

## Dirección local del movimiento. -Z (Vector3.BACK) es hacia "adelante" del nodo.
@export var direction: Vector3 = Vector3.BACK


func _physics_process(_delta: float) -> void:
	# Obtenemos la dirección de movimiento en coordenadas del mundo.
	var move_direction = global_transform.basis * direction.normalized()
	var move_velocity = move_direction * speed

	# Iteramos sobre todos los cuerpos que están actualmente dentro del área.
	# Este método es más simple y robusto que usar señales.
	for body in get_overlapping_bodies():
		# Si el cuerpo es un CharacterBody3D (como el jugador)
		if body is CharacterBody3D:
			# Asignamos la velocidad de la cinta directamente.
			# El jugador podrá sumar su propio movimiento a esta velocidad.
			body.velocity.x = move_velocity.x
			body.velocity.z = move_velocity.z
			
		# Si el cuerpo es un RigidBody3D (como las cajas)
		elif body is RigidBody3D:
			# A los RigidBody, también les asignamos la velocidad lineal.
			# Esto sobreescribe su velocidad actual, creando un movimiento consistente.
			body.linear_velocity = move_velocity
