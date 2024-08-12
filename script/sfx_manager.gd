extends Node

# Audio signals
signal signal_example

var num_players = 8
var bus = "SFX"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.

var min_sfx_pitch

func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.connect("finished", _on_stream_finished.bind(p))
		p.bus = bus
	
	# connect("signal_play_enemy_hit", _on_play_enemy_hit)


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)


func _play(sound_path):
	queue.append(sound_path)


func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
		
	
func reset():
	for i in available:
		(i as AudioStreamPlayer).stop()

	
func play_win():
	_play("res://asset/audio/level_audio/up.ogg")
	
func play_fail():
	_play("res://asset/audio/level_audio/down.ogg")
	
	
func play_walk():
	_play("res://asset/audio/level_audio/move.ogg")
	
	
func play_heal():
	_play("res://asset/audio/ui_audio/confirmation_001.ogg")
	

func play_attack():
	_play("res://asset/audio/entity_audio/attack.wav")
	

func play_revive():
	_play("res://asset/audio/entity_audio/popup.wav")
	

func play_turn_direction():
	_play("res://asset/audio/entity_audio/turn_direction.wav")
	

func play_upgrade():
	_play("res://asset/audio/entity_audio/upgrade.wav")
	

func play_open_chest():
	_play("res://asset/audio/entity_audio/open_case.wav")
