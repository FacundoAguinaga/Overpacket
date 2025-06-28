extends State

func enter() -> void:
	# Opcional: podrías poner aquí que se reproduzca una animación de "idle".
	pass

func process_physics(delta: float) -> State:
	# Si el jugador no se está moviendo, aplicamos fricción para frenar.
	player.velocity.x = lerp(player.velocity.x, 0.0, delta * player.friction)
	player.velocity.z = lerp(player.velocity.z, 0.0, delta * player.friction)
	
	# Transición: si el jugador introduce movimiento, cambiamos al estado Move.
	if player.get_input_direction().length() > 0.1:
		return player.states["Move"]
		
	return null

# Añadir a IdleState.gd y MoveState.gd
func process_input(event: InputEvent) -> State:
	# Si se presiona "lanzar" Y el jugador tiene un objeto, entramos en AimState.
	if event.is_action_pressed("throw") and player.held_item:
		return player.states["Aim"]
		
	return null
