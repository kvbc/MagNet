class_name MagNetPeer extends Object

var _multiplayer_api: MultiplayerAPI

func _init(multiplayer_api: MultiplayerAPI):
	_multiplayer_api = multiplayer_api

func get_id() -> int:
	return _multiplayer_api.get_unique_id()
