extends Area

var _peer_id : int = -1

func _on_Area_body_entered(body : PhysicsBody) -> void:
	print("body entered: %s" % [body.name])
	if body is NPC:
		var marker = self
		print("marker: %s" % [marker.name])
		Server.transfer_to_peer(body, _peer_id)
