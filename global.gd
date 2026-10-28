extends Node

signal material_obtido
signal missao_caderno_finalizada(com_sucesso: bool)

var proximo_ponto_entrada: String = ""

## Momento (em ms) em que o último mapa terminou de carregar.
## As portas usam isso para ignorar o jogador logo após uma troca.
var ultima_troca_de_mapa_ms: int = 0

## Nome do mapa de gameplay em que o jogador está agora de verdade
## (setado por mapas/area_base.gd, e sobrescrito por mapas
## específicos tipo SalaDeAula — ver mapas/sala_de_aula.gd).
## Importante: uma troca de cena pra dentro de um MINIGAME não
## passa por area_base.gd, então isso continua marcando o mapa
## real mesmo com um minigame aberto por cima.
var mapa_atual: String = ""

var tem_caderno: bool = false
var missao_caderno_ativa: bool = false
var missao_caderno_falhou: bool = false

# Guarda quem já recebeu o pedido de material.
var tentativas_material_feitas: Dictionary = {}

## Relógio de jogo: soma só enquanto o dia está rodando
## (não conta durante diálogo, minigame ou tela de prova).
var tempo_de_jogo: float = 0.0

## id da estação de minigame -> tempo_de_jogo em que ela libera de novo
var estacoes_liberam_em: Dictionary = {}

func _process(delta: float) -> void:
	if GerenciadorDeTempo.rodando:
		tempo_de_jogo += delta

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

	return true


func registrar_tentativa_material(alvo: String) -> bool:
	if not pode_tentar_material(alvo):
		return false

	if tentativas_material_feitas.has(alvo):
		return true

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
	
	
## Cooldown de NPCs que abrem minigame. O id é livre
## (ex: "npc_pedrao"); usa o mesmo relógio das estações.
func estacao_disponivel(id: String) -> bool:
	return segundos_para_liberar(id) <= 0.0


func segundos_para_liberar(id: String) -> float:
	var libera_em: float = estacoes_liberam_em.get(id, 0.0)
	return maxf(0.0, libera_em - tempo_de_jogo)


func iniciar_cooldown(id: String, segundos: float) -> void:
	estacoes_liberam_em[id] = tempo_de_jogo + segundos
	
	
## Zera TUDO que é estado de partida, para "Jogar de novo".
func reiniciar_partida() -> void:
	EstadoJogador.reiniciar()

	tem_caderno = false
	missao_caderno_ativa = false
	missao_caderno_falhou = false
	tentativas_material_feitas.clear()

	proximo_ponto_entrada = ""
	mapa_atual = ""
	ultima_troca_de_mapa_ms = 0

	GerenciadorDeEventos.sala_com_aula_ativa = ""
	GerenciadorDeEventos.sala_com_prova_ativa = ""
	GerenciadorDeEventos.bloco_da_prova = -1
	GerenciadorDeEventos.jogador_presente_manual = false
	
	tempo_de_jogo = 0.0
	estacoes_liberam_em.clear()
