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


func play(sound_path):
	queue.append(sound_path)


func _process(delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()

#
#var hit_sfx_list = WeightTable.new(
	#[
		#"res://assets/audio/footstep_carpet_000.ogg",
		#"res://assets/audio/footstep_carpet_001.ogg",
		#"res://assets/audio/footstep_carpet_002.ogg",
		#"res://assets/audio/footstep_carpet_003.ogg",
		#"res://assets/audio/footstep_carpet_004.ogg"
	#]
#)
#func _on_play_enemy_hit():
	#play(hit_sfx_list.rand_pick())
