extends Node

## Autoload que guarda estado entre trocas de cena.
## Não é destruído quando o mapa muda, então serve pra "avisar"
## o próximo mapa de onde o personagem deve aparecer.

## Nome do Marker2D (dentro do próximo mapa) onde o personagem
## deve ser posicionado assim que a cena carregar.
var proximo_ponto_entrada: String = ""