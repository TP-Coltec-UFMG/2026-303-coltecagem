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

const Folder = preload("folder/folder.tscn")
const File = preload("file/file.tscn")

const TYPE_MAX = 4

const FILE_SIZE = 200
const CELL_LAYOUT = Vector2i(NanogamePlayer.VIEW_SIZE / FILE_SIZE)
const CELL_SIZE = Vector2i(NanogamePlayer.VIEW_SIZE) / CELL_LAYOUT
const CELL_OFFSET = 32

const _SYMBOLS: Array[String] = [
	"res://nanogames/file_organizer/_assets/document.svg",
	"res://nanogames/file_organizer/_assets/image.svg",
	"res://nanogames/file_organizer/_assets/music.svg",
	"res://nanogames/file_organizer/_assets/video.svg",
]

var _file_goal := 0


func nanogame_prepare(difficulty: int, _debug_code: int) -> void:
	var occupied_cells: Array[Vector2i] = []
	# Avoid placing files behind the arcade interface.
	occupied_cells.append(Vector2i())
	occupied_cells.append(Vector2i(CELL_LAYOUT.x - 1, 0))

	var occupy_cell := func(node: Node2D) -> void:
		add_child(node)

		while true:
			var cell :=\
					Vector2i(randi() % CELL_LAYOUT.x, randi() % CELL_LAYOUT.y)
			if occupied_cells.has(cell):
				continue

			occupied_cells.append(cell)

			node.position =\
					cell * CELL_SIZE + (Vector2i(FILE_SIZE, FILE_SIZE) / 2) +\
					Vector2i(randi_range(-CELL_OFFSET, CELL_OFFSET),
							randi_range(-CELL_OFFSET, CELL_OFFSET))

			break

	### Spawn Setup ###

	var folder_quantity := 1 if difficulty == 1 else 2

	_file_goal = difficulty + 1
	@warning_ignore("integer_division")
	var file_type_max: int = _file_goal / folder_quantity

	# Pick which types will be available.
	var types: Array[int] = []
	for i: int in TYPE_MAX:
		types.append(i)
	types.shuffle()
	types.resize(folder_quantity) # Discard the rest.

	### File Spawn ###

	var file_types: Array[int] = []

	var file_quantity := 0
	for i: int in folder_quantity:
		var folder: Node = Folder.instantiate()
		occupy_cell.call(folder)
		folder.set_type(types[i], load(_SYMBOLS[types[i]]))

		file_types.append(randi_range(1, file_type_max))
		file_quantity += file_types[i]

	# Dump what's left to the last available type.
	if file_quantity < _file_goal:
		file_types[-1] += _file_goal - file_quantity

	for i: int in _file_goal:
		var file: Node = File.instantiate()
		occupy_cell.call(file)
		file.placed.connect(_on_file_placed)

		file.set_type(types[0], load(_SYMBOLS[types[0]]))
		file_types[0] -= 1
		if file_types[0] == 0:
			types.remove_at(0) # Switch to the next type.


func _on_file_placed(successful: bool) -> void:
	if not successful:
		($FileResult as AudioStreamPlayer).stream = preload("_assets/wrong.wav")
		($FileResult as AudioStreamPlayer).play()

		return

	_file_goal -= 1
	if _file_goal > 0:
		($FileResult as AudioStreamPlayer).stream = preload("_assets/correct.wav")
		($FileResult as AudioStreamPlayer).play()

		return

	($AnimationPlayer as AnimationPlayer).play(&"win")

	ended.emit(true)
