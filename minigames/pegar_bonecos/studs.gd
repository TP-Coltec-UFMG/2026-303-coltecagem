extends Node2D

@onready var stud_visual: Control = $Stud
@onready var self_area: Area2D = $Area2D

signal stud_collected

var _collected := false


func _ready() -> void:
	self_area.body_entered.connect(_on_body_entered)
	self_area.collision_mask = 1
	_sync_area_position()


func _process(_delta: float) -> void:
	if not _collected:
		_sync_area_position()


func _sync_area_position() -> void:
	self_area.global_position = stud_visual.get_global_rect().get_center()


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body is CharacterBody2D:
		return
	_collected = true
	self_area.monitoring = false
	stud_collected.emit()
	hide()
