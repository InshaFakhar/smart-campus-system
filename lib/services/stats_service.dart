// ============================================================
// stats_service.dart — Persistent Stats Tracking
// Tracks: buildings visited, saved routes, days active
// Storage: SharedPreferences (persists across app restarts)
// ============================================================

import 'package:shared_preferences/shared_preferences.dart';

class StatsService {
  StatsService._();
  static final StatsService instance = StatsService._();

  // SharedPreferences keys
  static const _keyVisitedBuildings = 'visited_buildings';   // JSON list of building names
  static const _keySavedRoutes      = 'saved_routes';        // JSON list of route objects
  static const _keyFirstLaunch      = 'first_launch_date';   // ISO date string
  static const _keyActiveDays       = 'active_days';         // JSON list of date strings

  // ──────────────────────────────────────────────────────────
  // BUILDING VISITS
  // ──────────────────────────────────────────────────────────

  /// Call this every time a user taps on a building tile.
  /// Adds the building name to the visited set (no duplicates).
  Future<void> trackBuildingVisit(String buildingName) async {
    final prefs   = await SharedPreferences.getInstance();
    final raw     = prefs.getStringList(_keyVisitedBuildings) ?? [];
    final visited = raw.toSet();     // Set removes duplicates automatically

    if (visited.add(buildingName)) {
      // Only write back if something actually changed
      await prefs.setStringList(_keyVisitedBuildings, visited.toList());
    }

    // Also mark today as an active day
    await _markActiveDay();
  }

  /// Returns the list of unique building names visited by the user.
  Future<List<String>> getVisitedBuildings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyVisitedBuildings) ?? [];
  }

  // ──────────────────────────────────────────────────────────
  // SAVED ROUTES
  // ──────────────────────────────────────────────────────────

  /// Saves a route. Each route is stored as "buildingName|mode|timestamp".
  /// Returns true if saved, false if already exists (same building + mode).
  Future<bool> saveRoute({
    required String buildingName,
    required String mode,
    double? destLat,
    double? destLng,
  }) async {
    final prefs  = await SharedPreferences.getInstance();
    final routes = prefs.getStringList(_keySavedRoutes) ?? [];

    // Check for duplicate (same building + same mode)
    final key = '$buildingName|$mode';
    final alreadySaved = routes.any((r) => r.startsWith(key));
    if (alreadySaved) return false;

    final entry = '$buildingName|$mode|${DateTime.now().toIso8601String()}'
        '|${destLat ?? ""}|${destLng ?? ""}';
    routes.add(entry);
    await prefs.setStringList(_keySavedRoutes, routes);
    await _markActiveDay();
    return true;
  }

  /// Removes a saved route by building name + mode.
  Future<void> removeSavedRoute(String buildingName, String mode) async {
    final prefs  = await SharedPreferences.getInstance();
    final routes = prefs.getStringList(_keySavedRoutes) ?? [];
    final key    = '$buildingName|$mode';
    routes.removeWhere((r) => r.startsWith(key));
    await prefs.setStringList(_keySavedRoutes, routes);
  }

  /// Returns list of saved routes as parsed maps.
  Future<List<Map<String, String>>> getSavedRoutes() async {
    final prefs  = await SharedPreferences.getInstance();
    final routes = prefs.getStringList(_keySavedRoutes) ?? [];

    return routes.map((r) {
      final parts = r.split('|');
      return {
        'buildingName': parts.length > 0 ? parts[0] : '',
        'mode':         parts.length > 1 ? parts[1] : '',
        'savedAt':      parts.length > 2 ? parts[2] : '',
        'lat':          parts.length > 3 ? parts[3] : '',
        'lng':          parts.length > 4 ? parts[4] : '',
      };
    }).toList();
  }

  /// Checks if a specific route (building + mode) is already saved.
  Future<bool> isRouteSaved(String buildingName, String mode) async {
    final prefs  = await SharedPreferences.getInstance();
    final routes = prefs.getStringList(_keySavedRoutes) ?? [];
    final key    = '$buildingName|$mode';
    return routes.any((r) => r.startsWith(key));
  }

  // ──────────────────────────────────────────────────────────
  // ACTIVE DAYS
  // ──────────────────────────────────────────────────────────

  /// Records today as an active day (deduped by date string).
  Future<void> _markActiveDay() async {
    final prefs      = await SharedPreferences.getInstance();
    final today      = _todayKey();
    final activeDays = (prefs.getStringList(_keyActiveDays) ?? []).toSet();

    if (activeDays.add(today)) {
      await prefs.setStringList(_keyActiveDays, activeDays.toList());
    }
  }

  /// Returns count of unique days the user has been active.
  Future<int> getActiveDaysCount() async {
    final prefs = await SharedPreferences.getInstance();
    final days  = prefs.getStringList(_keyActiveDays) ?? [];
    // Always at least 1 (today counts as first launch day)
    if (days.isEmpty) {
      await _markActiveDay();
      return 1;
    }
    return days.length;
  }

  // ──────────────────────────────────────────────────────────
  // LOAD ALL STATS (convenience method for ProfileScreen)
  // ──────────────────────────────────────────────────────────

  /// Returns a map with all three stats at once.
  /// { 'buildings': int, 'routes': int, 'days': int }
  Future<Map<String, int>> loadStats() async {
    final visited = await getVisitedBuildings();
    final routes  = await getSavedRoutes();
    final days    = await getActiveDaysCount();

    return {
      'buildings': visited.length,
      'routes':    routes.length,
      'days':      days,
    };
  }

  // ──────────────────────────────────────────────────────────
  // HELPERS
  // ──────────────────────────────────────────────────────────

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Clears all stats — use only for debug/reset purposes.
  Future<void> clearAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyVisitedBuildings);
    await prefs.remove(_keySavedRoutes);
    await prefs.remove(_keyActiveDays);
    await prefs.remove(_keyFirstLaunch);
  }
}