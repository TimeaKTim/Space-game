extends RichTextLabel

@export var secret_message: String = ""

func _ready() -> void:
	bbcode_enabled = true 
	# Updates the text based on the player's current unlocks the moment the scene loads
	update_display()

# You can still call this function manually from other scripts if you want the 
# sign to update while the player is standing right in front of it!
func update_display() -> void:
	self.text = TranslationManager.get_translated_text(secret_message)
