extends "res://mapas/area_base.gd"

@export var dialogo_primeira_aula: DialogueResource
@export var dialogo_professor: DialogueResource # Arraste o professor.dialogue aqui no Inspetor



func _ready() -> void:
	super._ready()
	Global.mapa_atual = "SalaDeAula"
	var area_presenca = find_child("*Presenca*", true, false)
	if area_presenca and area_presenca.has_signal("body_entered"):
		area_presenca.body_entered.connect(_on_jogador_entrou_na_sala)

func _on_jogador_entrou_na_sala(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	if Global.cutscene_sala_feita:
		return
	Global.cutscene_sala_feita = true

	await get_tree().create_timer(1.5).timeout
	if not is_inside_tree():
		return
	if not GerenciadorDeDialogos.dialogo_manager_ativo:
		GerenciadorDeDialogos.iniciar_dialogo_manager()
		DialogueManager.show_dialogue_balloon(dialogo_primeira_aula, "entrada_sala")
