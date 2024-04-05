class_name MagNetPeer extends Object

var _client: MagNetClient
var _server: MagNetServer
var multiplayer_api: MultiplayerAPI = null

func _init(multiplayer_api: MultiplayerAPI):
	self.multiplayer_api = multiplayer_api
	_client = MagNetClient.new(multiplayer_api)
	_server = MagNetServer.new(multiplayer_api)

func is_server() -> bool:
	return multiplayer_api.is_server()

# then_func: (server: MagNetServer) -> void
func if_server(then_func: Callable) -> void:
	if is_server():
		then_func.call(_server)

# then_func: (client: MagNetClient) -> void
func if_client(then_func: Callable) -> void:
	if not is_server():
		then_func.call(_client)

func get_id() -> int:
	return multiplayer_api.get_unique_id()
