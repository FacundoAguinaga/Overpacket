extends Node3D

## Exportamos una variable para poder decirle al spawner QUÉ escena generar.
## ¡Esto lo hace reutilizable para cualquier objeto!
@export var scene_to_spawn: PackedScene

# Una referencia al punto de aparición.
@onready var spawn_point: Marker3D = $"../../spawnPoint"


# Usamos _unhandled_input para capturar eventos de teclado/mando.
func _unhandled_input(event: InputEvent) -> void:
	# Si se presiona la acción que definimos...
	if event.is_action_pressed("spawn_box"):
		spawn_object()


func spawn_object() -> void:
	# Primero, comprobamos si se ha asignado una escena para evitar errores.
	if not scene_to_spawn:
		printerr("No se ha asignado ninguna 'scene_to_spawn' en el Spawner.")
		return

	# 1. Creamos una nueva instancia de la escena.
	var new_instance = scene_to_spawn.instantiate()

	# 2. Añadimos la instancia a la escena principal del juego.
	#    Usar get_tree().current_scene es más robusto que un simple add_child().
	get_tree().current_scene.add_child(new_instance)

	# 3. Colocamos la nueva instancia en la posición global del SpawnPoint.
	#    Esto es importante para que el objeto aparezca en el lugar correcto.
	if new_instance is Node3D:
		new_instance.global_position = spawn_point.global_position

	print("¡Objeto generado en ", spawn_point.global_position, "!")
