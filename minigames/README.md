# Minigames — pasta portátil (Godot 4)

Esta pasta contém 17 minijogos extraídos do projeto "Minigame Madness"
(convertido de Godot 3 para Godot 4), reorganizados para serem plugados
em qualquer outro projeto Godot 4. Cada minijogo é independente — nenhum
deles depende de código fora desta pasta (nada de `master/`, nenhum
singleton/autoload).


## 1. Como instalar

Copie a pasta `minigames/` inteira para a raiz do seu projeto, de forma
que fique `res://minigames/...`. Os caminhos internos de todas as cenas
e scripts já apontam para `res://minigames/...`, então não mexa no nome
nem no nível dessa pasta.

Assim que você abrir o projeto no editor, o Godot vai reimportar
automaticamente as imagens/áudios dessa pasta (os arquivos `.import`
originais não foram trazidos de propósito, porque eles guardavam
caminhos antigos — o reimport automático é normal e não é erro).


## 2. Configurar as Input Actions (obrigatório)

Os minijogos leem estas 5 ações de input pelo nome. Você precisa
criá-las no seu projeto em **Project Settings > Input Map** (com as
teclas/botões que preferir):

| Ação         | Uso típico                                   |
|--------------|-----------------------------------------------|
| `move_left`  | Mover para a esquerda                        |
| `move_right` | Mover para a direita                         |
| `move_up`    | Mover para cima / pular (dependendo do jogo) |
| `move_down`  | Mover para baixo / agachar                   |
| `action`     | Botão de ação (pular, atirar, cortar, etc.)  |

Nem todo minijogo usa as 5 (ex: o Dance só usa as direções), mas como
são compartilhadas entre os jogos, é mais simples cadastrar as 5 de
uma vez.


## 3. Como cada minijogo funciona (API)

Todo minijogo estende a classe base `Minigame`
(`res://minigames/shared/scripts/minigame.gd`), que já define:

```gdscript
signal found_secret
signal won
signal lost

func start()   # chame isso pra iniciar o minijogo
func stop()    # chame isso pra pausar/encerrar o minijogo
```

Ou seja, o fluxo de uso é sempre o mesmo:

1. Instancie a cena do minijogo (veja a tabela na seção 4)
2. Adicione a instância como filha de algum nó da sua cena
3. Conecte os sinais `won` e `lost` a funções suas
4. Chame `.start()` na instância

Exemplo mínimo, ligado a um botão virtual seu:

```gdscript
# No script do seu botão / launcher
func _on_JumpButton_pressed():
	var minigame_scene = preload("res://minigames/jump/jump_minigame.tscn")
	var minigame = minigame_scene.instantiate()
	add_child(minigame)

	minigame.won.connect(_on_minigame_won)
	minigame.lost.connect(_on_minigame_lost)

	minigame.start()


func _on_minigame_won():
	print("Jogador venceu!")
	# aqui você pode remover o minigame da tela, mostrar uma tela de
	# vitória, voltar pro seu menu, etc.


func _on_minigame_lost():
	print("Jogador perdeu!")
```

Existe também um sinal `found_secret` (sem argumentos, assim como
`won` e `lost`), usado no jogo original para marcar uma vitória
"secreta" em vez da vitória normal. É opcional — conecte só se fizer
sentido pro seu caso; a maioria dos minijogos nunca emite esse sinal.

Alguns minijogos (o Pitfall, por exemplo) são embrulhados numa cena
"frame" que renderiza o jogo por dentro de um `SubViewport` — isso é
só um detalhe interno, a API de fora (`start()`/`stop()`/sinais) é a
mesma.


## 4. Lista completa dos minijogos

| Nome           | Cena para instanciar                                              |
|----------------|---------------------------------------------------------------------|
| Ragdoll        | `res://minigames/ragdoll/scenes/ragdoll.tscn`                      |
| Saw            | `res://minigames/saw/scenes/saw_minigame.tscn`                     |
| Baseball       | `res://minigames/baseball/scenes/baseball_minigame.tscn`           |
| Platformer     | `res://minigames/platformer/scenes/platformer_minigame.tscn`       |
| Za (pizza)     | `res://minigames/za/scenes/za_minigame.tscn`                       |
| Big Rigs       | `res://minigames/big_rigs/big_rig_minigame.tscn`                   |
| Wind           | `res://minigames/wind/scenes/wind_minigame.tscn`                   |
| Shooter        | `res://minigames/shooter/scenes/shooter_frame.tscn`                |
| Anchovy Quest  | `res://minigames/anchovy_quest/scenes/anchovy_game.tscn`           |
| Dodge          | `res://minigames/dodge/scenes/dodge.tscn`                          |
| Pants          | `res://minigames/pants/pants_minigame.tscn`                        |
| Pitfall        | `res://minigames/pitfall/pitfall_minigame_frame.tscn`              |
| Dance          | `res://minigames/dance/scenes/dance_minigame.tscn`                 |
| Goalie         | `res://minigames/goalie/goalie_minigame.tscn`                      |
| Jump           | `res://minigames/jump/jump_minigame.tscn`                          |
| Bother         | `res://minigames/bother/bother_minigame.tscn`                      |
| Ball Tribute * | `res://minigames/ball_tribute/scenes/ball_tribute.tscn`            |

`*` Ball Tribute era o minijogo "secreto" do jogo original (não fazia
parte da lista numerada principal) — funciona igual aos outros, só
está incluído à parte.


## 5. Observações

- Todos os scripts já foram atualizados para Godot 4 (sem `yield`,
  `setget`, `export()` antigo, `KinematicBody2D`, etc.) — essa pasta é
  a versão já convertida e testada do projeto original.
- Se algum minijogo usar `get_tree()` para algo específico do seu
  próprio jogo (pausar a árvore inteira, trocar de cena, etc.), teste
  com calma — como cada minijogo foi originalmente pensado pra rodar
  dentro do `MinigameCanvas` do jogo completo, pode ser que algum
  comportamento específico dependa do contexto em que ele é
  instanciado. Nenhum deles referencia código fora desta pasta, mas
  vale testar cada um individualmente ao integrar.
