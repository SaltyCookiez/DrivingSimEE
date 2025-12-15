extends Node

var overtake_wrong = 0

var drive_through_wrong = 0

var u_turn_wrong = 0
var right_turn_wrong = 0
var left_turn_wrong = 0

var give_way_correct := 0
var give_way_wrong := 0

var stop_correct := 0
var stop_wrong := 0

var odd_parking_correct := 0
var odd_parking_wrong := 0
var odd_parking_ok := 0

var current_day := 5 # 5th day of the month (odd)

func is_odd_day() -> bool:
	return current_day % 2 != 0
