extends Node
## ============================================================
## EstadoJogador
## ------------------------------------------------------------
## Autoload (Singleton) responsável por TODO o "core" do jogo:
##   - guardar o estado do estudante (energia, estresse, social,
##     desempenho acadêmico)
##   - aplicar os efeitos de cada ação do dia a dia
##   - calcular a nota da prova
##   - decidir qual final o jogador atingiu
##
## Valores e efeitos baseados no canvas de design do jogo
## (mapa mental de atributos, tabela de eventos padrão e lista
## de finais). Onde o canvas não especifica um número exato,
## deixei um valor "chute inicial" comentado — ajustem à vontade,
## é só mexer nas constantes lá em cima.
##
## Como usar de qualquer script:
##     EstadoJogador.estudar()
##     print(EstadoJogador.energia)
## ============================================================

# ---------------------------------------------------------------
# SINAIS
# ---------------------------------------------------------------
signal atributo_alterado(nome: String, valor_antigo: int, valor_novo: int)
signal acao_bloqueada(acao: String, motivo: String)
signal prova_corrigida(nota: int)
signal fim_de_jogo(final_nome: String)


# ---------------------------------------------------------------
# CONSTANTES DE BALANCEAMENTO
# ---------------------------------------------------------------
const ATRIBUTO_MIN := 0
const ATRIBUTO_MAX := 100

## Estresse muito alto bloqueia ações "produtivas" (aula, estudar,
## entrosar). O canvas fala em "muito estresse gera eventos
## negativos" — implementei como bloqueio, que é o que a issue
## original pede explicitamente.
const ESTRESSE_LIMITE_BLOQUEIO := 90

## Segundo o canvas: "Se [energia] ficar zerada: estudar rende
## menos; algumas ações ficam indisponíveis". Ou seja, o gatilho é
## energia = 0, não um valor intermediário.
const ENERGIA_LIMITE_ZERADA := 0

## Variação aleatória (fator sorte) usada na nota da prova.
const FATOR_SORTE_MIN := -15
const FATOR_SORTE_MAX := 15

## Nota mínima pra passar (canvas: "Objetivo: Chegar no final com
## Nota >= 60")
const MEDIA_APROVACAO := 60


# ---------------------------------------------------------------
# ATRIBUTOS DO ESTUDANTE (sempre entre 0 e 100)
# ---------------------------------------------------------------
# Nunca altere estas variáveis diretamente de fora deste script.
# Sempre passe pelas ações (aula, estudar, dormir...) ou, pra um
# ajuste manual, use alterar_atributo() — assim o clamp (0-100) e
# o sinal de aviso são sempre respeitados.

var energia: int = 100
var estresse: int = 0
var social: int = 50
var desempenho_academico: int = 50

## Última nota tirada em prova (-1 = nenhuma prova feita ainda)
var ultima_nota: int = -1

## Contador simples de dias/ações passadas
var dias_passados: int = 0


# ---------------------------------------------------------------
# HELPER PRINCIPAL — soma/subtrai valor de um atributo, com clamp
# ---------------------------------------------------------------
func alterar_atributo(nome: String, delta: int) -> void:
	var valor_antigo: int
	var valor_novo: int

	match nome:
		"energia":
			valor_antigo = energia
			valor_novo = clampi(valor_antigo + delta, ATRIBUTO_MIN, ATRIBUTO_MAX)
			energia = valor_novo
		"estresse":
			valor_antigo = estresse
			valor_novo = clampi(valor_antigo + delta, ATRIBUTO_MIN, ATRIBUTO_MAX)
			estresse = valor_novo
		"social":
			valor_antigo = social
			valor_novo = clampi(valor_antigo + delta, ATRIBUTO_MIN, ATRIBUTO_MAX)
			social = valor_novo
		"desempenho_academico":
			valor_antigo = desempenho_academico
			valor_novo = clampi(valor_antigo + delta, ATRIBUTO_MIN, ATRIBUTO_MAX)
			desempenho_academico = valor_novo
		_:
			push_warning("EstadoJogador: atributo desconhecido '%s'" % nome)
			return

	if valor_antigo != valor_novo:
		atributo_alterado.emit(nome, valor_antigo, valor_novo)


# ---------------------------------------------------------------
# CONDIÇÕES DE BLOQUEIO
# ---------------------------------------------------------------

