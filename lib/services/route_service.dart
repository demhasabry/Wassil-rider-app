import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' show Position;

// Same public token used everywhere else in this app.
const String _mapboxPublicToken =
    'pk.eyJ1IjoiZGVtaGFzYWJyeTEzIiwiYSI6ImNtdHJ4cHdkZTA4MDYyeHNodzAydTB4OHEifQ.nK4Qu3jycEZkjLQUnQB6og';

/// Road distance in kilometers plus the actual route geometry — mirrors
/// customer_app/lib/services/pricing_service.dart's identical class (no
/// shared package between the two apps, so this is duplicated rather than
/// imported).
class RouteResult {
  final double distanceKm;
  final List<Position> coordinates;
  const RouteResult({required this.distanceKm, required this.coordinates});
}

/// Always "driving", regardless of vehicle type — matches
/// functions/src/mapboxDirections.js's profileForVehicleType and
/// pricing_service.dart's fetchRoute. The "cycling" profile used for
/// two/three-wheelers produced inaccurate routes in this region; "driving"
/// (what the truck always used) is the one that's consistently accurate.
String profileForVehicleType(String? vehicleTypeId) => 'driving';

/// Real road-following route between two points via Mapbox Directions — used
/// to draw the actual route line the rider is following, instead of a
/// straight line cutting through buildings.
Future<RouteResult?> fetchRoute(Position from, Position to, {String profile = 'driving'}) async {
  try {
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/$profile/'
      '${from.lng},${from.lat};${to.lng},${to.lat}'
      '?access_token=$_mapboxPublicToken&overview=full&geometries=geojson',
    );
    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;

    final route = routes[0] as Map<String, dynamic>;
    final distanceMeters = (route['distance'] as num?)?.toDouble();
    final coordinates = (route['geometry'] as Map<String, dynamic>?)?['coordinates'] as List<dynamic>?;
    if (distanceMeters == null || coordinates == null || coordinates.isEmpty) return null;

    return RouteResult(
      distanceKm: distanceMeters / 1000,
      coordinates: coordinates.map((pair) {
        final p = pair as List<dynamic>;
        return Position((p[0] as num).toDouble(), (p[1] as num).toDouble());
      }).toList(),
    );
  } catch (_) {
    return null;
  }
}
