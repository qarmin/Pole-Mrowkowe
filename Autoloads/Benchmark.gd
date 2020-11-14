extends Node

var points: int = 0
var average_fps: float = 0
var stages_frames: PoolIntArray = [0, 0, 0, 0, 0, 0]
var stages_frames_per_second: PoolRealArray = [0, 0, 0, 0, 0, 0]
var speed_scale: float = 10.0
const ONE_STAGE_TIME: float = 10.0
const STAGES: int = 6

var benchmarks_waits_to_be_shown: bool = false

var time_frame: Array = []


## Czyści wyniki
func clear_results():
	for i in range(STAGES):
		stages_frames[i] = 0
		stages_frames_per_second[i] = 0
	points = 0
	time_frame = []
	for _i in range(STAGES):
		time_frame.append([])


## Należy znormalizować wyniki jeśli były uruchomione z inną niż bazową prędkością
func normalize_results():
	for i in range(STAGES):
		stages_frames[i] = int(stages_frames[i] * speed_scale)
	points = int(points * speed_scale)

	for i in range(STAGES):
		stages_frames_per_second[i] = (stages_frames[i] * STAGES) / 60.0
	average_fps = points / 60.0
