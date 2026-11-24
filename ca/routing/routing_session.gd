extends RefCounted

const PACKET = preload("res://routing/packet.gd")

var packet := PACKET.new("10.0.0.20")
var guided := true
var score := 0


func get_hint() -> String:
	if guided and not packet.is_delivered():
		return _explain_route()
	return ""


func choose_next_hop(chosen_hop: String) -> String:
	if packet.is_delivered():
		return "This packet has already arrived."

	if not packet.try_forward(chosen_hop):
		return _explain_route() + " Try again."

	score += 1
	if packet.is_delivered():
		return "Delivered to PC %s." % packet.destination_ip
	return "Forwarded to %s." % packet.current_device


func start_next_packet() -> bool:
	if not guided or not packet.is_delivered():
		return false

	packet = PACKET.new("10.0.0.30")
	guided = false
	return true


func is_finished() -> bool:
	return not guided and packet.is_delivered()


func _explain_route() -> String:
	var next_hop := packet.get_next_hop()
	if next_hop.is_empty():
		return "%s has no route for %s." % [packet.current_device, packet.destination_ip]
	if next_hop == packet.destination_ip:
		return "%s's table shows that PC %s is directly connected." % [packet.current_device, next_hop]
	return "%s's table says to send packets for %s to %s." % [
		packet.current_device, packet.destination_ip, next_hop
	]
