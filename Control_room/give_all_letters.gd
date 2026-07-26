extends Button


func _on_pressed() -> void:
	# Call the function from your Autoload script
	TranslationManager.unlock_all_letters()
	
	# NOTE: If you have a RichTextLabel on screen right now, 
	# it won't automatically update. You will need to tell it to 
	# re-translate its text right here!
	# Example:
	# $"../MyRichTextLabel".text = TranslationManager.get_translated_text("Hello World!")
