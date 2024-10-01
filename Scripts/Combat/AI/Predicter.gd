extends Resource
class_name Predicter

signal prediction_made


func make_prediction(iteration, knowledge):
	var prediction = null
	emit_signal("prediction_made", prediction, iteration, knowledge)
