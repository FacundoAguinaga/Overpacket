# State.gd
class_name State extends Node

# Referencia al jugador, que ahora será asignada externamente por el Player.
var player: CharacterBody3D

# El resto de las funciones de la interfaz no cambian.
func enter() -> void:
	pass

func exit() -> void:
	pass

func process_physics(_delta: float) -> State:
	return null

func process_input(_event: InputEvent) -> State:
	return null
