extends Node2D

func _ready():
	MagNet.peer_created.connect(func():
		MagNet.peer.client_connected.connect(func(peer_id: int):
			add_child(Player.create(peer_id))
		)
		MagNet.peer.if_client(func(client: MagNetClient):
			add_child(Player.create(MagNet.peer.get_id()))
		)
	)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_1:
				MagNet.create_server()
			elif event.keycode == KEY_2:
				MagNet.create_client()
