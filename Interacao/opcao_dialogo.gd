extends Resource
class_name OpcaoDialogo
## ============================================================
## OpcaoDialogo
## ------------------------------------------------------------
## Representa UM botão de escolha múltipla na DialogoBox (estilo
## Kindergarten: "Falar sobre a missão" / "Jogar conversa fora").
## Crie quantos quiser no Inspetor (botão direito > Novo Recurso >
## OpcaoDialogo) e monte a lista em Interagivel.opcoes.
## ============================================================

## Texto exibido no botão.
@export var texto: String = ""

## Falas mostradas quando o jogador escolhe esta opção (a
## "ramificação" do diálogo). Pode ficar vazio se a opção só
## dispara uma ação e encerra o diálogo na hora.
@export var falas: Array[String] = []

## Nome simbólico de uma ação a executar quando a opção for
## escolhida. Reconhecidos por padrão em interagivel.gd:
##   "entregar_caderno" -> entrega o caderno da missão
##   "entrosar"         -> tenta EstadoJogador.entrosar() (gasta ficha)
##   ""                 -> nenhuma ação extra (ex: só jogar conversa fora)
@export var acao: String = ""
