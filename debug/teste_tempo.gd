extends Control
## ============================================================
## Cena de TESTE do GerenciadorDeTempo.
## ------------------------------------------------------------
## Mostra o relógio, o bloco atual, quanto tempo falta e quantas
## ações restam — e tem um botão "Fazer Ação" pra você simular
## uma aula/estudo/refeição terminando e ver a ficha de ação
## sendo consumida.
## ============================================================

@onready var label_status: RichTextLabel = $Margem/VBox/LabelStatus
@onready var label_log: RichTextLabel = $Margem/VBox/LabelLog
@onready var btn_acao: Button = $Margem/VBox/Botoes/BtnAcao
@onready var btn_iniciar: Button = $Margem/VBox/Botoes/BtnIniciar
@onready var btn_pausar: Button = $Margem/VBox/Botoes/BtnPausar


func _ready() -> void:
	btn_iniciar.pressed.connect(_on_iniciar)
	btn_pausar.pressed.connect(_on_pausar)
	btn_acao.pressed.connect(_on_fazer_acao)

	GerenciadorDeTempo.bloco_iniciado.connect(_on_bloco_iniciado)
	GerenciadorDeTempo.bloco_terminado.connect(_on_bloco_terminado)
	GerenciadorDeTempo.dia_terminado.connect(_on_dia_terminado)
	GerenciadorDeTempo.tempo_atualizado.connect(_on_tempo_atualizado)
	GerenciadorDeTempo.acoes_atualizadas.connect(_on_acoes_atualizadas)

	_log("Painel de teste pronto. Aperte 'Iniciar Dia' pra começar o relógio.")
	_atualizar_status()


func _on_iniciar() -> void:
	GerenciadorDeTempo.iniciar_dia()
	_log("Dia iniciado!")


func _on_pausar() -> void:
	if GerenciadorDeTempo.rodando:
		GerenciadorDeTempo.pausar_dia()
		_log("Pausado.")
	else:
		GerenciadorDeTempo.retomar_dia()
		_log("Retomado.")


func _on_fazer_acao() -> void:
	if not GerenciadorDeTempo.pode_agir():
		_log("[color=orange]Sem ações disponíveis nesse bloco![/color]")
		return
	GerenciadorDeTempo.consumir_acao()
	_log("Ação concluída (ficha consumida).")


func _on_bloco_iniciado(indice: int, nome_horario: String, limite_acoes: int) -> void:
	var texto_limite := "ilimitadas" if limite_acoes == GerenciadorDeTempo.ACOES_ILIMITADAS else str(limite_acoes)
	_log("[b]Bloco %d iniciado às %s (ações: %s)[/b]" % [indice + 1, nome_horario, texto_limite])


func _on_bloco_terminado(indice: int, nome_horario_fim: String) -> void:
	_log("Bloco %d terminou (%s)." % [indice + 1, nome_horario_fim])


func _on_dia_terminado() -> void:
	_log("[b]Dia letivo terminou![/b] (aqui é onde chamaríamos EstadoJogador.verificar_final())")


func _on_tempo_atualizado(_segundos_restantes: float, _progresso: float) -> void:
	_atualizar_status()


func _on_acoes_atualizadas(_restantes: int) -> void:
	_atualizar_status()


func _atualizar_status() -> void:
	var acoes_texto := "ilimitadas" if GerenciadorDeTempo.acoes_restantes == GerenciadorDeTempo.ACOES_ILIMITADAS else str(GerenciadorDeTempo.acoes_restantes)
	label_status.text = (
		"[b]Horário:[/b] %s\n" +
		"[b]Bloco:[/b] %d de %d\n" +
		"[b]Tempo restante no bloco:[/b] %.0fs\n" +
		"[b]Ações restantes:[/b] %s\n" +
		"[b]Rodando:[/b] %s"
	) % [
		GerenciadorDeTempo.horario_formatado(),
		GerenciadorDeTempo.indice_bloco + 1,
		GerenciadorDeTempo.BLOCOS.size(),
		GerenciadorDeTempo.tempo_restante,
		acoes_texto,
		"sim" if GerenciadorDeTempo.rodando else "não",
	]


func _log(texto: String) -> void:
	label_log.text += texto + "\n"
