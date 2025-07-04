class_name FootprintsTrail extends Node3D
## Attach this Node to a CharacterBody3D to print footprints trail on the floor.
## The position on the FootprintsTrail node define where footprints are printed.

@export_category("Footprint instance")
@export var footprint_material : Material ## The material of the footprint
@export var footprint_scale = 1.0
@export_category("Parameters")
@export var distance_between_footprints = 2.0 
@export var time_to_live = 30.0 ## Footprint delay before disapear
@export var right_left_alternance = true ## Enabled if you want to alternate right and left foot (it mirror the texture)
@export var footprints_visible = true

#footprint mesh scene
@onready var footprint  = load("res://addons/footprint-trail/scenes/footprint.tscn")
@onready var character : CharacterBody3D = get_parent()
#Create a node that will contain all footprints
@onready var footprints_container = Node3D.new()

var last_footprint_position = Vector3.ZERO
var footprint_rev = false

var foot_offset : float



func _ready():
	#Compute the distance bewteen the feet and the character positions
	foot_offset = self.global_position.distance_squared_to(character.global_position)
	#Adding the container to the parent node of the character
	footprints_container.name = "Footprints Container"
	character.get_parent().add_child.call_deferred(footprints_container)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var distance_from_last_footprint = character.position.distance_squared_to(last_footprint_position)
	#Footprint instantiation
	if character.is_on_floor() and distance_from_last_footprint >= distance_between_footprints + foot_offset:
		var footprint_instance = footprint.instantiate()
		footprint_instance.time_to_live = time_to_live

		#Set footprint material
		var footprint_mesh_instance : MeshInstance3D = footprint_instance.get_node("Mesh")
		var footprint_mat_instance = footprint_material.duplicate() #Important to make the material unique
		footprint_mesh_instance.mesh.surface_set_material(0, footprint_mat_instance)
		footprint_mesh_instance.scale = footprint_scale*Vector3.ONE
		
		footprints_container.add_child(footprint_instance)
		
		#Changing the transform
		# Posición base del nodo footprint trail
		footprint_instance.global_position = self.global_position
		
		# Añadir desplazamiento lateral (simula paso izquierdo/derecho)
		var side_offset = 0.2 # o 0.15 si es más realista
		var offset_dir = -character.global_transform.basis.x if footprint_rev else character.global_transform.basis.x
		footprint_instance.global_position += offset_dir * side_offset
		
		# Orientación alineada al personaje
		footprint_instance.global_rotation = character.global_rotation

		#Align the footprint with the floor
		footprint_instance.global_transform = align_to_Y_axis(footprint_instance.global_transform, character.get_floor_normal())
		#Mirror to simulate right and left foot
		footprint_mesh_instance.scale.x *= -1 if footprint_rev else 1
		footprint_rev = not footprint_rev && right_left_alternance
		
		#Update last footprint position
		last_footprint_position = footprint_instance.position
	
	#Set the footprints visible or not
	footprints_container.visible = footprints_visible

func align_to_Y_axis(n_transform : Transform3D, y_axis : Vector3):
	"""
	Align the node to the new y axis
	Callable only if is_on_floor() is true
	"""
	var scale = n_transform.basis.get_scale()
	
	n_transform.basis.y = y_axis
	n_transform.basis.x = y_axis.cross(n_transform.basis.z)
	n_transform.basis.z = n_transform.basis.x.cross(y_axis)
	
	n_transform.basis = n_transform.basis.orthonormalized()
	n_transform.basis.y *= scale.y
	n_transform.basis.x *= scale.x
	n_transform.basis.z *= scale.z
	
	return n_transform
	
