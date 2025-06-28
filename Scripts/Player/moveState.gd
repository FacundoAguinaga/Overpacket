extends State

func process_physics(delta: float) -> State:
	# Obtenemos la dirección del input.
	var direction = player.get_input_direction()
	
	# Transición: si el jugador deja de moverse, cambiamos al estado Idle.
	if direction.length() < 0.1:
		return player.states["Idle"]
	
	# Calculamos la velocidad objetivo y la aplicamos con aceleración.
	var target_velocity = Vector3(direction.x, 0, direction.z) * player.speed
	var horizontal_velocity = Vector3(player.velocity.x, 0, player.velocity.z)
	horizontal_velocity = horizontal_velocity.lerp(target_velocity, delta * player.acceleration)
	player.velocity.x = horizontal_velocity.x
	player.velocity.z = horizontal_velocity.z
	
	# Rotamos el personaje visualmente para que mire en la dirección del movimiento.
	var new_transform = player.transform.looking_at(player.global_position + direction, Vector3.UP)
	player.transform.basis = player.transform.basis.slerp(new_transform.basis, delta * player.rotation_speed)
		
	return null

# Añadir a IdleState.gd y MoveState.gd
func process_input(event: InputEvent) -> State:
	# Si se presiona "lanzar" Y el jugador tiene un objeto, entramos en AimState.
	if event.is_action_pressed("throw") and player.held_item:
		return player.states["Aim"]
		
	return null
