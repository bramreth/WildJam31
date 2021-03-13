extends Node

func start(node:Node, function:String) -> Thread:
	var thread = Thread.new()
	if thread.start(node, function):
		print("Failed to start thread for node " + node.name + "." + function)
	return thread
