@tool
extends EditorPlugin

#
# Client sends a net packet:
# - client simulates the packet locally
# - client sends the packet to the server
# - the server validates the packet 
#   -> success:
#      - server processes and distributes the packet forward to all other clients
#   -> failure:
#      - server tells the client that the packet has failed
#      - client rollbacks the local simulation
#      - client resends the packet (optional)
#

# Initialization
func _enter_tree():
	add_autoload_singleton("MagNet", "MagNet.gd")

# Clean-up
func _exit_tree():
	pass
