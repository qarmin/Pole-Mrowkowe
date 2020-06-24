extends Node

var points : int = 0
var stages_frames : PoolIntArray = [0,0,0,0,0,0]
var stages_frames_per_second : PoolRealArray = [0,0,0,0,0,0]
var speed_scale : float = 20.0
const ONE_STAGE_TIME : float = 10.0
const STAGES : int = 6

var benchmarks_waits_to_be_shown : bool = false

var time_frame : Array = []


func clear_results():
	for i in range(STAGES):
		stages_frames[i] = 0
		stages_frames_per_second[i] = 0
	points = 0
	time_frame = []
	for i in range(STAGES):
		time_frame.append([])

func normalize_results():
	for i in range(STAGES):
		stages_frames[i] = int(stages_frames[i] * speed_scale)
	points = int(points * speed_scale)
