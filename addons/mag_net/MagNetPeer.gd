class_name MagNetPeer extends Object

signal client_connected(id: int)
signal client_disconnected(id: int)

var _client: MagNetClient
var _server: MagNetServer
var multiplayer_api: MultiplayerAPI = null

func _init(multiplayer_api: MultiplayerAPI):
	self.multiplayer_api = multiplayer_api
	_client = MagNetClient.new(multiplayer_api)
	_server = MagNetServer.new(multiplayer_api)
	multiplayer_api.peer_connected.connect(func(id: int):
		if id != 1:
			client_connected.emit(id)
	)
	multiplayer_api.peer_disconnected.connect(func(id: int):
		client_disconnected.emit(id)
	)

func is_server() -> bool:
	return multiplayer_api.is_server()

func is_client() -> bool:
	return not is_server()

# then_func: (server: MagNetServer) -> Variant
func if_server(then_func: Callable) -> Variant:
	if is_server():
		return await then_func.call(_server)
	return null

# then_func: (client: MagNetClient) -> void
func if_client(then_func: Callable) -> void:
	if is_client():
		then_func.call(_client)

func get_id() -> int:
	return multiplayer_api.get_unique_id()
