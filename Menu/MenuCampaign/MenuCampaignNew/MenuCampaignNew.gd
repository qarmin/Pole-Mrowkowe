extends Control

onready var button_start_campaign: Button = find_node("StartCampaign")
#onready var button_back : Button = find_node("Back")

var is_enabled: bool = false


func _ready():
	pass  # Replace with function body.


func _on_TextureButton_toggled(button_pressed):
	if button_pressed:
		find_node("TextureButton").set_normal_texture(load("res://Menu/MenuCampaign/MenuCampaignNew/Campaign1Active.png"))
		button_start_campaign.set_disabled(false)
	else:
		find_node("TextureButton").set_normal_texture(load("res://Menu/MenuCampaign/MenuCampaignNew/Campaign1Normal.png"))
		button_start_campaign.set_disabled(true)
