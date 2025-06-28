extends State

var charge_level: float = 0.0 # Nivel de carga de 0.0 a 1.0

func enter() -> void:
	# Hacemos visible el indicador y reseteamos la carga.
	player.aim_indicator.show()
	charge_level = 0.0

func exit() -> void:
	# Ocultamos el indicador al salir del estado.
	player.aim_indicator.hide()

func process_physics(delta: float) -> State:
	# 1. Cargar el lanzamiento mientras se mantiene presionado el botón.
	charge_level = min(charge_level + delta / player.throw_charge_time, 1.0)

	# 2. Permitir al jugador rotar para apuntar usando el stick de movimiento.
	var aim_direction = player.get_input_direction()
	if aim_direction.length() > 0.1:
		var new_transform = player.transform.looking_at(player.global_position + aim_direction, Vector3.UP)
		player.transform.basis = player.transform.basis.slerp(new_transform.basis, delta * player.rotation_speed)
	
	# 3. Mantenemos al jugador quieto (o con movimiento lento si se prefiere).
	player.velocity.x = lerp(player.velocity.x, 0.0, delta * player.friction)
	player.velocity.z = lerp(player.velocity.z, 0.0, delta * player.friction)

	# 4. Actualizar la posición del indicador visual.
	update_indicator()
	
	return null

func process_input(event: InputEvent) -> State:
	# Si se suelta el botón de lanzar, ejecutamos el lanzamiento.
	if event.is_action_released("throw"):
		
		# --- INICIO DE LA LÓGICA MODIFICADA ---
		
		# 1. Calculamos la fuerza final según el nivel de carga.
		var force = lerp(player.throw_min_force, player.throw_max_force, charge_level)
		
		# 2. Obtenemos la dirección base (hacia donde está mirando el personaje).
		var forward_direction = -player.transform.basis.z
		
		# 3. ¡LA MAGIA! Rotamos ese vector hacia arriba según nuestro ángulo.
		#    La rotación se hace sobre el eje X local del jugador (su "derecha").
		var throw_direction = forward_direction.rotated(
			player.transform.basis.x, 
			deg_to_rad(player.throw_angle_degrees)
		)
		
		# 4. Calculamos el impulso final combinando la dirección y la fuerza.
		var impulse = throw_direction * force
		
		# 5. Llamamos a la función del jugador con el nuevo impulso parabólico.
		player.launch_held_item(impulse)
		
		# --- FIN DE LA LÓGICA MODIFICADA ---

		# Transicionamos de vuelta al estado Idle.
		return player.states["Idle"]
		
	return null

func update_indicator() -> void:
	# Calcula la posición del indicador en el suelo.
	var force = lerp(player.throw_min_force, player.throw_max_force, charge_level)
	var direction = -player.transform.basis.z
	
	# Proyectamos un punto en frente del jugador para el indicador
	var target_point = player.global_position + direction * (force / 3.0) # Ajusta el divisor para que coincida visualmente
	
	# Usamos un raycast para colocar el indicador perfectamente en el suelo.
	var space_state = player.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(target_point + Vector3.UP * 5, target_point + Vector3.DOWN * 5)
	var result = space_state.intersect_ray(query)
	
	if result:
		player.aim_indicator.global_position = result.position
