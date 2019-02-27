extends Node2D

onready var _animation_player = $AnimationPlayer

func _ready():
	_animation_player.play('toggle')
