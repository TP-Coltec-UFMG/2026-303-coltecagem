extends Node

signal material_obtido
signal missao_caderno_finalizada(com_sucesso: bool)

var proximo_ponto_entrada: String = ""

## Preenchidos por GerenciadorDeMinigames.iniciar_minigame() logo
## antes de trocar de cena pro minigame: guardam a posição exata
## (em pixels) de onde o personagem estava no mapa, pra ele voltar
## pro mesmo lugar (e não pro spawn/Marker2D da porta) quando o
## minigame terminar. Ver mapas/area_base.gd -> _posicionar_personagem().
var retornando_de_minigame: bool = false
var posicao_retorno_minigame: Vector2 = Vector2.ZERO

var tem_caderno: bool = false
var missao_caderno_ativa: bool = false
var missao_caderno_falhou: bool = false

# Guarda quem já recebeu o pedido de material.
var tentativas_material_feitas: Dictionary = {}


func iniciar_missao_caderno() -> void:
	# Interagir novamente com a carteira não reinicia a missão.
	if tem_caderno or missao_caderno_ativa or missao_caderno_falhou:
		return

	tentativas_material_feitas.clear()
	missao_caderno_ativa = true


func pode_tentar_material(alvo: String) -> bool:
	if tem_caderno:
		return false

	# Uma pergunta já feita pode ser repetida gratuitamente.
	if tentativas_material_feitas.has(alvo):
		return true

	if not missao_caderno_ativa or missao_caderno_falhou:
		return false

	if GerenciadorDeTempo.indice_bloco < 0:
		return false

	if GerenciadorDeTempo.indice_bloco >= GerenciadorDeTempo.BLOCOS.size():
		return false

	return (
		GerenciadorDeTempo.acoes_restantes
		== GerenciadorDeTempo.ACOES_ILIMITADAS
		or GerenciadorDeTempo.acoes_restantes > 0
	)


func registrar_tentativa_material(alvo: String) -> bool:
	if not pode_tentar_material(alvo):
		return false

	# Já perguntou para essa pessoa: não cobra outra ação.
	if tentativas_material_feitas.has(alvo):
		return true

	if not GerenciadorDeTempo.consumir_acao():
		return false

	tentativas_material_feitas[alvo] = true
	return true


func receber_material() -> void:
	# Evita emitir os sinais de recebimento mais de uma vez.
	if tem_caderno:
		return

	tem_caderno = true
	missao_caderno_ativa = false
	missao_caderno_falhou = false

	material_obtido.emit()
	missao_caderno_finalizada.emit(true)


func falhar_missao_caderno() -> void:
	if tem_caderno or not missao_caderno_ativa:
		return

	missao_caderno_ativa = false
	missao_caderno_falhou = true
	missao_caderno_finalizada.emit(false)
