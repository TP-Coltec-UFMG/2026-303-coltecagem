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

extends Node2D


signal ended(has_won: bool)

const BALL_LAUNCH_SPEED_MIN = 500
const BALL_LAUNCH_SPEED_MAX = 1_500
const BALL_LAUNCH_INTERVAL = 1.0

var _difficulty := 0
var _debug_code := 0


func nanogame_prepare(difficulty: int, debug_code: int) -> void:
	_difficulty = difficulty
	_debug_code = debug_code

	var ball_launch := $BallLaunch as AudioStreamPlayer2D
	for i: int in ball_launch.get_child_count():
		if i + 1 == difficulty:
			break

		(ball_launch.get_child(i + 1) as InstancePlaceholder).create_instance(true)


func nanogame_start() -> void:
	_launch_ball($BallLaunch/Ball1 as RigidBody2D)

	if _difficulty == 1:
		return

	var ball_launch := $BallLaunch as AudioStreamPlayer2D
	var tween: Tween = create_tween()
	for i: int in ball_launch.get_child_count():
		if i + 1 == _difficulty:
			break

		tween.tween_interval(BALL_LAUNCH_INTERVAL)
		tween.tween_callback(
				_launch_ball.bind(ball_launch.get_child(i + 1) as RigidBody2D))


func _launch_ball(ball: RigidBody2D) -> void:
	ball.freeze = false
	ball.apply_central_impulse(Vector2.LEFT *
			randi_range(BALL_LAUNCH_SPEED_MIN, BALL_LAUNCH_SPEED_MAX))

	($BallLaunch as AudioStreamPlayer2D).play()


func _on_ball_lose_body_entered(body: Node2D) -> void:
	if _debug_code == 1:
		body.queue_free()

		var ball: RigidBody2D =\
				load("res://nanogames/fliperama/ball/ball.tscn").instantiate()
		add_child.call_deferred(ball)
		ball.position = ($BallLaunch as Node2D).position
		_launch_ball(ball)

		return

	($Bumper1 as Area2D).disable()
	($Bumper2 as Area2D).disable()
	($Bumper3 as Area2D).disable()

	# Defer it, to avoid blocking.
	($BallLose as Area2D).set_deferred(&"monitoring", false)

	($AnimationPlayer as AnimationPlayer).play(&"shut_down")

	ended.emit(false)
