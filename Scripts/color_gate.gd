extends Area2D

const GATE_OPACITY = 128

@export_flags("Double Jump", "Dash", "Wall Cling") var gate_type = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.color = Color(Global.color_from_flag(gate_type), GATE_OPACITY / 256.)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
