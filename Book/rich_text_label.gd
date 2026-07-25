extends RichTextLabel

@export var secret_message: String = "A living, self-replicating organism that defied all logic, surviving effortlessly in the absolute vacuum of space. We brought a specimen aboard, believing we had made the greatest scientific discovery of our age.\n\nWe brought our extinction aboard."

func _ready() -> void:
	bbcode_enabled = true 
	# Updates the text based on the player's current unlocks the moment the scene loads
	update_display()

# You can still call this function manually from other scripts if you want the 
# sign to update while the player is standing right in front of it!
func update_display() -> void:
	self.text = TranslationManager.get_translated_text(secret_message)
