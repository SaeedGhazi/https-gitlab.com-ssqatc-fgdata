# WARNING: *.draw files will be deprecated, see: http://wiki.flightgear.org/MapStructure
var draw_parking = func(group, apt, lod) {
	var group = group.createChild("group", "apt-"~apt.id);
	foreach(var park; apt.parking()) {
	var icon_park =
	group.createChild("text", "parking-" ~ park.name)
		.setMarkup("<u>" ~ park.name ~ "</u>")
		.setFont(family: "Liberation Mono", weight: "Bold", size: 15)
		.setGeoPosition(park.lat, park.lon)
	}
}

