extends CanvasLayer
signal start_game
@onready var lives_counter := $MarginContainer/HBoxContainer/LivesCounter.get_children()
@onready var score_label := $MarginContainer/HBoxContainer/ScoreLabel
@onready var message := $Message
@onready var start_button := $StartButton
@onready var shield_bar = $MarginContainer/HBoxContainer/ShieldBar

var bar_textures = {
	"green": preload("res://assets/bar_green_200.png"),
	"yellow": preload("res://assets/bar_yellow_200.png"),
	"red": preload("res://assets/bar_red_200.png")
}

func show_message(text):
	message.text = text
	message.show()
	$Timer.start()

func update_score(value):
	score_label.text = str(value)

func update_lives(value):
	for item in 3:
		lives_counter[item].visible = value > item
		
func game_over():
	show_message("Game Over")
	await $Timer.timeout
	message.text = "Space Rocks!"
	message.show()
	start_button.show()

func update_shield(value):
	shield_bar.texture_progress = bar_textures["green"]
	if value < 0.4:
		shield_bar.texture_progress = bar_textures["red"]
	elif value < 0.7:
		shield_bar.texture_progress = bar_textures["yellow"]
	shield_bar.value = value

func _on_timer_timeout() -> void:
	message.hide()
	message.text = ""

func _on_start_button_pressed() -> void:
	start_button.hide()
	start_game.emit()
