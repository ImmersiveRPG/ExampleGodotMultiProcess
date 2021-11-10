# Copyright (c) 2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
# This file is license under the MIT License
# https://github.com/ImmersiveRPG/ExampleGodotMultiProcess

extends KinematicBody
class_name NPC


const JUMP_IMPULSE := 20.0
const ROTATION_SPEED := 6.0
const ACCELERATION := 70.0
const MAX_VELOCITY := 100.0
const NPC_RANGE := 500.0

var _velocity := Vector3.ZERO
var _snap_vector := Vector3.ZERO
var _start_location := Vector3.ZERO
var _destination := Vector3.INF

func _ready() -> void:
	_start_location = self.global_transform.origin

func _process(_delta : float) -> void:
	# Get a new destination if there is none
	if _destination == Vector3.INF:
		_destination = _start_location + Global.rand_vector(-NPC_RANGE, NPC_RANGE)
		_destination.y = 0.0

	# When close to destination, get a new random one
	var distance := Global.distance_between(self.global_transform.origin, _destination)
	#print("Wandering distance: %s, %s" % [distance, _destination])
	if distance <= 3.0:
		_destination = _start_location + Global.rand_vector(-NPC_RANGE, NPC_RANGE)
		_destination.y = 0.0

func _physics_process(delta : float) -> void:
	# Get the input vector based on the destination
	var input_vector := Vector3.ZERO
	if _destination != Vector3.INF:
		input_vector = (_destination - self.global_transform.origin).normalized()

	var is_moving := input_vector != Vector3.ZERO

	self.rotation.y = lerp_angle(self.rotation.y, atan2(-input_vector.x, -input_vector.z), ROTATION_SPEED * delta)

	# Velocity
	var max_velocity := MAX_VELOCITY

	# Acceleration
	if is_moving:
		_velocity = input_vector * max_velocity * ACCELERATION * delta
	else:
		_velocity.x = 0.0
		_velocity.z = 0.0

	# Gravity
	_velocity.y = clamp(_velocity.y + Global.GRAVITY * delta, Global.GRAVITY, JUMP_IMPULSE)

	# Snap to floor plane if close enough
	_snap_vector = -get_floor_normal() if is_on_floor() else Vector3.DOWN

	# Actually move
	_velocity = move_and_slide_with_snap(_velocity, _snap_vector, Vector3.UP, true, 4, Global.FLOOR_SLOPE_MAX_THRESHOLD, false)

func serialize(world_offset : Vector3) -> Dictionary:
	var data = {
		"scene_file" : "res://src/NPC/NPC.tscn",
		"origin" : self.global_transform.origin - world_offset,
		"_velocity" : _velocity,
		"_snap_vector" : _snap_vector,
		"_start_location" : _start_location - world_offset,
		"_destination" : _destination - world_offset,
	}
	return data

func deserialize(world_offset : Vector3, data : Dictionary) -> void:
	self.global_transform.origin = data["origin"] + world_offset
	_velocity = data["_velocity"]
	_snap_vector = data["_snap_vector"]
	_start_location = data["_start_location"] + world_offset
	_destination = data["_destination"] + world_offset

