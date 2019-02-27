extends StaticBody2D

export(int, -1, 1) var direction = 1

onready var area = $Area2D
onready var player = $'/root/World/Player'
onready var _icons_on = $IconsOn

func _ready():
	area.connect('body_entered', self, '_on_body_entered')
	area.connect('body_exited', self, '_on_body_exited')
	
	for icon in _icons_on.get_children():
		icon.rotation_degrees = 90 * direction
	
func _on_body_entered(body):
	if body == player:
		player.apply_platform_speed_increase(self)
		
func _on_body_exited(body):
	if body == player:
		player.remove_platform_speed_increase(self)
