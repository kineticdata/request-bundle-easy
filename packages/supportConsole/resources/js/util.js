function generatePastDate(range) {
	var currentDate = new Date();
	var newDate;
	if (range === "Past Month") {
		newDate = new Date(currentDate.getFullYear(), currentDate.getMonth() - 1, currentDate.getDate(),
			currentDate.getHours(), currentDate.getMinutes(), currentDate.getSeconds());
	} else if (range === "Past Week" ) {
		newDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() - 7,
			currentDate.getHours(), currentDate.getMinutes(), currentDate.getSeconds());
	} else if (range === "Past Day") {
		newDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate() - 1,
			currentDate.getHours(), currentDate.getMinutes(), currentDate.getSeconds());
	} else if (range === "Past Hour") {
		newDate = new Date(currentDate.getFullYear(), currentDate.getMonth(), currentDate.getDate(),
			currentDate.getHours() - 1, currentDate.getMinutes(), currentDate.getSeconds());
	} else {
		throw "Invalid range type passed to generatePastDate: " + range;
	}
	return moment(newDate).format('MM/DD/YYYY hh:mm:ss a');
}