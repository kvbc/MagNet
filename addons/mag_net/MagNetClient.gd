class_name MagNetClient extends Object

signal connected
signal connection_failed
signal disconnected

func _init(multiplayer_api: MultiplayerAPI):
	multiplayer_api.connected_to_server.connect(func():
		connected.emit()
	)
	multiplayer_api.connection_failed.connect(func():
		connection_failed.emit()
	)
	multiplayer_api.server_disconnected.connect(func():
		disconnected.emit()
	)

func do_action(callable: Callable, args: Array = []) -> void:
	MagNet._client_do_action(callable, args)
