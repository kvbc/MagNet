class_name BlockService extends Node2D

var _placing_block: Block = null

@rpc("any_peer", "reliable")
func _action_place_block(args):
	MagNet.forward_action(_action_place_block, args, func(action_data: MagNet.ActionData, block_global_position: Vector2):
		MagNet.peer.if_client(func(client: MagNetClient):
			match action_data.server_response:
				MagNet.ServerResponse.NONE: # simulate locally
					var block_id = str(randi())
					action_data.dictionary.client_block_id = block_id
					
					var block = Block.create()
					block.name = block_id
					block.global_position = block_global_position
					add_child(block)
				MagNet.ServerResponse.FAIL:
					var block_id = action_data.dictionary.client_block_id
					get_node(block_id).queue_free()
				MagNet.ServerResponse.SUCCESS:
					var block_id = action_data.dictionary.client_block_id
					if not has_node(block_id):
						var block = Block.create()
						block.name = block_id
						block.global_position = block_global_position
						add_child(block)
		)
		
		return await MagNet.peer.if_server(func(server: MagNetServer) -> bool:
			var block_id: String = action_data.dictionary.client_block_id
			if has_node(block_id):
				return false
			
			var block = Block.create()
			block.collide = false
			block.name = block_id
			block.global_position = block_global_position
			add_child(block)
			
			if await block.is_area_overlapping_any_body():
				block.queue_free()
				return false
				
			block.collide = true
			return true
		)
	)

func is_placing_block() -> bool:
	return _placing_block != null

func start_placing_block():
	_placing_block = Block.create()
	_placing_block.collide = false
	_placing_block.global_position = get_global_mouse_position()
	add_child(_placing_block)
	_placing_block.area.body_entered.connect(func(body):
		_placing_block.modulate = Color.RED
	)
	_placing_block.area.body_exited.connect(func(body):
		if _placing_block and not _placing_block.area.has_overlapping_bodies():
			_placing_block.modulate = Color.DARK_GRAY
	)

func stop_placing_block():
	_placing_block.queue_free()
	_placing_block = null

func place_block():
	if not await _placing_block.is_area_overlapping_any_body():
		MagNet.do_action(_action_place_block, [get_global_mouse_position()])
	stop_placing_block()

func _input(event):
	if event is InputEventMouseMotion:
		if _placing_block:
			_placing_block.global_position = get_global_mouse_position()
