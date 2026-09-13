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

extends RigidBody2D

@onready var _sprite := ($Sprite2D as Sprite2D)

const SPEED_MAX = 1_500


func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if state.linear_velocity.length() > SPEED_MAX:
		state.linear_velocity = state.linear_velocity.normalized() * SPEED_MAX

	_sprite.global_rotation = 0 # Lock the sprite's rotation.
