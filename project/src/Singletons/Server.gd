# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleGodotMultiProcess

extends Node

var _network = NetworkedMultiplayerENet.new()
var ip = "127.0.0.1"
var port = 1909
var max_players = 100
var _peer_zones := {}


func start_as_server() -> void:
	_network.create_server(port, max_players)
	self.get_tree().set_network_peer(_network)
	print("Server started on port %s" % [port])

	_network.connect("peer_connected", self, "_on_peer_connected")
	_network.connect("peer_disconnected", self, "_on_peer_disconnected")

func start_as_client() -> void:
	_network.create_client(ip, port)
	self.get_tree().set_network_peer(_network)

	_network.connect("connection_failed", self, "_on_connection_failed")
	_network.connect("connection_succeeded", self, "_on_connection_succeeded")

func _on_connection_failed() -> void:
	print("Failed to connect to server at %s" % [port])

func _on_connection_succeeded() -> void:
	print("Connected to server at %s" % [port])

func _on_peer_connected(peer_id : int) -> void:
	print("Peer %s connected" % [peer_id])

func _on_peer_disconnected(peer_id : int) -> void:
	print("Peer %s disconnected" % [peer_id])

	# Remove this peer's data
	if _peer_zones.has(peer_id):
		# Remove the marker for this zone
		var data = _peer_zones[peer_id]
		data["marker"].queue_free()
		_peer_zones.erase(peer_id)



remote func request_set_controlling_pos(pos : Vector3, node_id : int) -> void:
	print("request_set_controlling_pos")
	var peer_id : int = self.get_tree().get_rpc_sender_id()
	var marker = Global._root_node.add_marker(pos, peer_id)
	_peer_zones[peer_id] = {
		"pos" : pos,
		"marker" : marker,
	}

	var world_offset = Global._root_node.global_transform.origin
	rpc_id(peer_id, "response_set_controlling_pos", world_offset, node_id)

remote func response_set_controlling_pos(remote_offset : Vector3, node_id : int) -> void:
	print("response_set_controlling_pos")
	var peer_id : int = self.get_tree().get_rpc_sender_id()

	var world_offset = Global._root_node.global_transform.origin
	print(world_offset, " ", remote_offset)
	var offset = remote_offset - world_offset

	var marker = Global._root_node.add_marker(offset, peer_id)
	_peer_zones[peer_id] = {
		"pos" : offset,
		"marker" : marker,
	}

func set_controlling_pos(pos : Vector3) -> void:
	print("set_controlling_pos")
	var node_id : int = self.get_instance_id()
	rpc_id(1, "request_set_controlling_pos", pos, node_id)



func transfer_to_peer(body : PhysicsBody, peer_id : int):
	# Get the peer that controls this marker
	#print("body %s" % [body.name])
	if _peer_zones.has(peer_id):
		#print("    peer_id: %s" % [peer_id])
		var zone = _peer_zones[peer_id]
		#print("        peer_id: %s" % [peer_id])
		var world_offset = Global._root_node.global_transform.origin
		var serialized = body.serialize(world_offset)
		#print("        calling response_transfer_to_peer peer_id:%s, serialized:%s" % [peer_id, serialized])
		rpc_id(peer_id, "response_transfer_to_peer", serialized)
		body.queue_free()

remote func response_transfer_to_peer(serialized : Dictionary) -> void:
	print("Called response_transfer_to_peer %s " % [serialized])
	# Get this world's offset
	var world_offset = Global._root_node.global_transform.origin

	# Create the thing in this process
	var scene_file = serialized["scene_file"]
	var scene := ResourceLoader.load(scene_file)
	var instance = scene.instance()
	Global._root_node.add_child(instance)
	instance.deserialize(world_offset, serialized)
	#print(instance.name)


