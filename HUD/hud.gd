extends CanvasLayer
## ============================================================
## HUD
## ------------------------------------------------------------
## HUD fixa do jogo: 4 barras de atributo (Energia, Estresse,
## Social, Desempenho Acadêmico) + relógio com o horário atual.
##
## Só precisa instanciar essa cena dentro de World.tscn (ou
## qualquer cena de gameplay) — ela se conecta sozinha nos
## Autoloads (EstadoJogador e GerenciadorDeTempo) e se atualiza
## via sinal, sem precisar que ninguém "empurre" dados pra ela.
## ============================================================

@onready var barra_energia: ProgressBar = $Control/PainelBarras/Energia/Barra
@onready var barra_estresse: ProgressBar = $Control/PainelBarras/Estresse/Barra
@onready var barra_social: ProgressBar = $Control/PainelBarras/Social/Barra
@onready var barra_desempenho: ProgressBar = $Control/PainelBarras/Desempenho/Barra

@onready var label_horario: Label = $Control/PainelRelogio/LabelHorario
@onready var label_acoes: Label = $Control/PainelRelogio/LabelAcoes


func _ready() -> void:
	EstadoJogador.atributo_alterado.connect(_on_atributo_alterado)
	GerenciadorDeTempo.tempo_atualizado.connect(_on_tempo_atualizado)
	GerenciadorDeTempo.acoes_atualizadas.connect(_on_acoes_atualizadas)
	GerenciadorDeTempo.bloco_iniciado.connect(_on_bloco_iniciado)

	_atualizar_barras()
	_atualizar_relogio()
	_atualizar_acoes(GerenciadorDeTempo.acoes_restantes)


func _atualizar_barras() -> void:
	barra_energia.value = EstadoJogador.energia
	barra_estresse.value = EstadoJogador.estresse
	barra_social.value = EstadoJogador.social
	barra_desempenho.value = EstadoJogador.desempenho_academico


func _on_atributo_alterado(nome: String, _valor_antigo: int, valor_novo: int) -> void:
	match nome:
		"energia":
			barra_energia.value = valor_novo
		"estresse":
			barra_estresse.value = valor_novo
		"social":
			barra_social.value = valor_novo
		"desempenho_academico":
			barra_desempenho.value = valor_novo


func _atualizar_relogio() -> void:
	label_horario.text = GerenciadorDeTempo.horario_formatado()


func _on_tempo_atualizado(_segundos_restantes: float, _progresso: float) -> void:
	_atualizar_relogio()


func _on_bloco_iniciado(_indice: int, _nome_horario: String, _limite_acoes: int) -> void:
	_atualizar_relogio()


func _atualizar_acoes(restantes: int) -> void:
	if restantes == GerenciadorDeTempo.ACOES_ILIMITADAS:
		label_acoes.text = "Ações: livre"
	else:
		label_acoes.text = "Ações: %d" % restantes


func _on_acoes_atualizadas(restantes: int) -> void:
	_atualizar_acoes(restantes)
