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

var _type := 0

var _folder_names: Array[StringName] = [
	tr(&"Documents"),
	tr(&"Images"),
	tr(&"Music"),
	tr(&"Videos"),
]


func _ready() -> void:
	var accent: Color = DisplayServer.get_accent_color()
	($Icon as Sprite2D).self_modulate = accent if accent.a == 1\
			else Color.DEEP_SKY_BLUE


func open() -> void:
	($Icon as Sprite2D).frame = 1
	($Icon/Symbol as Sprite2D).scale.y = 0.7


func close() -> void:
	($Icon as Sprite2D).frame = 0
	($Icon/Symbol as Sprite2D).scale.y = 1


func insert_file(file: Area2D) -> void:
	if file.get_type() == _type:
		file.accept()
	else:
		file.reject()


func set_type(index: int, symbol: Texture2D) -> void:
	if index > _folder_names.size():
		push_error('Invalid folder type of index "%d".' % index)
		return

	_type = index

	($Icon/Symbol as Sprite2D).texture = symbol
	($Name as Label).text = _folder_names[index]


func get_type() -> int:
	return _type
