extends Node2D

const COLLISION_MASK_CARD = 1

var screen_size
var card_being_dragged
var is_hovering_on_card

func _ready() -> void:
	screen_size = get_viewport_rect().size
	
func _process(delta: float) -> void:
	if card_being_dragged:
		var mouse_pos = get_global_mouse_position()
		card_being_dragged.position = Vector2(clamp(mouse_pos.x , 0, screen_size.x),
			clamp(mouse_pos.y , 0, screen_size.y))
	

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			var card = raycast_check_for_card()
			if card:
				start_drag(card)
		else:
			finish_drag()

func start_drag(card):
	card_being_dragged = card
	card.scale = Vector2(1,1)

func finish_drag():
	card_being_dragged.scale = Vector2(1.05,1.05)
	card_being_dragged = null
	

func connect_card_signal(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		hightlight_card(card, true)

func on_hovered_off_card(card):
	if !card_being_dragged:
		hightlight_card(card, false)
		var new_card_hovered = raycast_check_for_card()
		if new_card_hovered:
			hightlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func hightlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05,1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1,1)
		card.z_index = 1

func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var paramiters = PhysicsPointQueryParameters2D.new()
	paramiters.position = get_global_mouse_position()
	paramiters.collide_with_areas = true
	paramiters.collision_mask = COLLISION_MASK_CARD
	var result = space_state.intersect_point(paramiters)
	if result.size() > 0 :
		return get_card_with_highest_z_indez(result)
		#print(result)
		#return result[0].collider.get_parent()
	return null
	
func get_card_with_highest_z_indez(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index
	for i in range(1,cards.size()):
		var current_card = cards[i].collider.get_parent()
		if current_card.z_index > highest_z_index:
			highest_z_card = current_card
			highest_z_index = current_card.z_index
	return highest_z_card
			
		
		
