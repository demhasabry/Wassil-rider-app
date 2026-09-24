import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

// Same public token used everywhere else in this app.
const String _mapboxPublicToken =
    'pk.eyJ1IjoiZGVtaGFzYWJyeTEzIiwiYSI6ImNtdHJ4cHdkZTA4MDYyeHNodzAydTB4OHEifQ.nK4Qu3jycEZkjLQUnQB6og';

/// Called directly from the rider app (not via a Cloud Function) so the
/// feed can show a live "X min away" on each request card without a round
/// trip through the backend for every card, every rebuild. Returns null on
/// any failure — a missing ETA should never break the feed itself.
Future<int?> fetchEtaMinutes(GeoPoint from, GeoPoint to) async {
  try {
    final url = Uri.parse(
      'https://api.mapbox.com/directions/v5/mapbox/cycling/'
      '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
      '?access_token=$_mapboxPublicToken&overview=false',
    );
    final response = await http.get(url);
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = data['routes'] as List<dynamic>?;
    if (routes == null || routes.isEmpty) return null;

    final durationSeconds = (routes[0]['duration'] as num?)?.toDouble();
    if (durationSeconds == null) return null;

    return (durationSeconds / 60).round().clamp(1, 999);
  } catch (_) {
    return null;
  }
}

// ---- Caching layer ----
//
// The feed re-renders on every Firestore update to the open-requests list
// (a new request appearing, another rider bidding, etc.) — without caching,
// that meant a fresh Mapbox call for every card on every single re-render,
// even when nothing relevant to that ETA had actually changed. This cache
// reuses a recent result unless it's gone stale or the rider has genuinely
// moved, so a request sitting in the feed for a few minutes gets its ETA
// calculated roughly once a minute instead of dozens of times.

class _CachedEta {
  final int etaMinutes;
  final DateTime calculatedAt;
  final GeoPoint riderLocationAtCalculation;
  _CachedEta(this.etaMinutes, this.calculatedAt, this.riderLocationAtCalculation);
}

final Map<String, _CachedEta> _etaCache = {};

const Duration _cacheTtl = Duration(seconds: 60);
const double _riderMoveThresholdMeters = 100;

/// Same as [fetchEtaMinutes], but keyed by requestId and cached — only
/// calls Mapbox again once the cached value is older than 60 seconds OR the
/// rider has moved more than ~100m since it was last calculated, whichever
/// comes first.
Future<int?> fetchEtaMinutesCached(String requestId, GeoPoint from, GeoPoint to) async {
  final cached = _etaCache[requestId];
  if (cached != null) {
    final age = DateTime.now().difference(cached.calculatedAt);
    final riderMovedMeters = Geolocator.distanceBetween(
      cached.riderLocationAtCalculation.latitude,
      cached.riderLocationAtCalculation.longitude,
      from.latitude,
      from.longitude,
    );
    if (age < _cacheTtl && riderMovedMeters < _riderMoveThresholdMeters) {
      return cached.etaMinutes;
    }
  }

  final result = await fetchEtaMinutes(from, to);
  if (result != null) {
    _etaCache[requestId] = _CachedEta(result, DateTime.now(), from);
  }
  return result;
}

/// Call this once a request leaves the feed for good (accepted by someone,
/// expired, cancelled) so the cache doesn't grow indefinitely over a long
/// session. Safe to call even if there's nothing cached for it.
void clearEtaCacheEntriesExcept(Set<String> activeRequestIds) {
  _etaCache.removeWhere((requestId, _) => !activeRequestIds.contains(requestId));
}
