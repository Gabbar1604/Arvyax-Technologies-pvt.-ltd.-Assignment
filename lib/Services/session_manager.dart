import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:yoga_session_app/Model/session_catalog_model.dart';
import 'package:yoga_session_app/Model/pose_model.dart';

class SessionManager {
  static SessionCatalog? _catalog;
  static final Map<String, YogaSession> _loadedSessions = {};

  // Load the session catalog
  static Future<SessionCatalog> loadCatalog() async {
    if (_catalog != null) return _catalog!;

    try {
      final String catalogJson = await rootBundle.loadString(
        'assets/data/session_catalog.json',
      );

      final Map<String, dynamic> catalogData = json.decode(catalogJson);
      _catalog = SessionCatalog.fromJson(catalogData);

      print('Session catalog loaded: ${_catalog!.sessions.length} sessions');
      return _catalog!;
    } catch (e) {
      print('Error loading session catalog: $e');
      throw Exception('Failed to load session catalog');
    }
  }

  // Get specific session by ID
  static Future<YogaSession> loadSession(String sessionId) async {
    // Check if already loaded
    if (_loadedSessions.containsKey(sessionId)) {
      return _loadedSessions[sessionId]!;
    }

    // Load catalog if not loaded
    final catalog = await loadCatalog();

    // Find session metadata
    final sessionMetadata = catalog.sessions.firstWhere(
      (session) => session.id == sessionId,
      orElse: () => throw Exception('Session not found: $sessionId'),
    );

    // Load the session JSON file
    try {
      final String sessionJson = await rootBundle.loadString(
        'assets/data/${sessionMetadata.jsonFile}',
      );

      final Map<String, dynamic> sessionData = json.decode(sessionJson);
      final yogaSessionData = YogaSessionData.fromJson(sessionData);
      final yogaSession = YogaSession.fromYogaSessionData(yogaSessionData);

      // Cache the loaded session
      _loadedSessions[sessionId] = yogaSession;

      print('Session loaded: ${yogaSession.title}');
      return yogaSession;
    } catch (e) {
      print('Error loading session $sessionId: $e');
      throw Exception('Failed to load session: $sessionId');
    }
  }

  // Get all available sessions
  static Future<List<SessionMetadata>> getAvailableSessions() async {
    final catalog = await loadCatalog();
    return catalog.activeSessions;
  }

  // Get sessions by category
  static Future<List<SessionMetadata>> getSessionsByCategory(
    String category,
  ) async {
    final catalog = await loadCatalog();
    return catalog.getSessionsByCategory(category);
  }

  // Get sessions by difficulty
  static Future<List<SessionMetadata>> getSessionsByDifficulty(
    String difficulty,
  ) async {
    final catalog = await loadCatalog();
    return catalog.getSessionsByDifficulty(difficulty);
  }

  // Validate if all assets exist for a session
  static Future<bool> validateSessionAssets(String sessionId) async {
    try {
      final session = await loadSession(sessionId);

      // Check if all audio files exist
      for (final pose in session.poses) {
        if (pose.audioPath.isNotEmpty) {
          try {
            await rootBundle.load(pose.audioPath);
          } catch (e) {
            print('Missing audio file: ${pose.audioPath}');
            return false;
          }
        }

        // Check if all image files exist
        for (final image in pose.images) {
          if (image.path.isNotEmpty) {
            try {
              await rootBundle.load(image.path);
            } catch (e) {
              print('Missing image file: ${image.path}');
              return false;
            }
          }
        }
      }

      return true;
    } catch (e) {
      print('Error validating session assets: $e');
      return false;
    }
  }

  // Clear cache (useful for development)
  static void clearCache() {
    _catalog = null;
    _loadedSessions.clear();
    print('Session cache cleared');
  }

  // Get session statistics
  static Future<Map<String, dynamic>> getSessionStats() async {
    final catalog = await loadCatalog();

    final stats = <String, dynamic>{};
    stats['totalSessions'] = catalog.sessions.length;
    stats['activeSessions'] = catalog.activeSessions.length;

    // Group by category
    final categoryCounts = <String, int>{};
    for (final session in catalog.activeSessions) {
      categoryCounts[session.category] =
          (categoryCounts[session.category] ?? 0) + 1;
    }
    stats['byCategory'] = categoryCounts;

    // Group by difficulty
    final difficultyCounts = <String, int>{};
    for (final session in catalog.activeSessions) {
      difficultyCounts[session.difficulty] =
          (difficultyCounts[session.difficulty] ?? 0) + 1;
    }
    stats['byDifficulty'] = difficultyCounts;

    return stats;
  }
}
