extends RefCounted

# Destination IP -> next hop
const ROUTES: Dictionary = {
	"10.0.0.20": "Router B",
	"10.0.0.30": "Router C",
}


static func next_hop_for(destination_ip: String) -> String:
	return ROUTES.get(destination_ip, "")
