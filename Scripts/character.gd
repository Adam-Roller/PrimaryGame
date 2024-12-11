extends CharacterBody2D


@export var SPEED = 100.0
@export var JUMP_VELOCITY = -200.0

@export_flags("DOUBLE_JUMP", "DASH", "WALL_CLING") var abilities = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gates = get_tree().get_nodes_in_group("Color_Gates")
	for gate in gates:
		gate.body_entered.connect(on_color_gate_enter.bind(gate.gate_type))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	
func _process(delta: float) -> void:
	$ColorRect.color = Global.color_from_flag(abilities)

func on_color_gate_enter(body: Node2D, gate_type: int):
	if gate_type > 0:
		abilities |= gate_type
	else:
		abilities = gate_type
