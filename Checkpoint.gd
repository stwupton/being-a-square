extends Node2D

export(int) var value
export(NodePath) var level_node

onready var level = get_node(level_node) setget ,_get_level_node

func _get_level_node():
	return level
