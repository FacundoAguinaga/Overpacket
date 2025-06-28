extends StaticBody3D

# --- Variables de Configuración ---
## La escena del objeto que esta máquina ACEPTA.
@export var required_input_scene: PackedScene
## La escena del objeto que esta máquina PRODUCE.
@export var resulting_output_scene: PackedScene
## El tiempo en segundos que tarda el proceso.
@export var processing_time: float = 2.0
@export var light_color_on: Color = Color.CYAN 
@export var light_color_off: Color = Color.CYAN 

# --- Referencias a los Nodos Hijos ---
@onready var detection_area: Area3D = $colBox
@onready var output_point: Marker3D = $OutputPoint
@onready var timer: Timer = $Timer
@onready var animplayer: AnimationPlayer = $AnimationPlayer
@onready var inCol: CollisionShape3D = $inCol
@onready var pushArea: Area3D = $pushArea
@onready var pushPos: Marker3D = $pushPos
@onready var audioEf: AudioStreamPlayer3D = $soundEffects
@onready var lights: Node3D = $lights
# --- Estado Interno ---
var is_processing: bool = false


func _ready() -> void:
	# Conectamos la señal de la zona de detección a nuestra función.
	detection_area.body_entered.connect(on_body_entered)
	# Conectamos la señal del timer a nuestra función de finalización.
	timer.timeout.connect(on_processing_finished)
	# Configuramos el timer para que solo se dispare una vez por cada inicio.
	timer.one_shot = true
	set_all_spotlight_colors_recursive(lights, light_color_off)


## Esta función se ejecuta cuando un cuerpo (jugador, caja) entra en el Area3D.
func on_body_entered(body: Node3D) -> void:
	# Ignoramos si la máquina ya está ocupada o si el cuerpo no es un objeto agarrable.
	if is_processing or not body is Grabbable:
		return
	
	# Comprobamos si la escena del objeto que entró es la que requerimos.
	if body.scene_file_path == required_input_scene.resource_path:
		print("¡Input correcto recibido! Iniciando proceso...")
		
		# Marcamos la máquina como ocupada.
		is_processing = false
		
		inCol.disabled = false
		pushArea.monitoring = true
		set_all_spotlight_colors_recursive(lights, light_color_on)
		animplayer.play("closeopen")
		audioEf.play(0.0)
		
		# "Consumimos" el objeto de entrada (lo eliminamos de la escena).
		body.queue_free()
		
		# Iniciamos el temporizador con el tiempo de procesamiento definido.
		timer.wait_time = processing_time
		timer.start()
		
		# (Opcional) Aquí podrías iniciar una animación o un sonido de "trabajando".


## Esta función se ejecuta cuando el Timer llega a cero.
func on_processing_finished() -> void:
	print("¡Proceso finalizado! Generando output...")
	# Comprobamos que tengamos una escena de salida asignada.
	if not resulting_output_scene:
		printerr("No se ha asignado 'resulting_output_scene' en la máquina.")
		inCol.disabled = true
		pushArea.monitoring = false
		set_all_spotlight_colors_recursive(lights, light_color_off)
		is_processing = false # Liberamos la máquina
		return

	# Instanciamos el nuevo objeto.
	var new_instance = resulting_output_scene.instantiate()
	
	# Lo añadimos a la escena principal.
	get_tree().current_scene.add_child(new_instance)
	
	# Lo colocamos en el punto de salida.
	if new_instance is Node3D:
		new_instance.global_position = output_point.global_position
		
	# Liberamos la máquina para que pueda aceptar un nuevo objeto.
	is_processing = false
	inCol.disabled = true
	set_all_spotlight_colors_recursive(lights, light_color_off)
	pushArea.monitoring = false
	# (Opcional) Aquí podrías iniciar una animación o un sonido de "proceso completado".

func _on_push_area_body_entered(body:  Node3D) -> void:
	if body is Grabbable:
		body.global_position = pushPos.global_position

func set_all_spotlight_colors(color: Color):
	for child in get_children():
		if child is SpotLight3D:
			child.light_color = color
		elif child.has_node("."):
			set_all_spotlight_colors_recursive(child, color)

func set_all_spotlight_colors_recursive(node: Node, color: Color):
	for child in node.get_children():
		if child is SpotLight3D:
			child.light_color = color
		else:
			set_all_spotlight_colors_recursive(child, color)
