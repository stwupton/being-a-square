extends Area2D

onready var world = $'/root/World'
onready var player = $'/root/World/Player'

func _ready():
	connect('body_entered', self, '_on_body_entered')
	
func _on_body_entered(body):
	if body == player:
		world.player_died()
