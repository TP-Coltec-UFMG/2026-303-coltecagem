extends Area2D
## ============================================================
## SalaDeAulaPresenca
## ------------------------------------------------------------
## Area2D que cobre a sala inteira (ou a parte "de dentro" dela) e
## detecta automaticamente quando o jogador entra/sai, escrevendo
## direto em GerenciadorDeEventos.jogador_presente_manual. Isso
## substitui o botão de teste da cena debug/teste_eventos.tscn —
## quando este script existir no mapa, é ele quem controla a
## presença; o botão de debug deixa de ser necessário nessa cena.
##
## Como usar (no editor):
##   1. Area2D (com este script) cobrindo a área "de dentro" da
##      SalaDeAula.tscn, com um CollisionShape2D.
##   2. Nada mais precisa ser configurado — ele já escuta
##      body_entered/body_exited sozinho.
##
## IMPORTANTE: GerenciadorDeEventos.jogador_presente_na_sala() hoje
## é um placeholder que ignora qual sala foi passada como
## parâmetro e só olha esse booleano global. Então só deve existir
## UMA área de presença ativa por vez (uma por cena/sala). Quando o
## Autoload evoluir para consultar posição real por sala, basta
## trocar esse booleano por uma estrutura por nome de sala.
## ============================================================

@export var nome_sala: String = "Sala 1"


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	GerenciadorDeEventos.jogador_presente_manual = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("jogador"):
		return
	GerenciadorDeEventos.jogador_presente_manual = false
