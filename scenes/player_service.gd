extends Node2D

func _ready():
	MagNet.create_server(22222, 23)

func _process(delta):
	pass
