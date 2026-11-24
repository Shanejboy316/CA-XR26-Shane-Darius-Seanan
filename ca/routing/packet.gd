extends RefCounted

const Network = preload("res://routing/routing_network.gd")

var current_device := "Router A"
var destination_ip: String
var route: Array[String] = []


func _init(ip: String) -> void:
	destination_ip = ip
	route.append(current_device)


func get_next_hop() -> String:
	return Network.next_hop_for(current_device, destination_ip)


func try_forward(chosen_hop: String) -> bool:
	if is_delivered() or not Network.is_correct_hop(current_device, destination_ip, chosen_hop):
		return false
	current_device = chosen_hop
	route.append(current_device)
	return true


func is_delivered() -> bool:
	return current_device == destination_ip and destination_ip.is_valid_ip_address()