## true se o estresse está alto demais para ações produtivas
func esta_em_burnout() -> bool:
	return estresse >= ESTRESSE_LIMITE_BLOQUEIO

## true se a energia está zerada (canvas: gatilho pra "estudar
## rende menos" e ações ficarem indisponíveis)
func esta_com_energia_zerada() -> bool:
	return energia <= ENERGIA_LIMITE_ZERADA

## Verifica se uma ação "produtiva" pode ser executada. Se não
## puder, emite acao_bloqueada (pra UI mostrar aviso) e retorna
## false. Ações de descanso (dormir, comer, matar_aula) não usam
## isso — elas são sempre permitidas.
func _pode_executar(acao: String) -> bool:
	if esta_em_burnout():
		acao_bloqueada.emit(acao, "estresse_alto")
		return false
	return true


# =================================================================
# AÇÕES PRINCIPAIS DO JOGO
# =================================================================
# Direção e força de cada efeito seguem a tabela "Eventos Padrões"
# do canvas: AULA tem o efeito mais forte em desempenho/estresse/
# energia; ESTUDAR tem o mesmo tipo de efeito, mas mais fraco.

## Ir para a aula: a ação de MAIOR impacto em desempenho e
## estresse, e a que mais custa energia (é o "pacote completo" —
## aula + prestar atenção o tempo todo).
func aula() -> bool:
	if not _pode_executar("aula"):
		return false

	var ganho_desempenho := 10
	if esta_com_energia_zerada():
		ganho_desempenho = 4 # rende bem menos sem energia

	alterar_atributo("energia", -20)
	alterar_atributo("estresse", 12)
	alterar_atributo("desempenho_academico", ganho_desempenho)

	dias_passados += 1
	return true


## Matar aula: sem custo de energia. Aumenta social (ficou com os
## amigos), mas diminui desempenho e estresse. Nunca é bloqueada.
func matar_aula() -> bool:
	alterar_atributo("desempenho_academico", -6)
	alterar_atributo("estresse", -5)
	alterar_atributo("social", 5)

	dias_passados += 1
	return true


## Estudar: mesmo tipo de efeito da aula (desempenho ↑, estresse ↑,
## energia ↓), mas TODOS mais fracos que aula() — segundo o canvas,
## aula rende mais que estudar sozinho.
func estudar() -> bool:
	if not _pode_executar("estudar"):
		return false

	var ganho_desempenho := 5
	if esta_com_energia_zerada():
		ganho_desempenho = 2 # "estudar rende menos" com energia zerada

	alterar_atributo("energia", -10)
	alterar_atributo("estresse", 6)
	alterar_atributo("desempenho_academico", ganho_desempenho)
	return true


## Comer: sempre recupera energia. O efeito no social depende do
## contexto (canvas: "Diminui: Social — Depender do Contexto").
## Por enquanto modelei como um parâmetro simples:
##   - comendo sozinho (padrão): social cai um pouco
##   - comendo com amigos: social sobe um pouco
## Ajustem/troquem essa regra quando tiverem o evento de refeição
## definido (ex: comer na cantina com NPCs específicos).
func comer(com_amigos: bool = false) -> bool:
	alterar_atributo("energia", 15)
	if com_amigos:
		alterar_atributo("social", 5)
	else:
		alterar_atributo("social", -5)
	return true


## Dormir: recupera energia e reduz estresse. Nunca é bloqueada,
## avança o contador de dias.
func dormir() -> bool:
	alterar_atributo("energia", 40)
	alterar_atributo("estresse", -25)
	dias_passados += 1
	return true


## Entrosar (socializar): segundo o canvas, só mexe em social
## (aumenta) e estresse (diminui) — sem custo de energia ou
## impacto em desempenho.
func entrosar() -> bool:
	if not _pode_executar("entrosar"):
		return false

	alterar_atributo("social", 15)
	alterar_atributo("estresse", -8)
	return true


# =================================================================
# PROVA / SEMINÁRIO
# =================================================================

