extends RefCounted

const RouterA = preload("res://routing/router_a.gd")

# An IP in the next-hop column means the PC is directly connected.
const TABLES: Dictionary = {
	"Router A": RouterA.ROUTES,
	"Router B": {"10.0.0.20": "10.0.0.20", "10.0.0.30": "Router A"},
	"Router C": {"10.0.0.20": "Router A", "10.0.0.30": "10.0.0.30"},
}


static func next_hop_for(current_router: String, destination_ip: String) -> String:
	var table: Dictionary = TABLES.get(current_router, {})
	return table.get(destination_ip, "")


static func is_correct_hop(current_router: String, destination_ip: String, chosen_hop: String) -> bool:
	return chosen_hop != "" and chosen_hop == next_hop_for(current_router, destination_ip)
