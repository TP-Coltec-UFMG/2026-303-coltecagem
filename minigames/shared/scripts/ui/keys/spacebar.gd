@tool
extends "res://minigames/shared/scripts/ui/keys/key_prompt.gd"
# An extension of the normal key prompt script which enables the labels that
# are used to specify what the spacebar does in-game.


# This variable is sort of a cheat used to change the text of the spacebar's
# label.
@export var _label: String = "":
	set(new_label):
		_label = new_label
		$Label.set_text( new_label )

		# If we are currently in the editor, notify the editor that the
		# property list has changed so that we can see the new label.
		if Engine.is_editor_hint():
			notify_property_list_changed()
