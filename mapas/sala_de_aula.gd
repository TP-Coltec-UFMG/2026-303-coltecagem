extends "res://mapas/area_base.gd"

@export var dialogo_primeira_aula: DialogueResource
@export var dialogo_professor: DialogueResource # Arraste o professor.dialogue aqui no Inspetor

var _cutscene_ja_aconteceu: bool = false
var _pergunta_ja_feita: bool = false # Evita que ele pergunte toda vez que você entrar

func _ready() -> void:
	super._ready()
	Global.mapa_atual = "SalaDeAula"
	var area_presenca = find_child("*Presenca*", true, false)
	if area_presenca and area_presenca.has_signal("body_entered"):
		area_presenca.body_entered.connect(_on_jogador_entrou_na_sala)

func _on_jogador_entrou_na_sala(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
		
	if not _cutscene_ja_aconteceu:
		_cutscene_ja_aconteceu = true
		await get_tree().create_timer(1.5).timeout
		
		if not GerenciadorDeDialogos.dialogo_manager_ativo:
			GerenciadorDeDialogos.iniciar_dialogo_manager()
			DialogueManager.show_dialogue_balloon(dialogo_primeira_aula, "entrada_sala")
			
	# Dispara a pergunta surpresa 15 segundos DEPOIS que o jogador entrou na sala
	elif not _pergunta_ja_feita:
		_pergunta_ja_feita = true
		await get_tree().create_timer(15.0).timeout # Ajuste o tempo que preferir
		
		# Só chama o balão se não houver outro diálogo rolando
		if not GerenciadorDeDialogos.dialogo_manager_ativo:
			GerenciadorDeDialogos.iniciar_dialogo_manager()
			DialogueManager.show_dialogue_balloon(dialogo_professor, "pergunta_surpresa")
