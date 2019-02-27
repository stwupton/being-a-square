extends Area2D

onready var player = $'/root/World/Player'

func _ready():
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')
	
func _on_body_entered(body):
	if body == player:
		player.apply_anti_gravity(self)
		
func _on_body_exited(body):
	if body == player:
		player.remove_anti_gravity(self)