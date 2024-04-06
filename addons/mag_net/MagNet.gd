extends Node

enum ServerResponse {
	NONE,
	FAIL,
	SUCCESS
}

class ActionData:
	var dictionary: Dictionary = {}
	var retries: int:
		set(v): dictionary.retries = v
		get: return dictionary.get("retries", 0)
	var retry_timeout_ms: int:
		set(v): dictionary.retry_timeout_ms = v
		get: return dictionary.get("retry_timeout_ms", 1000)
	var server_response: ServerResponse:
		set(v): dictionary.server_response = v
		get: return dictionary.get("server_response", ServerResponse.NONE)
	var user_args: Array:
		set(v): dictionary.user_args = v
		get: return dictionary.get("user_args", [])
	var client_send_s: float:
		set(v): dictionary.client_send_s = v
		get: return dictionary.get("client_send_s")
	var server_send_s: float:
		set(v): dictionary.server_send_s = v
		get: return dictionary.get("server_send_s")
	func _init(dictionary: Dictionary = {}):
		self.dictionary = dictionary

const DEFAULT_PORT: int = 42069
const DEFAULT_MAX_CLIENTS: int = 16

signal peer_created

var peer: MagNetPeer = null:
	set(v):
		peer = v
		peer_created.emit()
var _last_action_ms := Time.get_ticks_msec()
var ping: int = 0

func get_action_sender_id() -> int:
	return multiplayer.get_remote_sender_id()

func _pack_action_args(retries: int, server_success, args: Array) -> Array:
	var action_args = [retries, server_success]
	action_args.append_array(args)
	return action_args

# CLIENT
#   callback: (...args) -> void
# SERVER
#   callback: (...args) -> success: bool
func forward_action(callable: Callable, action_data_dict: Dictionary, callback: Callable) -> void:
	if peer.is_client() and multiplayer.get_remote_sender_id() > 1:
		push_error("rpc called from another client")
		return
	
	var action_data = ActionData.new(action_data_dict)
	var callback_args = [action_data]
	callback_args.append_array(action_data.user_args)
	var server_success = callback.bindv(callback_args).call() # callv doesnt work for some reason?
	
	if peer.is_server():
		assert(server_success is bool)
		action_data.server_send_s = Time.get_unix_time_from_system()
		if server_success:
			action_data.server_response = ServerResponse.SUCCESS
			callable.rpc(action_data.dictionary)
		else:
			action_data.server_response = ServerResponse.FAIL
			callable.rpc_id(
				multiplayer.get_remote_sender_id(),
				action_data.dictionary
			)
			
	if peer.is_client():
		if action_data.server_response == ServerResponse.NONE:
			action_data.client_send_s = Time.get_unix_time_from_system()
		else:
			ping = (action_data.server_send_s - action_data.client_send_s) * 1000
	
	var server_response = action_data.server_response
	action_data.server_response = ServerResponse.NONE
	if server_response == ServerResponse.FAIL:
		if action_data.retries > 0:
			action_data.retries -= 1
			await get_tree().create_timer(action_data.retry_timeout_ms / 1000.0).timeout
			do_action(callable, action_data.user_args, action_data)

func do_action(callable: Callable, user_args: Array = [], action_data := ActionData.new()) -> void:
	action_data.user_args = user_args
	if peer.is_server():
		callable.rpc(action_data.dictionary)
	else: #client
		callable.call(action_data.dictionary) # simulate locally
		callable.rpc_id(1, action_data.dictionary) # call server

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
