# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleGodotMultiProcess

extends StaticBody

var _peer_id : int = -1

func _on_Area_body_entered(body : PhysicsBody) -> void:
	if body is NPC:
		var marker = self
		print("marker: %s" % [marker.name])
		Server.transfer_to_peer(body, _peer_id)
