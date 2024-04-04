class_name MagNetServer extends MagNetPeer

signal client_connected(id: int)
signal client_disconnected(id: int)

func _init(multiplayer_api: MultiplayerAPI):
	super._init(multiplayer_api)
	multiplayer_api.peer_connected.connect(func(id: int):
		client_connected.emit(id)	
	)
	multiplayer_api.peer_disconnected.connect(func(id: int):
		client_disconnected.emit(id)	
	)
