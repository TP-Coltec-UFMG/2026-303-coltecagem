extends Node

## Autoload que guarda estado entre trocas de cena.
## Não é destruído quando o mapa muda, então serve pra "avisar"
## o próximo mapa de onde o personagem deve aparecer.

## Nome do Marker2D (dentro do próximo mapa) onde o personagem
## deve ser posicionado assim que a cena carregar.
var proximo_ponto_entrada: String = ""

# ---------------------------------------------------------------
# MISSÃO DO CADERNO (SalaDeAula)
# ---------------------------------------------------------------

## true assim que o jogador pega/recebe o caderno de volta.
## Enquanto for false, a Carteira não libera o ganho de pontos
## da aula (jogador_presente_manual) e dispara a missão.
var tem_caderno: bool = false

## true a partir do momento em que a Carteira detecta que o
## jogador não tem o caderno e "dá início" à missão (ex: liberar
## diálogo de um NPC que pode devolver o caderno via
## Interagivel.entrega_caderno). Fica false de novo assim que o
## caderno é entregue.
var missao_caderno_ativa: bool = false
