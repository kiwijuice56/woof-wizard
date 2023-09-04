class_name ItemContainer
extends VBoxContainer

func show_items() -> void:
	var item_names: Array = GlobalData.data.inventory.keys()
	item_names.sort()
	
	delete_items()
	
	for item in item_names:
		var new_label: Label = Label.new()
		new_label.text = item
		%ItemContainer.add_child(new_label)
		
		var cnt_label: Label = Label.new()
		cnt_label.text = "x" + str(GlobalData.data.inventory[item])
		%CountContainer.add_child(cnt_label)

func delete_items() -> void:
	for child in %ItemContainer.get_children() + %CountContainer.get_children():
		child.queue_free()
