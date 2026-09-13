#=============================================================================#
# Librerama                                                                   #
# Copyright (c) 2020-present Michael Alexsander.                              #
#-----------------------------------------------------------------------------#
# This file is part of Librerama.                                             #
#                                                                             #
# Librerama is free software: you can redistribute it and/or modify           #
# it under the terms of the GNU General Public License as published by        #
# the Free Software Foundation, either version 3 of the License, or           #
# (at your option) any later version.                                         #
#                                                                             #
# Librerama is distributed in the hope that it will be useful,                #
# but WITHOUT ANY WARRANTY; without even the implied warranty of              #
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               #
# GNU General Public License for more details.                                #
#                                                                             #
# You should have received a copy of the GNU General Public License           #
# along with Librerama.  If not, see <http://www.gnu.org/licenses/>.          #
#=============================================================================#

extends Area2D


const BUMP_SPEED = 20_000

var _balls: Array[RigidBody2D] = []


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	for i: RigidBody2D in _balls:
		i.apply_central_force(
				global_position.direction_to(i.global_position) * BUMP_SPEED)


func disable() -> void:
	# Defer it, to avoid error about flushing queries in physical objects.
	($CollisionShape2D as CollisionShape2D).set_deferred(&"disabled", true)

	($AnimationPlayer as AnimationPlayer).play(&"switch_color")


func _on_body_entered(body: Node2D) -> void:
	if body is RigidBody2D:
		_balls.append(body)

		($Noise as AudioStreamPlayer2D).play()


func _on_body_exited(body: Node2D) -> void:
	if _balls.has(body):
		_balls.erase(body)
