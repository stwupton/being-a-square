extends Area2D

export(NodePath) var checkpoint_node
export(NodePath) var level_node

onready var checkpoint = get_node(checkpoint_node)
onready var player = $'/root/World/Player'
onready var world = $'/root/World'

var level

func _ready():
	connect('body_entered', self, '_on_body_entered')
	
	if level_node != null:
		level = get_node(level_node)
	
func _on_body_entered(body):
	if body == player:
		world.checkpoint = checkpoint
		world.update_current_level(checkpoint.level if level == null else level)

