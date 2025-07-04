class GeoFence {
  final String name;
  final double latitude;
  final double longitude;
  final double radius; // meters

  const GeoFence({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radius = 50,
  });
}

const List<GeoFence> predefinedGeoFences = [
  GeoFence(name: 'Home', latitude: 37.7749, longitude: -122.4194),
  GeoFence(name: 'Office', latitude: 37.7858, longitude: -122.4364),
];
