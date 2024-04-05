extends Node

enum ActionState {
	CLIENT,
	SERVER
}

const DEFAULT_PORT: int = 42069
const DEFAULT_MAX_CLIENTS: int = 16

signal peer_created

var peer: MagNetPeer = null:
	set(v):
		peer = v
		peer_created.emit()

# CLIENT
#   action_sender_id: 0 / null
#   args: [this: Callable, server_success: bool | null, ...]
#   callback: (...args) -> void
#
# SERVER
#   action_sender_id: int
#   args: [this: Callable, ...]
#   callback: (...args) -> success: bool
func start_action(action_sender_id: int, args: Array, callback: Callable) -> void:
	var callable: Callable = args.pop_front()
	
	var server_success = callback.callv(args)
	
	if peer.is_server():
		assert(server_success is bool)
		if server_success:
			callable.rpc(true)
		else:
			callable.rpc_id(action_sender_id, false)
	elif args[1] == null: # client and (server_success is null)
		print("calling server")
		callable.rpc_id(1) # to server
	
func _client_do_action(callable: Callable, args: Array = []) -> void:
	var new_args = [
		callable,
		null # server_access
	]
	new_args.append_array(args)
	callable.call(0, new_args)
	
func create_server(port: int = DEFAULT_PORT, max_clients: int = DEFAULT_MAX_CLIENTS) -> void:
	assert(peer == null, "peer has already been created")
	
	var enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_server(port, max_clients)
	multiplayer.multiplayer_peer = enet_peer
	print("Created server on port %d with %d max clients" % [port, max_clients])
	
	peer = MagNetPeer.new(multiplayer)

func create_client(port: int = DEFAULT_PORT, ip_address: String = "localhost") -> void:
	assert(peer == null, "peer has already been created")
	
	var enet_peer = ENetMultiplayerPeer.new()
	enet_peer.create_client(ip_address, port)
	multiplayer.multiplayer_peer = enet_peer
	print("Created client on port %d and ip %s" % [port, ip_address])
	
	peer = MagNetPeer.new(multiplayer)
