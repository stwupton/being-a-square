extends StaticBody2D

onready var area = $Area2D
onready var player = $'/root/World/Player'

func _ready():
	area.connect('body_entered', self, '_on_body_entered')
	area.connect('body_exited', self, '_on_body_exited')
	
func _on_body_entered(body):
	if body == player:
		player.apply_jump_force_increase(self)
		
func _on_body_exited(body):
	if body == player:
		player.remove_jump_force_increase(self)
