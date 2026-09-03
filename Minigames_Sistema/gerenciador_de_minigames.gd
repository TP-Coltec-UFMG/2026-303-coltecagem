extends Node
## ============================================================
## GerenciadorDeMinigames
## ------------------------------------------------------------
## Autoload que sabe abrir QUALQUER minigame do Minigame Madness
## (ou qualquer cena que siga o mesmo contrato: extends Minigame,
## com start()/stop() e sinais won/lost) e converter o resultado
## em pontos de atributo, sem cada minigame precisar saber nada
## sobre EstadoJogador.
##
## Filosofia do jogo (conforme decidido): não existe "perder" de
## verdade uma task — ganhar rende a recompensa cheia, perder
## ainda rende uma fração dela (você tentou, fez a task mesmo
## errando uma etapa). Não há tela de "Game Over".
##
## Como qualquer objeto/NPC no mapa dispara um minigame:
##     GerenciadorDeMinigames.iniciar_minigame(
##         "res://minigames/pants/pants_minigame.tscn",
##         {"desempenho_academico": 8, "estresse": -3}
##     )
## (ver Minigames_Sistema/minigame_task_area.gd pra um componente
## pronto de Area2D que já faz essa chamada sozinho)
## ============================================================

## Fração da recompensa aplicada quando o minigame termina em
## "lost" em vez de "won" — 0.5 = metade dos pontos.
const FRACAO_RECOMPENSA_DERROTA := 0.5

## Quanto tempo (em segundos) a telinha de resultado ("Você
## conseguiu!" / "Quase lá...") fica visível antes de voltar pro
## mapa.
const TEMPO_TELA_RESULTADO := 1.4

var _cena_para_voltar: String = ""
var _recompensas: Dictionary = {}
var _minigame_atual: Node = null


## Ponto de entrada: caminho da cena do minigame (res://...) e um
## dicionário nome_do_atributo -> quantidade (mesmos nomes usados
## em EstadoJogador: "energia", "estresse", "social",
## "desempenho_academico"). Pode ser positivo ou negativo.
func iniciar_minigame(caminho_cena_minigame: String, recompensas: Dictionary) -> void:
	var cena_atual := get_tree().current_scene
	_cena_para_voltar = cena_atual.scene_file_path
	_recompensas = recompensas

	# Guarda o pixel exato de onde o personagem está agora, pra
	# ele voltar pro mesmo lugar (e não pro spawn/porta do mapa)
	# quando o minigame terminar. Ver area_base.gd -> _posicionar_personagem().
	var personagem := get_tree().get_first_node_in_group("jogador")
	if personagem:
		Global.posicao_retorno_minigame = personagem.global_position
		Global.retornando_de_minigame = true
	else:
		Global.retornando_de_minigame = false

	GerenciadorDeTempo.pausar_dia()

	var erro := get_tree().change_scene_to_file(caminho_cena_minigame)
	if erro != OK:
		push_error("GerenciadorDeMinigames: change_scene_to_file('%s') falhou com erro %d — a cena provavelmente tem um problema de carregamento (script com erro, .tscn corrompido/formato incompatível, etc). Confira o painel Output do editor." % [caminho_cena_minigame, erro])
		GerenciadorDeTempo.retomar_dia()
		Global.retornando_de_minigame = false
		return

	# A troca de cena do Godot passa por um estado intermediário em
	# que current_scene fica null (ele libera a cena antiga antes
	# de instalar a nova, de forma deferida). Nem "await
	# process_frame" nem "call_deferred" isolados garantem que essa
	# troca já terminou — então esperamos, frame a frame, até
	# current_scene realmente virar a cena nova.
	var tentativas := 0
	while get_tree().current_scene == null and tentativas < 60:
		await get_tree().process_frame
		tentativas += 1

	if get_tree().current_scene == null:
		push_error("GerenciadorDeMinigames: current_scene continua null depois de 60 frames esperando a troca para '%s'. A cena não deve ter carregado." % caminho_cena_minigame)
		GerenciadorDeTempo.retomar_dia()
		return

	_conectar_minigame_atual()


func _conectar_minigame_atual() -> void:
	_minigame_atual = get_tree().current_scene

	if _minigame_atual == null:
		push_error("GerenciadorDeMinigames: current_scene ainda é null após a troca de cena.")
		return

	if not (_minigame_atual.has_signal("won") and _minigame_atual.has_signal("lost")):
		push_error("GerenciadorDeMinigames: a cena '%s' não parece seguir o contrato Minigame (sem sinais won/lost)." % _minigame_atual.name)
		return

	_minigame_atual.won.connect(_on_minigame_terminou.bind(true))
	_minigame_atual.lost.connect(_on_minigame_terminou.bind(false))

	if _minigame_atual.has_method("start"):
		_minigame_atual.start()


func _on_minigame_terminou(venceu: bool) -> void:
	# Trava o minigame (spawn de calças, movimento, etc) enquanto
	# mostra o resultado, se o minigame tiver isso implementado.
	if _minigame_atual and _minigame_atual.has_method("stop"):
		_minigame_atual.stop()

	await _mostrar_tela_resultado(venceu)

	_aplicar_recompensas(venceu)
	GerenciadorDeTempo.retomar_dia()
	get_tree().change_scene_to_file(_cena_para_voltar)

	_minigame_atual = null
	_recompensas = {}
	_cena_para_voltar = ""


## Mostra uma telinha simples de "Você conseguiu!" / "Quase lá..."
## por cima do minigame, por TEMPO_TELA_RESULTADO segundos, antes
## de deixar o resto de _on_minigame_terminou continuar. Genérico
## pra qualquer minigame — não depende de nada específico da cena.
func _mostrar_tela_resultado(venceu: bool) -> void:
	if _minigame_atual == null or not is_instance_valid(_minigame_atual):
		return

	var camada := CanvasLayer.new()
	camada.layer = 100

	var fundo := ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.45)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	camada.add_child(fundo)

	var label := Label.new()
	label.text = "Você conseguiu!" if venceu else "Quase lá..."
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 28)
	label.add_theme_color_override("font_color", Color(1, 1, 1))
	camada.add_child(label)

	_minigame_atual.add_child(camada)

	# O jogo pode estar pausado (pausar_dia costuma pausar a árvore),
	# então usamos um timer que ignora pause pra garantir que a
	# telinha realmente fica visível pelo tempo certo.
	var timer := get_tree().create_timer(TEMPO_TELA_RESULTADO, true, false, true)
	await timer.timeout

	if is_instance_valid(camada):
		camada.queue_free()


func _aplicar_recompensas(venceu: bool) -> void:
	var fator := 1.0 if venceu else FRACAO_RECOMPENSA_DERROTA
	for nome_atributo in _recompensas.keys():
		var quantidade: int = roundi(_recompensas[nome_atributo] * fator)
		EstadoJogador.alterar_atributo(nome_atributo, quantidade)
