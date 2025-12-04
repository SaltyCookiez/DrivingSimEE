extends Node

var give_way_correct := 0
var give_way_wrong := 0

var stop_correct := 0
var stop_wrong := 0

var odd_parking_correct := 0
var odd_parking_wrong := 0
var odd_parking_ok := 0

# Mock version for current day. After creating a test level with odd or not odd date parking sign, update this mock version
var current_day := 5 # 5th day of the month (odd)

func is_odd_day() -> bool:
	return current_day % 2 != 0
