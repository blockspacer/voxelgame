extends AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	connect("finished", self, "_onAudioFinished")
	
func _onAudioFinished():
	play()
