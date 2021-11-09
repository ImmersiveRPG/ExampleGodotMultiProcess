# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleGodotMultiProcess

extends Node

const GAME_TITLE := "Multi Process"

const AIR_FRICTION := 10.0
const FLOOR_SLOPE_MAX_THRESHOLD := deg2rad(60)
const FLOOR_FRICTION := 60.0
const GRAVITY := -40.0
const MOUSE_SENSITIVITY := 0.1
const MOUSE_ACCELERATION_X := 10.0
const MOUSE_ACCELERATION_Y := 10.0
const MOUSE_Y_MAX := 70.0
const MOUSE_Y_MIN := -60.0

var _rng : RandomNumberGenerator
var _root_node : Node


enum Layers {
	terrain,
	item,
	player,
	enemy,
	storage,
	furniture,
	building,
	interact_point,
	vehicle,
	destructible,
	smell,
}

func _ready() -> void:
	# Setup random number generator
	_rng = RandomNumberGenerator.new()
	_rng.randomize()

func _input(event) -> void:
	if Input.is_action_just_pressed("Quit"):
		self.get_tree().quit()

func distance_between(v1 : Vector3, v2 : Vector3) -> float:
	var dx := v1.x - v2.x
	var dy := v1.y - v2.y
	var dz := v1.z - v2.z
	return sqrt(dx * dx + dy * dy + dz * dz)

