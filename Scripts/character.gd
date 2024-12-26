extends CharacterBody2D

@export var speed = 100.0
@export var jump_velocity = -300.0
@export var dash_velocity = 400.0
@export var dash_dur = .3

@export_flags("DOUBLE_JUMP", "DASH", "WALL_CLING") var abilities = 0

enum States {IDLE, RUNNING, JUMPING, FALLING, DASHING, CLINGING}

var state: States = States.IDLE
var jumps_left = 0
var dashes_left = 0
var dash_dir: Vector2 = Vector2.UP
@onready var dash_timer := $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var gates = get_tree().get_nodes_in_group("Color_Gates")
	for gate in gates:
		gate.body_entered.connect(on_color_gate_enter.bind(gate.gate_type))

func _physics_process(delta: float) -> void:
	# Reset jumps on floor
	if is_on_floor():
		jumps_left = 1 + int((abilities & Global.ABILITY_TYPES.Double_Jump != 0))
		
	# Get the input always used
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x := Input.get_axis("move_left", "move_right")
	var just_jumped = Input.is_action_just_pressed("move_jump") and jumps_left > 0
	
	# Character state machine - Input Handling
	match state:
		States.DASHING:
			# Only accept jump out of dash
			pass
			
		_:
			if Input.is_action_just_pressed("abil_dash") and dashes_left > 0:
				dashes_left -= 1
				var direction_y = Input.get_axis("move_up", "move_down")
				dash_dir = Vector2(direction_x, direction_y)
				dash_timer.stop()
				dash_timer.start(dash_dur)
				state = States.DASHING;
				
	# Character state machine - Movement
	match state:
		States.DASHING:
			# Constant velocity while dashing
			velocity = dash_dir * dash_velocity
			# Transition out of jump
			if just_jumped:
				velocity.y += jump_velocity
				# Ensure jumping out of a downward dash still gives slight upward velocity
				velocity.y = clampf(velocity.y, -100, jump_velocity / 2)
				jumps_left -= 1
				state = States.JUMPING
		
		_:	
			# Handle moving
			if direction_x:
				if (direction_x > 0 and velocity.x > speed) or (direction_x < 0 and velocity.x < speed * -1):
					# Do Nothing if already moving faster than max in the same direction as input
					pass
				elif (direction_x > 0 and velocity.x < speed * -1) or (direction_x < 0 and velocity.x > speed):
					# No immediate direction changing from dash speeds
					velocity.x += direction_x * speed * delta
				else:
					# Normal Movement
					velocity.x = direction_x * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				
			# Add the gravity.
			if not is_on_floor():
				velocity += get_gravity() * delta
				if velocity.y > 0:
					state = States.FALLING
			else:
				# Reset dashes
				dashes_left = int((abilities & Global.ABILITY_TYPES.Dash != 0)) + (1 * int((abilities & Global.ABILITY_TYPES.Double_Jump != 0)))
				# Transition states based on horizontal movement
				if is_equal_approx(velocity.x, 0.0):
					state = States.IDLE
				else:
					state = States.RUNNING
					
			# Handle jump.
			if just_jumped:
				velocity.y = jump_velocity
				jumps_left -= 1
				state = States.JUMPING
			

	move_and_slide()
	
func _process(_delta: float) -> void:
	$ColorRect.color = Global.color_from_flag(abilities)

func on_color_gate_enter(_body: Node2D, gate_type: int):
	if gate_type > 0:
		abilities |= gate_type
	else:
		abilities = gate_type


func _on_dash_timeout() -> void:
	print("Dash_timeout")
	velocity.x = clampf(velocity.x, speed * -1, speed)
	if state == States.DASHING:
		state = States.IDLE
	pass # Replace with function body.
