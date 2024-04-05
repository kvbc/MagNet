extends Node2D

#@rpc
#func cross_print(msg: String):
	#print("[%d] %s" % [MagNet.peer.get_id(), msg])

@rpc func test_action(a, b):
	print(a, " ", b, " (this is %d)" % MagNet.peer.get_id())
	MagNet.start_action(a,b,func():
		MagNet.peer.if_server(func(server: MagNetServer):
			print("hi from server")
		)
		MagNet.peer.if_client(func(client: MagNetClient):
			print("hi from client")
		)
	)

func _ready():
	MagNet.peer_created.connect(func():
		MagNet.peer.if_server(func(server: MagNetServer):
			print("i am a server")
		)
		MagNet.peer.if_client(func(client: MagNetClient):
			print("i am a client")
		)
	)

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_1:
				MagNet.create_server()
			elif event.keycode == KEY_2:
				MagNet.create_client()
			elif event.keycode == KEY_F and MagNet.peer:
				MagNet.peer.if_client(func(client: MagNetClient):
					client.do_action(self.test_action, ["123 123 123"])
				)
