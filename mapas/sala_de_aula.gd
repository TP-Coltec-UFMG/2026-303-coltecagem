extends "res://mapas/area_base.gd"
## ============================================================
## SalaDeAula
## ------------------------------------------------------------
## Especialização de area_base.gd só pra SalaDeAula.tscn: além de
## posicionar o personagem e ligar a HUD/relógio (comportamento
## herdado), dispara automaticamente o roteiro inicial — o
## Professor mandando a turma se sentar — assim que a cena carrega.
##
## Como usar (no editor):
##   Troque o script do nó raiz "SalaDeAula" (que hoje é
##   mapas/area_base.gd) por este arquivo. Todo o resto da cena
##   (Camera2D, Tiles, Carteira, etc.) continua igual.
## ============================================================

## Falas do Professor mostradas assim que a sala carrega.
@export var falas_professor_sentem: Array[String] = [
	"Bom dia, turma! Já pra dentro, vamos começar a aula.",
	"Cada um na sua carteira, por favor.",
]


func _ready() -> void:
	super._ready()
	# call_deferred pra garantir que a cena (HUD, Autoloads) já
	# terminou de entrar em _ready antes de abrirmos o diálogo.
	call_deferred("_iniciar_cutscene_inicial")


func _iniciar_cutscene_inicial() -> void:
	if falas_professor_sentem.is_empty():
		return
	# Nenhuma ficha do GerenciadorDeTempo é gasta aqui: mostrar_dialogo
	# só pausa/retoma o relógio, nunca chama consumir_acao().
	DialogoBox.mostrar_dialogo("Professor", falas_professor_sentem)
