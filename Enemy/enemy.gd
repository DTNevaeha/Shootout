extends CharacterBody3D
class_name Enemy

const SPEED = 5.0

@export var attack_damage := 20
@export var attack_range := 1.5
@export var max_hitpoints := 100

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
@onready var playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var aggro_range := 12.0
var player
var player_nearby := false

var hitpoints: int = max_hitpoints:
	set(value):
		hitpoints = value
		if hitpoints <= 0:
			queue_free()
		player_nearby = true


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if player_nearby:
		navigation_agent_3d.target_position = player.global_position
	

func _physics_process(delta: float) -> void:
	var next_posittion = navigation_agent_3d.get_next_path_position()

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	var direction = global_position.direction_to(next_posittion)
	var distance = global_position.distance_to(player.global_position)

	if distance <= aggro_range:
		player_nearby = true

	if player_nearby:
		if distance <= attack_range:
			playback.travel("Attack")

	if direction:
		look_at_target(direction)
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


func look_at_target(direction: Vector3) -> void:
	var adjusted_direction = direction
	adjusted_direction.y = 0 # This removes the Y value when the enemy looks at the player
	look_at(global_position + adjusted_direction, Vector3.UP, true)


func attack() -> void:
	player.hitpoints -= attack_damage