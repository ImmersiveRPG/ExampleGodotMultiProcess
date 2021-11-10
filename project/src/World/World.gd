# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleGodotMultiProcess

extends Spatial


func _ready() -> void:
	Global._root_node = self
	if not Global._is_server:
		Server.set_controlling_pos(self.transform.origin)

func add_marker(pos : Vector3, peer_id : int) -> Node:
	var offset_pos = Vector3(-pos.x, -pos.y, -pos.z)

	var target = get_tree().get_current_scene()
	var scene_file := "res://src/ZoneMarker/ZoneMarker.tscn"
	var scene := ResourceLoader.load(scene_file)
	var instance = scene.instance()
	target.add_child(instance)
	instance._peer_id = peer_id
	instance.global_transform.origin = offset_pos
	return instance

