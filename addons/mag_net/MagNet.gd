extends Node

const DEFAULT_PORT: int = 42069
const DEFAULT_MAX_CLIENTS: int = 16

func _is_peer_created() -> bool:
	return multiplayer.multiplayer_peer is ENetMultiplayerPeer

func create_server(port: int = DEFAULT_PORT, max_clients: int = DEFAULT_MAX_CLIENTS) -> MagNetServer:
	assert(not _is_peer_created(), "peer has already been created")
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port, max_clients)
	multiplayer.multiplayer_peer = peer
	print("Created server on port %d with %d max clients" % [port, max_clients])
	return MagNetServer.new(multiplayer)

func create_client(port: int = DEFAULT_PORT, ip_address: String = "localhost") -> MagNetClient:
	assert(not _is_peer_created(), "peer has already been created")
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip_address, port)
	multiplayer.multiplayer_peer = peer
	print("Created client on port %d and ip %s" % [port, ip_address])
	return MagNetClient.new(multiplayer)
