class_name NanogameLibreramaAdapter
extends Minigame
## ============================================================
## NanogameLibreramaAdapter
## ------------------------------------------------------------
## Adapta um "nanogame" do projeto Librerama
## (codeberg.org/Librerama/librerama, GPL-3.0-or-later, assets em
## CC BY-SA 4.0) para o contrato `Minigame` já usado neste projeto
## (sinais won/lost, métodos start()/stop()).
##
## O Librerama usa um contrato diferente pros nanogames dele:
##   - signal ended(has_won: bool)
##   - func nanogame_prepare(difficulty: int, debug_code: int) -> void
##   - func nanogame_start() -> void   (opcional)
##
## Este adaptador NÃO exige editar nada dentro da pasta original do
## nanogame — ele só instancia a cena original como filha e traduz
## os sinais/chamadas de um contrato pro outro.
##
## COMO USAR (sem programar nada):
##   1. Baixe o nanogame que você quer em:
##      https://codeberg.org/Librerama/librerama/src/branch/master/nanogames
##      e copie a pasta inteira dele (ex: "fliperama/") para dentro
##      de res://minigames/<nome_do_nanogame>/, sem alterar nada lá
##      dentro.
##   2. Duplique o arquivo "nanogame_adapter_template.tscn" (nesta
##      mesma pasta), mova a cópia pra dentro de
##      res://minigames/<nome_do_nanogame>/ e renomeie pra
##      <nome_do_nanogame>_minigame.tscn.
##   3. Selecione o node raiz dessa cena duplicada e, no Inspetor,
##      arraste o "main.tscn" que você copiou no passo 1 pro campo
##      "Cena Nanogame".
##   4. Pronto — essa cena já funciona com
##      GerenciadorDeMinigames.iniciar_minigame(), exatamente como
##      qualquer outro minigame desta pasta (ex: pants_minigame.tscn).
## ============================================================

## O "main.tscn" original do nanogame do Librerama. Não edite esse
## arquivo — só arraste ele aqui, do jeito que veio.
@export var cena_nanogame: PackedScene

## Dificuldade repassada ao nanogame via nanogame_prepare() — de 1
## (mais fácil) a 3 (mais difícil). Cada nanogame decide sozinho o
## que fazer com esse número (ex: velocidade, quantidade de itens).
@export_range(1, 3, 1) var dificuldade: int = 2

## Quanto tempo esperar DEPOIS de nanogame_prepare() (que mostra o
## estado inicial, ex: as cartas viradas pra cima) e ANTES de
## nanogame_start() (que começa o jogo de verdade, ex: embaralha).
## Sem essa pausa, o jogador mal vê o "prepare" antes de já estar
## jogando. Ajuste por instância se algum nanogame precisar de mais
## ou menos tempo pra olhar antes de começar.
@export var tempo_de_preparo: float = 1.5

## Quanto tempo esperar DEPOIS que o nanogame emite "ended" e ANTES
## de repassar won/lost pro GerenciadorDeMinigames — dá tempo da
## própria animação de vitória/derrota do nanogame (se tiver) rodar
## antes da cena ser trocada.
@export var tempo_apos_fim: float = 1.0

var _instancia: Node = null


func start() -> void:
	super.start()

	if cena_nanogame == null:
		push_error("NanogameLibreramaAdapter (%s): 'Cena Nanogame' não foi preenchida no Inspetor." % name)
		return

	_instancia = cena_nanogame.instantiate()
	add_child(_instancia)

	if not _instancia.has_signal("ended"):
		push_error("NanogameLibreramaAdapter (%s): a cena em 'Cena Nanogame' não tem o sinal 'ended' — confira se é mesmo o main.tscn de um nanogame do Librerama." % name)
		return
	_instancia.ended.connect(_on_nanogame_ended)

	# Esses dois métodos fazem parte do contrato do Librerama. O
	# guia deles diz que nanogame_prepare() é sempre obrigatório e
	# nanogame_start() é opcional — por isso checamos os dois com
	# has_method() antes de chamar.
	if _instancia.has_method("nanogame_prepare"):
		_instancia.nanogame_prepare(dificuldade, 0)

	if tempo_de_preparo > 0.0:
		await get_tree().create_timer(tempo_de_preparo).timeout

	# Se o jogador já saiu do minigame durante a pausa (stop() foi
	# chamado), _instancia já não existe mais — não tenta continuar.
	if not is_instance_valid(_instancia):
		return

	if _instancia.has_method("nanogame_start"):
		_instancia.nanogame_start()


func stop() -> void:
	super.stop()
	if is_instance_valid(_instancia):
		_instancia.queue_free()
		_instancia = null


func _on_nanogame_ended(has_won: bool) -> void:
	if tempo_apos_fim > 0.0:
		await get_tree().create_timer(tempo_apos_fim).timeout

	if has_won:
		won.emit()
	else:
		lost.emit()
