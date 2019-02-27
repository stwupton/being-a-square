extends Node2D

export(NodePath) var checkpoint_path

onready var _player = $Player
onready var _end_trigger = $EndTrigger
onready var _end_spawn = $EndSpawn
onready var _animation_player = $AnimationPlayer
onready var checkpoint = get_node(checkpoint_path) setget _set_checkpoint

var _starting_checkpoint

func _ready():
	set_process_input(true)
	
	_player.global_position = checkpoint.global_position
	checkpoint.level.get_node('Camera2D').current = true
	_starting_checkpoint = checkpoint
	
	_end_trigger.connect('body_entered', self, '_on_end_triggered')
	
func _input(event):
	if event is InputEventKey && event.is_pressed() && event.scancode == KEY_ESCAPE:
		OS.window_minimized = true
		
func _set_checkpoint(new_checkpoint):
	if new_checkpoint.value < checkpoint.value:
		return
	checkpoint = new_checkpoint
	
func update_current_level(level):
	level.get_node('Camera2D').current = true
	
func player_died():
	_player.reset_movement()
	_player.global_position = checkpoint.global_position
	checkpoint.level.get_node('Camera2D').current = true
	
func _on_end_triggered(body):
	if body == _player:
		checkpoint = _starting_checkpoint
		update_current_level(checkpoint.level)
		_player.global_position = _end_spawn.global_position
		_animation_player.play('Show Message')