## Nota = Desempenho + Fator Sorte (versão simples, como pedido na
## issue). O canvas também descreve uma versão "rica" considerando
## energia/estresse/ajuda de amigos — fica pra depois, se vocês
## quiserem evoluir a fórmula.
func fazer_prova() -> int:
	var fator_sorte := randi_range(FATOR_SORTE_MIN, FATOR_SORTE_MAX)
	var nota := clampi(desempenho_academico + fator_sorte, 0, 100)

	ultima_nota = nota
	prova_corrigida.emit(nota)

	# Canvas: Prova/Seminário aumenta estresse e diminui energia
	alterar_atributo("energia", -10)
	alterar_atributo("estresse", 10)

	return nota


# =================================================================
# FINAIS DO JOGO
# =================================================================
# Os 7 finais abaixo vêm direto do canvas (deixei de fora "Viciado
# em Café", que depende de um contador novo). "Formado na Média" é
# um fallback meu pra garantir que sempre caia em algum final,
# mesmo quando o estado não combina com nenhum caso "de destaque".
#
# Os números (85 = "média alta", 25 = "poucas amizades", etc) são
# a MINHA interpretação das descrições do canvas, que não trazia
# valores exatos — testem e ajustem essas constantes à vontade.

const DESEMPENHO_ALTO := 85
const SOCIAL_BAIXO := 25
const SOCIAL_ALTO := 80
const ESTRESSE_CONTROLADO := 40
const ESTRESSE_ELEVADO := 70
const ESTRESSE_EXTREMO := 90
const ENERGIA_MUITO_BAIXA := 20

enum Final {
	ALUNO_EXEMPLAR,
	GENIO_SOLITARIO,
	MAIS_POPULAR_DA_TURMA,
	SOBREVIVEU_POR_POUCO,
	VIDA_SOCIAL_EM_PRIMEIRO_LUGAR,
	BURNOUT_ACADEMICO,
	REPETENTE,
	FORMADO_NA_MEDIA, # fallback, não vem do canvas
}

const NOME_FINAL := {
	Final.ALUNO_EXEMPLAR: "Aluno Exemplar",
	Final.GENIO_SOLITARIO: "Gênio Solitário",
	Final.MAIS_POPULAR_DA_TURMA: "O Mais Popular da Turma",
	Final.SOBREVIVEU_POR_POUCO: "Sobreviveu por Pouco",
	Final.VIDA_SOCIAL_EM_PRIMEIRO_LUGAR: "Vida Social em Primeiro Lugar",
	Final.BURNOUT_ACADEMICO: "Burnout Acadêmico",
	Final.REPETENTE: "Repetente",
	Final.FORMADO_NA_MEDIA: "Formado na Média",
}

## Analisa o estado atual e decide qual dos finais do canvas se
## aplica. Retorna o enum Final; use NOME_FINAL[resultado] pro
## texto. Também emite fim_de_jogo já com o nome em string.
func verificar_final() -> Final:
	var aprovado := desempenho_academico >= MEDIA_APROVACAO
	var resultado: Final

	if not aprovado:
		# Reprovado: só dois finais possíveis no canvas
		if social >= SOCIAL_ALTO:
			resultado = Final.VIDA_SOCIAL_EM_PRIMEIRO_LUGAR
		else:
			resultado = Final.REPETENTE
	else:
		# Aprovado: checa os casos mais extremos primeiro
		if estresse >= ESTRESSE_EXTREMO:
			resultado = Final.BURNOUT_ACADEMICO
		elif energia <= ENERGIA_MUITO_BAIXA and estresse >= ESTRESSE_ELEVADO:
			resultado = Final.SOBREVIVEU_POR_POUCO
		elif desempenho_academico >= DESEMPENHO_ALTO and social <= SOCIAL_BAIXO:
			resultado = Final.GENIO_SOLITARIO
		elif desempenho_academico >= DESEMPENHO_ALTO and estresse <= ESTRESSE_CONTROLADO:
			resultado = Final.ALUNO_EXEMPLAR
		elif social >= SOCIAL_ALTO and desempenho_academico < DESEMPENHO_ALTO:
			resultado = Final.MAIS_POPULAR_DA_TURMA
		else:
			resultado = Final.FORMADO_NA_MEDIA

	fim_de_jogo.emit(NOME_FINAL[resultado])
	return resultado


# =================================================================
# UTILITÁRIO — reiniciar o estado (útil pra "Jogar novamente")
# =================================================================
func reiniciar() -> void:
	energia = 100
	estresse = 0
	social = 50
	desempenho_academico = 50
	ultima_nota = -1
	dias_passados = 0
