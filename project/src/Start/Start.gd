# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleGodotMultiProcess

extends Control


func _ready() -> void:
	Global._is_server = true

	if Global._is_server:
		Server.start_as_server()
	else:
		Server.start_as_client()

func _on_server_pressed() -> void:
	self.get_tree().change_scene("res://src/World/World.tscn")


func _on_client_pressed() -> void:
	self.get_tree().change_scene("res://src/WorldClient/WorldClient.tscn")
