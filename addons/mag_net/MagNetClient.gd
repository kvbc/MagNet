class_name MagNetClient extends MagNetPeer

signal connected
signal connection_failed
signal disconnected

func _init(multiplayer_api: MultiplayerAPI):
	super._init(multiplayer_api)
	_multiplayer_api.connected_to_server.connect(func():
		connected.emit()
	)
	_multiplayer_api.connection_failed.connect(func():
		connection_failed.emit()
	)
	_multiplayer_api.server_disconnected.connect(func():
		disconnected.emit()
	)
