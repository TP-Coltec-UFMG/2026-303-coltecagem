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


signal placed(successful: bool)

const _FILE_COLORS: Array[Color] = [
	Color.WHITE_SMOKE, # Document
	Color.LIME_GREEN, # Image
	Color.GOLD, # Music
	Color.DODGER_BLUE, # Video
]

const NAME_LABEL_WIDTH_MAX = 180

const ANIMATION_LENGTH = 0.3

var _type := 0

var _last_position := Vector2()
var _cursor_offset := Vector2()

var _folder_closest: Area2D
var _folders_hovered: Array[Area2D] = []

var _file_names: Array[Array] = [
	# Document
	[
		tr(&"something important"),
		tr(&"random stuff"),
		tr(&"nanogame ideas"),
		tr(&"don't copy (copy)"),
	],
	# Image
	[
		tr(&"vacation in canela",
				&"Popular vacation place in the south of Brazil"),
		tr(&"might delete later"),
		tr(&"family reunion"),
		tr(&"screenshot %s") % Time.get_date_string_from_system(),
	],
	# Music
	[
		tr(&"game soundtrack i like"),
		tr(&"nanogames up the wazoo"),
		tr(&"share the software"),
		tr(&"molly on a stake"),
	],
	# Video
	[
		tr(&"waiting for godot"),
		tr(&"revolution os", &"Documentary about GNU/Linux"),
		tr(&"stuff :)"),
		tr(&"varginha alien proof (real) (no fake)",
				&'Reference to Brazil\'s "ET de Varginha"'),
	],
]


func _ready() -> void:
	set_process_input(false)

	var accent: Color = DisplayServer.get_accent_color()
	($Selection as PanelContainer).self_modulate =\
			Color(accent if accent.a == 1 else Color.DEEP_SKY_BLUE, 0)

	area_entered.connect(
			func(area: Area2D) -> void: _folders_hovered.append(area))
	area_exited.connect(_on_area_exited)


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		# Don't let the player place the file outside the screen.
		var canvas_origin: Vector2 = get_canvas_transform().origin
		global_position = (event.position + _cursor_offset).clamp(
				-canvas_origin, NanogamePlayer.VIEW_SIZE + canvas_origin)

		var closest: Area2D
		var distance := INF
		for i: Area2D in _folders_hovered:
			var distance_current: float =\
					position.distance_squared_to(i.position)
			if distance_current < distance:
				closest = i
				distance = distance_current

		if closest != _folder_closest:
			_folder_closest = closest
			if closest != null:
				closest.open()

			for i: Area2D in _folders_hovered:
				if i != closest:
					i.close()

	if event is not InputEventMouseButton:
		return

	if not event.is_pressed() and event.button_index == MOUSE_BUTTON_MASK_LEFT:
		set_process_input(false)

		($Selection as PanelContainer).self_modulate.a = 0

		if _folder_closest != null:
			_folder_closest.insert_file(self)


func _input_event(
		_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if is_processing_input() or not event.is_pressed() or\
			event is not InputEventMouseButton or\
			event.button_index != MOUSE_BUTTON_LEFT:
		return

	set_process_input(true)

	_last_position = global_position
	_cursor_offset = global_position - event.position

	move_to_front()

	# Stop the player from picking multiple files at once.
	event.canceled = true

	($Selection as PanelContainer).self_modulate.a = 1


func accept() -> void:
	placed.emit(true)

	($Selection as PanelContainer).self_modulate.a = 0

	($AnimationPlayer as AnimationPlayer).play(&"shrink")


func reject() -> void:
	placed.emit(false)

	# Defer it, to avoid error about flushing queries in physical objects.
	($CollisionShape2D as CollisionShape2D).set_deferred(&"disabled", true)

	var tween: Tween = create_tween()
	tween.tween_property(self, ^"global_position", _last_position,
			ANIMATION_LENGTH).set_trans(Tween.TRANS_SPRING)
	tween.tween_callback(
			($CollisionShape2D as CollisionShape2D).set_disabled.bind(false))


func set_type(index: int, symbol: Texture2D) -> void:
	if index > _file_names.size():
		push_error('Invalid file type of index "%d".' % index)
		return

	_type = index

	(%Icon as TextureRect).self_modulate = _FILE_COLORS[index]

	(%Symbol as Sprite2D).texture = symbol
	# Make the symbol darker for ducuments, so it's visible in the white icon.
	(%Symbol as Sprite2D).self_modulate =\
			Color.DIM_GRAY if index == 0 else Color.WHITE

	var file_name: String = _file_names[index].pick_random()
	# Add extra variation to lower chance of repeating names.
	match randi_range(0, 4):
		1:
			file_name = file_name.to_camel_case()
		2:
			file_name = file_name.to_pascal_case()
		3:
			file_name = file_name.to_snake_case()
		4:
			file_name = file_name.to_upper()

	var label := %Name as Label
	label.text = file_name

	await get_tree().process_frame # Wait for the label's size to change.
	if label.size.x > NAME_LABEL_WIDTH_MAX:
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func get_type() -> int:
	return _type


func _on_area_exited(area: Area2D) -> void:
	area.close()
	_folders_hovered.erase(area)
