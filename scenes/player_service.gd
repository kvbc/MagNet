extends Node2D

@rpc("any_peer", "reliable")
func test_action(args):
	MagNet.forward_action(self.test_action, args, func(action_data: MagNet.ActionData, msg: String):
		MagNet.peer.if_client(func(client: MagNetClient):
			if action_data.server_response == MagNet.ServerResponse.NONE:
				print("simulating client")
			elif action_data.server_response == MagNet.ServerResponse.SUCCESS:
				print("client success")
			elif action_data.server_response == MagNet.ServerResponse.FAIL:
				print("client fail")
		)
		return MagNet.peer.if_server(func(server: MagNetServer):
			if msg.length() > 10:
				print("server fail")
				return false
			print("server success")
			return true
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
				var action_data := MagNet.ActionData.new()
				action_data.retries = 3
				MagNet.do_action(self.test_action, ["123 123 123 123"], action_data)
