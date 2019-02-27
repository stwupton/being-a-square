extends 'res://scn/props/SpeedPlatform.gd'

onready var _animation_player = $AnimationPlayer
onready var _icons_off = $IconsOff

func _ready():
	._ready()
	_animation_player.play('Toggle')
	
	for icon in _icons_off.get_children():
		icon.rotation_degrees = 90 * direction
	
