class_name Player extends CharacterBody2D

const SPEED := 300.0

var target_gpos := Vector2.INF
var peer_id: int:
	set(v):
		peer_id = v
		name = str(peer_id)
		$id_label.text = str(peer_id)

static func create(peer_id: int) -> Player:
	var player = preload("res://scenes/player.tscn").instantiate()
	player.peer_id = peer_id
	return player

@rpc("any_peer", "unreliable")
func action_move(args):
	MagNet.forward_action(action_move, args, func(action_data: MagNet.ActionData, input_dir: Vector2, server_gpos := Vector2.INF):
		input_dir = input_dir.normalized()
		input_dir *= 1.0 / Engine.physics_ticks_per_second
		
		MagNet.peer.if_client(func(client: MagNetClient):
			match action_data.server_response:
				MagNet.ServerResponse.NONE:
					# simulate locally
					move_and_collide(input_dir * SPEED)
				MagNet.ServerResponse.FAIL:
					pass
				MagNet.ServerResponse.SUCCESS:
					target_gpos = server_gpos
		)
		
		return await MagNet.peer.if_server(func(server: MagNetServer) -> bool:
			if MagNet.get_action_sender_id() != peer_id:
				return false
			
			move_and_collide(input_dir * SPEED)
			action_data.user_args.append(global_position)
			
			return true
		)
	)

func _physics_process(delta):
	if target_gpos.is_finite():
		if global_position.distance_to(target_gpos) <= 1.0:
			target_gpos = Vector2.INF
		else:
			var weight: float = delta * 10
			if peer_id == MagNet.peer.get_id():
				weight = delta * 1
			global_position = global_position.lerp(target_gpos, weight)
			#global_position = global_position.lerp(target_gpos, delta * 1)
			#global_position = global_position.lerp(target_gpos, delta * (1 - min(MagNet.ping, 699) / 700))
		
	if peer_id == MagNet.peer.get_id():
		var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		if not input_dir.is_zero_approx():
			MagNet.do_action(action_move, [input_dir])
