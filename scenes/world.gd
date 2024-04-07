extends Node2D

@onready var block_service: BlockService = $block_service
@onready var ui_peer_label: Label = $UI.get_node("%peer_label")
@onready var ui_ping_label: Label = $UI.get_node("%ping_label")

func _ready():
	MagNet.peer_created.connect(func():
		ui_peer_label.text = "Server" if MagNet.peer.is_server() else ("Client (%d)" % MagNet.peer.get_id())
	)
	
	while true:
		if MagNet.peer:
			var ping = MagNet.ping
			var color = Color.LIME
			if ping >= 80:
				color = Color.YELLOW
			if ping >= 120:
				color = Color.ORANGE
			if ping >= 160:
				color = Color.RED
			ui_ping_label.text = str(ping) + "ms"
			ui_ping_label.label_settings.font_color = color
		await get_tree().create_timer(1).timeout

func _input(event):
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_F:
				if block_service.is_placing_block():
					block_service.stop_placing_block()
				else:
					block_service.start_placing_block()
	elif event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if block_service.is_placing_block():
					block_service.place_block()
