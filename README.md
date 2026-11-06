# Packet Routing XR

**Team members:** Shane, Darius, Seanan

## Our idea

We want to build an educational XR shooter, based on packet routing from Data Communications. The player starts at a router with a packet showing its destination IP address and a visible routing table. They use a controller as a laser gun to fire the packet towards the connected router they think is the correct next hop. After a correct choice, the player continues from that router, using its routing table, until the packet reaches the destination computer.

## How it teaches

The aim is to teach students how to read routing tables, the difference between the final destination of a packet and its next hop, and how packets traverse a network by making the routing decisions themselves.

We'll start with a guided example, then let players try for themselves. Wrong choices will prompt the game to explain which routing-table entry applies and why, before another attempt. Correct choices earn points. Seeing the connections and watching the packet move should help players connect the table entries to the packet's route. A new destination without hints will check whether they can apply what they've learned.

## Scope

We'll start with one small network and simple visuals. Once the basic game works, we plan to add harder levels involving subnet masks and to improve the visuals.

## Technologies

- **Godot 4 and GDScript** for the network, routing logic, scoring and feedback
- **OpenXR** for the Meta Quest setup
- **Godot XR Tools** for controller pointing and interaction with 3D UI
